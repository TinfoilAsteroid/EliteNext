# The Pi debug interface: writing Next memory from the Pi

How a Raspberry Pi Zero on the accelerator header reads and writes the Next's memory, NextRegs and CPU directly, with no Z80 code running. This is the interface a Pi renderer for EliteNext would use (the design proposal and its open questions are in [TODO.md](TODO.md#pi-renderer)).

Sources: the official core's `pi_debug_control` (core 3.02.04 on, by David Saphier, in the ZX Spectrum Next FPGA tree under `cores/zxnext/src/device/pi_debug_control`, with a `readme.txt`), and [NextTang](https://github.com/jattree/NextTang), which carries the same logic and a Python client (`host/debug/nexttang_debug/protocol.py`) checked against it in simulation. Read from NextTang on 2026-11-23; check the official readme before relying on a detail.

## Overview

- The **Pi is the SPI master** and the FPGA is the slave. The Pi's own SPI0 pins are used, so Linux `spidev` works as is.
- **SPI mode 0** (CPOL 0, CPHA 0), most significant bit first.
- **One command is one chip select.** Every byte the Pi sends clocks one byte back. Raising chip select resets the slave's command state.
- The Pi sends `00` whenever it has nothing to send (filler while reading). If the Pi loses sync the slave goes into an error state (status bit 0); dropping chip select and starting again clears the command state.
- Main memory (SRAM) can be read and written **while the Z80 runs**. Banks 5 and 7 and the CPU registers need the CPU paused.

## Pins and enabling it

| Pi GPIO | SPI0 signal | Direction when the slave is on |
|---|---|---|
| 8 | CE0 | Pi to Next |
| 9 | MISO | Next to Pi |
| 10 | MOSI | Pi to Next |
| 11 | SCLK | Pi to Next |

NextReg `0xA0` (Pi peripheral enable):
- bit 1: Pi SPI0 **slave**, the debug interface (the Pi is master).
- bit 0: Pi SPI0 **master**, the older mode where the Next drives the Pi through ports `0xE7` / `0xEB`.

The two modes use the same pins, so only one can be on; the slave takes priority. The Pi's UART (GPIO 14 / 15) is separate, so a NextPi / AlpineNext console over UART keeps working. Set bit 1 from the Z80 at start up (read NextReg `0xA0` first and keep its other bits), or by any other means that writes NextRegs.

## Commands

Every valid command byte has `A` as its upper nibble. `xx` is a filler byte the Pi sends (`00`); "junk" is a byte that comes back undefined.

| Byte | Command | Pi sends | Reply | Needs |
|---|---|---|---|---|
| `A0` | NOP | `A0` | | |
| `A1` | VERSION | `A1 xx xx xx` | byte 2: version in bits 7:4; byte 3: capabilities | |
| `A2` | STATUS | `A2 xx xx xx` | byte 2: status; byte 3: hotkeys | |
| `A3` | SYSTEM | `A3 bits` | | |
| `A4` | CPU PAUSE | `A4` | poll STATUS until paused | |
| `A5` | CPU RESUME | `A5` | cancels a pause or a step at once | |
| `A6` | CPU STEP | `A6` | runs one instruction, then pauses (acts as PAUSE if not paused) | |
| `A7` | SRAM READ | `A7 A20:16 A15:8 A7:0 L15:8 L7:0`, then `L + 1` fillers | byte 6 junk, data from byte 7 | |
| `A8` | SRAM WRITE | `A8 A20:16 A15:8 A7:0 L15:8 L7:0 data...` | | |
| `A9` | BRAM READ | `A9 A15:8 A7:0 L15:8 L7:0`, then `L + 1` fillers | byte 5 junk, data from byte 6 | CPU paused |
| `AA` | BRAM WRITE | `AA A15:8 A7:0 L15:8 L7:0 data...` | | CPU paused |
| `AB` | NEXTREG READ | `AB reg xx xx` | byte 3: value | |
| `AC` | NEXTREG WRITE | `AC reg value xx` | | |
| `AD` | CPU REG READ | `AD reg xx xx` | byte 3: value | CPU paused |
| `AE` | CPU REG WRITE | `AE reg value xx` | | CPU paused |

### Info bytes

- **Version:** bits 7:4.
- **Capabilities** (bit 7 to 0): tape hotkeys, CPU registers, BRAM (banks 5 / 7), pause / resume / step, SRAM, NextReg write, NextReg read, system. VERSION and STATUS are always there.
- **Status** (bit 7 to 0): had reset, bus state (2 bits: `00` running, `01` stopping the CPU, `10` paused, `11` releasing for one step), DMA active (active low), CPU halted (active low), 0, 0, had error.
- **Hotkeys:** `0 0 0 Q W E R T` (tape controls, pulsed).
- **System bits** (`A3`): `01` soft reset, `02` hard reset, `04` DivMMC NMI, `08` Multiface NMI, `10` CTC channel 3 interrupt.

### CPU register numbers (`AD` / `AE`)

