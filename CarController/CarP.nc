#include "../SmartCar.h"
#include <msp430usart.h>
#include "printf.h"
#include "queue.h"

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

    uint8_t message[8]={1,2,1,0,0,0xff,0xff,0}; //串口通信序列
    int8_t i;

    int16_t angle[3];//三个角度

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
        insertQueue(2,value);
        return call Resource.request();
    }

    command error_t Wheel.goBackward(uint16_t value){//小车后退
        insertQueue(3,value);
        return call Resource.request();
    }

    command error_t Wheel.turnLeft(uint16_t value){//小车左转
        insertQueue(4,value);
        return call Resource.request();
    }

    command error_t Wheel.turnRight(uint16_t value){//小车右转
        insertQueue(5,value);
        return call Resource.request();
    }

    command error_t Wheel.stop(){
        insertQueue(6,0);
        return call Resource.request();
    }

    void initAngle(){//初始化角度
        angle[0] = INIT_ANGLE0;
        angle[1] = INIT_ANGLE1;
        angle[2] = INIT_ANGLE2;
    }

    command error_t Arm.comeDown(){
        atomic{
            angle[0] -= DELTA_ANGLE0;
            angle[0] = max(MIN_ANGLE, angle[0]);
        }
        printf("angle0=%i\n",angle[0]);
        insertQueue(1,angle[0]);
        return call Resource.request();
    }

    command error_t Arm.raiseUp(){
        atomic{
            angle[0] += DELTA_ANGLE0;
            angle[0] = min(MAX_ANGLE, angle[0]);
        }
        printf("angle0=%i\n",angle[0]);
        insertQueue(1,angle[0]);
        return call Resource.request();
    }

    command error_t Arm.turnLeft(){
        atomic{
            angle[1] -= DELTA_ANGLE1;
            angle[1] = max(MIN_ANGLE, angle[1]);
        }
        printf("angle1=%i\n",angle[1]);
        insertQueue(7,angle[1]);
        return call Resource.request();
    }

    command error_t Arm.turnRight(){
        atomic{
            angle[1] += DELTA_ANGLE1;
            angle[1] = min(MAX_ANGLE, angle[1]);
        }
        printf("angle1=%i\n",angle[1]);
        insertQueue(7,angle[1]);
        return call Resource.request();
    }

    command error_t Arm.home(){
        initAngle();
        insertQueue(1, angle[0]);
        insertQueue(7, angle[1]);
        insertQueue(8,angle[2]);
        return call Resource.request();
    }

    event void Resource.granted(){
        call HplMsp430Usart.setModeUart(&config);
        call HplMsp430Usart.enableUart();
        while(!isQueueEmpty()){
            atomic{
                U0CTL &= ~SYNC;
                printf("Queue size=%i\n", queueSize());
                car_command = removeFromQueue();
                message[2] = car_command.type;
                message[3] = car_command.value / 256;
                message[4] = car_command.value % 256;
                printf("transfering :");
                for(i=0; i<8; i++){
                    printf("%u ", message[i]);
                    call HplMsp430Usart.tx(message[i]);
                    while(!call HplMsp430Usart.isTxEmpty());
                }
                printf("\n");
                printfflush();
            }       
        }
        call Resource.release();
    }
}