#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include "Typedefs.h"
#include "ConsoleIO.h"
#include "Maths3d.h"
#include "Vector.h"
#include "ShipData.h"
#include "ShipModels.h"

#define debug   1

//#define  buffered 1

EIOMode      input_output_mode     = textverbose;

char         in_buffer[io_buffer_size];
unsigned int in_buffer_index       = 0;
char         separator[]="|";
char         eol[]      ="\n";
char         readyMessage[] = "~";
char         readyMessageVerbose[]="ReadyForInput~";
char         exitMessage[] = "@";
char         exitMessageVerbose[] = "Exiting@";

//static char        out_buffer[io_buffer_size];
//static unsigned int         out_buffer_index      = 0;
//static int         separator             = '|';
//static int         eolseparator          = '\n';// Only used for text, binary mode is always fixed length

 /* sets mode for IO to ascii with 0x13 terminator */
 void set_text_mode(void)
 { 
     freopen(NULL, "r", stdin);
     freopen(NULL, "w", stdout);
     input_output_mode = text;
 }
 
 void set_text_verbose_mode(void)
 {
     freopen(NULL, "r", stdin);
     freopen(NULL, "w", stdout);
     input_output_mode = textverbose;   
 }
 
 void clear_input_buffer(void)
 {
     in_buffer_index = 0;
     in_buffer[0] = '\0';
 }
 
 /* sets mode for IO as 24 bit integrer for all numbers */
 void set_binary_mode(void)
 {
     freopen(NULL, "rb", stdin);
     freopen(NULL, "wb", stdout);
     input_output_mode = binary;
 }
 
 EnumCommands read_command(void)
 {
     int    readlength = 0;
     #ifdef debug
     printf("entering read_command\n");
     #endif     
     if (input_output_mode != binary)
     {
         readlength = fread(in_buffer,1,3,stdin);
         if (readlength != 3)
         {
            return NoOperation;
         }
         else
         {
            in_buffer[2] = '\0';        // All commands are only 2 characters so a fast buffer clear for the last input
            int instruction = atoi (in_buffer);
            #ifdef debug
            printf("Instruction %s ASCII %i %i len %i nbr %i exit %i \n", in_buffer,(int)in_buffer[0], (int)in_buffer[1], readlength,instruction, (int)Exit);
            #endif
            if  (instruction <= (int)Exit)
            {
                return (EnumCommands)atoi(in_buffer);
            }
            else
            {
                return InvalidCommand;
            }
         }
     }
     else
     {
         if (fread(in_buffer,1,1,stdin) != 1)
         {
             return Exit;
         }
         else
         {
             return (EnumCommands)in_buffer[0];
         }
     }
 }
 
 double  read_double()
 {
     double value;
     double multiplier;
     char    last_read;
     int     head;
 
     #ifdef debug
     printf("CIO:ReadDbl");
     #endif
     if (input_output_mode != binary)
     {
         fread(in_buffer,1,1,stdin);
         if (in_buffer[0] == '-')
         {
             #ifdef debug
             printf("LeadNegative\n");
             #endif 
             multiplier = -1.0;
             head       = 0;
         }
         else
         {
             #ifdef debug
             printf("LeadDigit %c\n",in_buffer[0]);
             #endif 
             multiplier = 1.0;
             head       = 1;
         }
         // an non "-" "0..9" is a sparator
         for (in_buffer_index = head; in_buffer_index < io_buffer_size; in_buffer_index++)
         {
             #ifdef debug
             printf("@");
             #endif 
             if (fread(&in_buffer[in_buffer_index],1,1,stdin) != 1)
             {
                #ifdef debug
                printf("Invalid buffer length \n");
                #endif 
                break;
             }
             last_read = in_buffer[in_buffer_index];
             if  ((last_read < '0' || last_read > '9') && last_read != '-')
             {
                #ifdef debug
                printf("Separator index %i ASCII %i\n",in_buffer_index,(int)last_read);
                #endif 
                break;
             }
             #ifdef debug
             else
             {
                 printf("CHR: %c %i\n",last_read,in_buffer_index);
             }
             #endif 
                 
         }
         #ifdef debug
         printf("Evaluating, termination index %i \n",in_buffer_index);
         #endif
         strcpy(&(in_buffer[in_buffer_index]),"");
         printf("Entered value %s\n",in_buffer);
         value = atoi(in_buffer);
         value *= multiplier;
     }
     else
     {
         value = 0;
         if (fread(in_buffer,1,3,stdin) != 3)
         {
             return 0;
         }
         else
         {
             value = (unsigned char)in_buffer[0] + ((unsigned char)in_buffer[1] * 256) + (((unsigned char)in_buffer[2] & 127) * 256 * 256);
             if (((unsigned char)in_buffer[2] & 128) != 0)
             {
                 value *= -1.0;
             }
         }
     }
     #ifdef debug
     printf("=%f\n", value);
     #endif
     return value;
 }