| Reg | No. | Reg | No. | Reg | No. |
|---|---|---|---|---|---|
| A | 00 | A' | 08 | IXH | 10 |
| F | 01 | F' | 09 | IXL | 11 |
| B | 02 | B' | 0A | IYH | 12 |
| C | 03 | C' | 0B | IYL | 13 |
| D | 04 | D' | 0C | SPH | 14 |
| E | 05 | E' | 0D | SPL | 15 |
| H | 06 | H' | 0E | PCH | 16 |
| L | 07 | L' | 0F | PCL | 17 |
| I | 18 | R | 19 | | |

`1A` reads the CPU state: `0 0 IM1 IM0 0 HALT IFF2 IFF1`. `1B` writes HALT, IFF2 and IFF1 only. NextTang clears HALT when it sets PC, as JNext does, or the CPU stays parked on the HALT.

## Addresses

SRAM commands take a **21 bit physical address** (2 MB), not a Z80 address.

- 8K page `p` is at `0x40000 + p * 0x2000` (16K bank `b` is at `0x40000 + b * 0x4000`).
- To turn a Z80 address into a physical one, read the MMU slot's page from NextReg `0x50 + (addr >> 13)` with `AB`.
- **Banks 5 and 7 are only in FPGA block RAM** (8K pages `0A`, `0B` and `0E`). An SRAM write to them doesn't reach what the Z80 or the ULA sees. Use the BRAM commands, with the CPU paused: address bit 15 = 0 is bank 5 (16K), 1 is bank 7 (8K); the address wraps at the bank's size.
- **ROM (page `FF`) can't be reached.** NextTang reads it as `FF`.

EliteNext's Layer 2 (256 x 192, 64 rows per 16K bank; [Layer2Graphics/layer2_defines.asm](Layer2Graphics/layer2_defines.asm)):

| Buffer | 16K banks | 8K pages | Physical | Top 128 rows (2/3) |
|---|---|---|---|---|
| `LAYER2_SCREEN_BANK1` | 8 to 10 | 16 to 21 | `0x60000` to `0x6BFFF` | `0x60000` to `0x67FFF` |
| `LAYER2_SHADOW_BANK1` | 13 to 15 | 26 to 31 | `0x74000` to `0x7FFFF` | `0x74000` to `0x7BFFF` |

Which buffer is shown changes with [l2_flip_buffers](Layer2Graphics/l2_flip_buffers.asm): read NextReg `0x12` (shown) and `0x13` (shadow) with `AB` rather than assume.

## Limits

- **Speed.** NextTang runs it cleanly at up to 3 MHz SCLK (its slave is reached through an FPGA side master, not a real Pi). That's about 375 KB/s less 6 bytes a command. The top speed on a real Next with a real Pi is not known: measure it.
- **Pausing stops only the CPU.** Video, sound, timers and the copper carry on, and an interrupt due during a pause is missed.
- **Contention.** SRAM port C shares the memory with the CPU and the DMA. What it costs the Z80 at 28 MHz isn't known: measure it.
- **Frame size.** NextTang splits transfers into 256 byte frames because of its UART link. Over SPI from a Pi the length field allows up to 65535 bytes in one command; `spidev`'s own buffer limit (4096 bytes by default, the `bufsiz` module parameter) is what to watch.

## Using it from the Pi (Python)

Enable SPI on the Pi (`dtparam=spi=on` in `config.txt`, giving `/dev/spidev0.0` for CE0). A transport for NextTang's `PiDebug` client is one `exchange` method:

```python
import spidev

class SpiTransport:
    """One call is one chip select: send every byte, return every byte that came back."""

    def __init__(self, bus=0, device=0, hz=3_000_000):
        self.spi = spidev.SpiDev()
        self.spi.open(bus, device)
        self.spi.mode = 0
        self.spi.max_speed_hz = hz

    def exchange(self, sent: bytes) -> bytes:
        return bytes(self.spi.xfer2(list(sent)))
```

Then, with `protocol.py` from NextTang (GPL-3.0-or-later):

```python
from nexttang_debug.protocol import PiDebug, Z80Memory

debug = PiDebug(SpiTransport())
print(debug.version().names)               # what the core supports
debug.write_memory(0x74000, bytes(256))    # first row of the shadow Layer 2 buffer
shadow = debug.nextreg(0x13)               # which bank is the shadow buffer now
debug.pause(); print(debug.registers()); debug.resume()
mem = Z80Memory(debug)                     # Z80 addresses through the MMU
```

Or by hand, a write of `data` at physical address `a`:

```python
n = len(data)
spi.xfer2([0xA8, a >> 16 & 0x1F, a >> 8 & 0xFF, a & 0xFF, n >> 8, n & 0xFF, *data])
```

## Testing without hardware

nexsim doesn't model the interface yet. The plan in [TODO.md](TODO.md#pi-renderer) adds a `pi_debug_control` slave to nexsim with the same `exchange` shape, so the same Python code can drive the emulator and, later, the Pi.
