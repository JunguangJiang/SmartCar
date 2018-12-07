#include "../SmartCar.h"
#include <msp430usart.h>
module CarP @safe(){
    provides{
        interface Wheel;
        interface Arm;
    }
    uses{
        interface Resource;
        interface HplMsp430Usart;
        
        //interface HplMsp430UsartInterrupts;
        //interface HplMsp430GeneralIO;
    }
}
implementation{
    cc_message_t car_command;//小车串口控制命令

    uint8_t message[8]; 
    int i;

    int16_t angle[3];//三个角度
    
    error_t setCarCommand(uint8_t type, uint16_t value){
        atomic{
            car_command.type = 2;
            car_command.value = value;
        }
        return call Resource.request();
    }

    msp430_uart_union_config_t config = {
        {
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
        }
    };

    command error_t Wheel.goForward(uint16_t value){//小车前进
        return setCarCommand(2,value);
    }

    command error_t Wheel.goBackward(uint16_t value){//小车后退
        return setCarCommand(3,value);
    }

    command error_t Wheel.turnLeft(uint16_t value){//小车左转
        return setCarCommand(4,value);
    }

    command error_t Wheel.turnRight(uint16_t value){//小车右转
        return setCarCommand(5,value);
    }

    command error_t Wheel.stop(){
        return setCarCommand(6,0);
    }

    void initAngle(){//初始化角度
        angle[0] = INIT_ANGLE0;
        angle[1] = INIT_ANGLE1;
        angle[2] = INIT_ANGLE2;
    }

    command error_t Arm.comeDown(){
        angle[0] -= DELTA_ANGLE0;
        angle[0] = max(MIN_ANGLE, angle[0]);
        printf("angle0=%i\n",angle[0]);
        return setCarCommand(1,angle[0]);
    }

    command error_t Arm.raiseUp(){
        angle[0] += DELTA_ANGLE0;
        angle[0] = min(MAX_ANGLE, angle[0]);
        printf("angle0=%i\n",angle[0]);
        return setCarCommand(1,angle[0]);
    }

    command error_t Arm.turnLeft(){
        angle[1] -= DELTA_ANGLE1;
        angle[1] = max(MIN_ANGLE, angle[1]);
        printf("angle1=%i\n",angle[1]);
        return setCarCommand(7, angle[1]);
    }

    command error_t Arm.turnRight(){
        angle[1] += DELTA_ANGLE1;
        angle[1] = min(MAX_ANGLE, angle[1]);
        printf("angle1=%i\n",angle[1]);
        return setCarCommand(7, angle[1]);
    }

    command error_t Arm.home(){
        initAngle();
        setCarCommand(1, angle[0]);
        setCarCommand(7, angle[1]);
        return setCarCommand(8, angle[2]);
    }

    event void Resource.granted(){
        call HplMsp430Usart.setModeUart(&config);
        call HplMsp430Usart.enableUart();
        atomic{
            U0CTL &= ~SYNC;
            message[0] = 0x01;
            message[1] = 0x02;
            message[2] = car_command.type;
            message[3] = car_command.value / 256;
            message[4] = car_command.value % 256;
            message[5] = 0xFF;
            message[6] = 0xFF;
            message[7] = 0x00;
            for(i=0; i<7; i++){
                call HplMsp430Usart.tx(message[i]);
                while(!call HplMsp430Usart.isTxEmpty());
            }
        }
        call Resource.release();
    }
}