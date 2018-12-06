#include "../SmartCar.h"
module CarP @safe(){
    provides{
        interface Car;
        //interface Arm;
    }
    uses{
        interface Resource;
        interface HplMsp430Usart;
        
    }
}
implementation{
    cc_message_t car_command;//小车串口控制命令

    msp430_uart_union_config_t config = {
        utxe: 1,
        urxe: 1,
        ubr: UBR_1MHZ_115200,
        umctl: UMCTL_1MHZ_115200,
        ssel: 0x02,
        pena: 0,
        pev: 0,
        clen: 1,
        listen: 0,
        mm: 0,
        ckpl: 0,
        urxse: 0,
        urxeie: 0,
        urxwie: 0,
        utxe: 1,
        urxe: 1
    };

    command error_t Car.goForward(uint16_t value){
        car_command.type = 2;
        car_command.value = value;

    }

    event void Resource.granted(){
        call HplMsp430Usart.setModeUart(&config);
        call HplMsp430Usart.enableUart();
        atomic{
            U0CTL &= ~SYNC;
            uint8_t message[8];
            message[0] = 0x01;
            message[1] = 0x02;
            message[2] = car_command.type;
            message[3] = car_command.value / 256;
            message[4] = car_command.value % 256;
            message[5] = 0xFF;
            message[6] = 0xFF;
            message[7] = 0xFF;
            for(int i=0; i<7; i++){
                call HplMsp430Usart.tx(message[i]);
                while(!call HplMsp430Usart.isTxEmpty());
            }
        }
        call Resource.release();
    }
}