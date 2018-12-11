#include <msp430usart.h>
configuration CarC{
    provides{
        interface Wheel;
        interface Arm;
    }
}
implementation{
    components CarP;
    Wheel=CarP;
    Arm=CarP;

    components HplMsp430Usart0C;
    components new Msp430Uart0C();
    components new TimerMilliC() as Timer0;

    CarP.Resource -> Msp430Uart0C;
    CarP.HplMsp430Usart -> HplMsp430Usart0C;
    CarP.Timer0 -> Timer0;
}