void read_vector(Vector *vector)
{
    vector->x = read_double();
    vector->y = read_double();        
    vector->z = read_double();        
}

void read_matrix(Matrix *matrix)
{
    read_vector(&matrix->row[0]);
    read_vector(&matrix->row[1]);
    read_vector(&matrix->row[2]);
}

void reverse(char s[])
{
    int i, j;
    char c;

    for (i = 0, j = strlen(s)-1; i<j; i++, j--) {
        c = s[i];
        s[i] = s[j];
        s[j] = c;
    }
}  

void itoa(int n, char s[])
{
    int i, sign;

    if ((sign = n) < 0)  /* record sign */
        n = -n;          /* make n positive */
    i = 0;
    do {       /* generate digits in reverse order */
        s[i++] = n % 10 + '0';   /* get next digit */
    } while ((n /= 10) > 0);     /* delete it */
    if (sign < 0)
        s[i++] = '-';
    s[i] = '\0';
    reverse(s);
}  

//*** for read and write we need the appropriate version of 1 for scaling to send to spectrum

void write_text(char *message)
{
    #ifdef debug
    printf("Message len %i string %s\n",(int)strlen(message),message);
    #endif
    write(STDOUT_FILENO,message,(int)strlen(message));
}

void write_ready(void)
{
    write_text (input_output_mode != textverbose?readyMessage:readyMessageVerbose);
}

void write_exit(void)
{
    write_text (input_output_mode != textverbose?exitMessage:exitMessageVerbose);
}

void write_int(int value)
{
    char out_buffer[30];

    #ifdef debug
    printf("In write_int");
    #endif
    if (input_output_mode != binary)
    {
        #ifdef debug
        printf("Text>");
        #endif
        if (value == 0)
        {
            #ifdef debug
            printf("its 0 write>");
            #endif
            write(STDOUT_FILENO,"0",1);
        }
        else
        {
            itoa(value,out_buffer);
            write(STDOUT_FILENO,out_buffer,strlen(out_buffer));
            #ifdef debug
            printf("Iwritten>");
            #endif
        }
        #ifdef debug
        printf("IDone>");
        #endif

    }
    else
    {
        #ifdef debug
        printf("Binary write double to be implemented\n");
        #endif
    }
}

void write_double(double value)
{
    write_int((int)value);
}

void write_vector(Vector *vect)
{
    write_double(vect->x);
    write_separator();
    write_double(vect->y);
    write_separator();
    write_double(vect->z);
}

void write_matrix(Matrix *mat)
{
    write_vector(&(mat->row[0]));
    write_separator();
    write_vector(&(mat->row[1]));
    write_separator();
    write_vector(&(mat->row[2]));
    write_separator();
}

void write_separator(void)
{
    write(STDOUT_FILENO,separator,1);
}

void write_terminator(void)
{
    write(STDOUT_FILENO,eol,1);
}

