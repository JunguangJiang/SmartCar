#include <msp430usart.h>
configuration CarC{
    provides{
        interface Car;
        //interface Arm;
    }
}
implementation{
    components CarP;
    Car=CarP;
    Arm=CarP;
}