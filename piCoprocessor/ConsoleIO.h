#ifndef  CONSOLEIO_H_
#define  CONSOLEIO_H_

#include <stdio.h>
#include "Typedefs.h"
#include "Vector.h"
#include "CommandProcessor.h"

#define io_buffer_size 5000
    

void            set_text_mode(void);
void            set_text_verbose_mode(void);
void            set_binary_mode(void);
void            clear_input_buffer(void);
EnumCommands    read_command(void);

EnumCommands    read_command(void);
double          read_double(void);
void            read_vector(Vector *vector);
void            read_matrix(Matrix *matrix);
void            reverse(char s[]);
void            itoa(int n, char s[]);
void            write_text(char *message);
void            write_ready(void);
void            write_exit(void);
void            write_int(int value);
void            write_double(double value);
void            write_vector(Vector *vect);
void            write_matrix(Matrix *mat);
void            write_separator(void);
void            write_terminator(void);
#endif