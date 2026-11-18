#include "PortIO.h"

#define debug 1

void data_ready()
{
    gpioWrite(PIN_DATA_READY,PIN_HIGH);
}

void data_not_ready()
{
    gpioWrite(PIN_DATA_READY,PIN_LOW);
}

bool is_clear_to_send()
{
    if (gpioRead(PIN_CLEAR_TO_SEND) == PIN_HIGH)
    {
        return true;
    }
    else
    {
        return false;
    }
}

void wait_for_data_read_to_read()
{
     // Wait and check for a clear to send
    while(is_clear_to_send() == true)
    {
        gpioDelay(1);
    }   
}

void wait_for_ready_to_send()
{
     // Wait and check for a clear to send
    while(is_clear_to_send() == false)
    {
        gpioDelay(1);
    }   
}

void ack_byte()
{
    data_ready();
}

void initialise_gpio()
{
    unsigned int a = 0;
    a = gpioInitialise();
    #ifdef debug
    printf("initialise_gpio state %i\n",a);
    #endif
    set_read_mode();                            // defaults we are reading port for an action
    gpioSetMode(PIN_READY_TO_SEND,PI_OUTPUT);   //     data is ready
    gpioSetMode(PIN_CLEAR_TO_SEND,PI_INPUT);    //     Clear to send
    data_not_ready();
}

void set_write_mode()
{
    gpioSetMode(PIN_BIT_0, PI_OUTPUT);    // bit 0
    gpioSetMode(PIN_BIT_1, PI_OUTPUT);    //     1
    gpioSetMode(PIN_BIT_2, PI_OUTPUT);    //     2
    gpioSetMode(PIN_BIT_3, PI_OUTPUT);    //     3
    gpioSetMode(PIN_BIT_4, PI_OUTPUT);    //     4
    gpioSetMode(PIN_BIT_5, PI_OUTPUT);    //     5
    gpioSetMode(PIN_BIT_6, PI_OUTPUT);    //     6
    gpioSetMode(PIN_BIT_7, PI_OUTPUT);    //     7
}

void set_read_mode()
{
    gpioSetMode(PIN_BIT_0, PI_INPUT);    // bit 0
    gpioSetMode(PIN_BIT_1, PI_INPUT);    //     1
    gpioSetMode(PIN_BIT_2, PI_INPUT);    //     2
    gpioSetMode(PIN_BIT_3, PI_INPUT);    //     3
    gpioSetMode(PIN_BIT_4, PI_INPUT);    //     4
    gpioSetMode(PIN_BIT_5, PI_INPUT);    //     5
    gpioSetMode(PIN_BIT_6, PI_INPUT);    //     6
    gpioSetMode(PIN_BIT_7, PI_INPUT);    //     7
}

void write_byte(unsigned char pByte)
{
    unsigned char bitArray[8] = {PIN_LOW,PIN_LOW,PIN_LOW,PIN_LOW,PIN_LOW,PIN_LOW,PIN_LOW,PIN_LOW};
    unsigned int  bitIndex = 8;
    unsigned int  bitMask  = 128;
    unsigned int  bitValue = 0;
    unsigned int i;
    // Prep bits
    for (i = bitIndex; i > 0; i--)
    {
        if (pByte && bitMask != 0)
        {
            bitArray[i]= PIN_HIGH;
        }
        bitMask = bitMask >> 1;
    }
    // Wait and check for a clear to send
    while(is_clear_to_send() == false)
    {
        gpioDelay(1);
    }
    not_ready_to_send();
    //Now we are clear then write
    for (i = PIN_BIT_0; i <= PIN_BIT_7; i++)
    {
        gpioWrite(i,bitArray[i - PIN_BIT_0]);
    }
    ready_to_send();
    // on clear to send then that is an ACK of read so set port to read mode
    gpioSetAlertFunc(PIN_CLEAR_TO_SEND,PIN_HIGH,set_write_mode); 
}


unsigned char read_byte()
{
    unsigned int  bitIndex = 8;
    unsigned int  bitMask  = 128;
    uint32_t      byteValue = 0;
    uint32_t      bits0to31;
    unsigned int i;
    // Prep bits
    data_not_ready();
    wait_for_data_read_to_read();
    bits0to31 = gpioRead_Bits_0_31();
    //                          33222222222211111111110000000000
    //                          10987654321098765432109876543210
    byteValue = (bits0to31 && 0b00000000000000000000111111110000)>>4;
    // on completion of read acknowledge via data ready bit 
    ack_byte();
    return  (usigned char)byteValue;
}   