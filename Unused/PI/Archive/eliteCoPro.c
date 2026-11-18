
#include "Typedefs.h"
#include "ConsoleIO.h"
#include "CommandProcessor.h"
#define debug 1
//#define debug_noop 1
/* TO DO
   ready to accept "~" prompt
   z buffer hidden line removal as well as clipping
*/

int main(int argc, char *argv[])
{
    int                 status = 0;
    EnumCommands        commandId;

    #ifdef debug
    printf("Initialised\n");
    #endif
    clear_input_buffer();
    write_ready();  
    while (status == 0)
    {
        #ifdef debug
        printf("In main loop %i\n",status);
        #endif
        commandId = read_command();
        switch(commandId)
        {
            case InvalidCommand:
            {
                #ifdef debug
                printf("Invalid Command\n");
                #endif
                break;
            }
            case NoOperation:
            {
                 #ifdef debug_noop
                 printf("NoOp\n");
                 #endif
                 break;
            }
            case Exit:
                 status = -1;
            default:
            {
                 #ifdef debug
                 printf("Processing command %i\n", (int)commandId);
                 #endif
                 processCommand(commandId);
                 clear_input_buffer();
                 if (commandId != Exit) 
                 {
                     write_ready();
                 }
            }
        }
    }
    return 0;
}