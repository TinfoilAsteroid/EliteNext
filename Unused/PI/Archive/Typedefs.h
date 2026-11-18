#ifndef  TYPEDEFS_H_
#define  TYPEDEFS_H_

// Pullin the ship defintions rather than have them in the z80 code.
typedef enum EFileStatus
{
    fileSuccess, 
    fileNoOperation,
    fileReadFail,
    fileReadNoInput,
    fileBufferEmpty,
    fileWriteFail,
    fileEndOfBuffer
} EFileStatus;

typedef enum EWriteMode
{
    appendMode,
    sendMode
} EWriteMode;

typedef enum EIOMode
{
    binary,
    text,
    textverbose
} EIOMode;

#endif