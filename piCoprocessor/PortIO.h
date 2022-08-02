#ifndef  PORTIO_H_
#define  PORTIO_H_

#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>

#define PIN_BIT_0         4
#define PIN_BIT_1         5
#define PIN_BIT_2         6
#define PIN_BIT_3         7
#define PIN_BIT_4         8
#define PIN_BIT_5         9
#define PIN_BIT_6         10
#define PIN_BIT_7         11
#define PIN_DATA_READY    24
#define PIN_CLEAR_TO_SEND 25
#define PIN_HIGH          1
#define PIN_LOW           10

void data_ready();
void data_not_ready();
bool is_clear_to_send();
void wait_for_ready_to_send();
void ack_byte();
void initialise_gpio();
void set_write_mode();
void set_read_mode();
void write_byte(unsigned char pByte);
unsigned char read_byte();