#include <Timer.h>
#include "../SmartCar.h"
#include "../Util.h"
#include "printf.h"

module CarControllerC{
    uses interface Boot;
    uses interface Leds;
    uses interface Timer<TMilli> as Timer0;
    uses interface Packet;
    uses interface AMPacket;
    uses interface SplitControl as AMControl;
    uses interface Receive;
    uses interface Wheel;
    uses interface Arm;
}
implementation{
    int32_t speed=0;//小车速度
    int16_t vx,vy;//x轴和y轴的速度
    int8_t controlMode = CONTROL_UP_DOWN;//S3的控制模式

    void processRadioMsg(r_message_t* radioMsg){//处理无线信息
        if(radioMsg->S1){
            speed = 0;
            call Wheel.stop();
            printf("stop\n");
        }
        if(radioMsg->S2){
            speed += DELTA_SPEED;
            speed = min(speed, MAX_SPEED);
            printf("speed=%i\n", speed);
        }
        if(radioMsg->S3){
            if(controlMode == CONTROL_UP_DOWN){
                controlMode = CONTROL_LEFT_RIGHT;
            }else{
                controlMode = CONTROL_UP_DOWN;
            }
            printf("change control mode:%i\n", controlMode);
        }
        if(radioMsg->S4){
            printf("home\n");
            call Arm.home();
        }
        if(radioMsg->S5){
            if(controlMode == CONTROL_UP_DOWN){
                printf("come down\n");
                call Arm.comeDown();
            }else{
                printf("turn left\n");
                call Arm.turnLeft();
            }
        }
        if(radioMsg->S6){
            if(controlMode == CONTROL_UP_DOWN){
                printf("raise up\n");
                call Arm.raiseUp();
            }else{
                printf("turn right\n");
                call Arm.turnRight();
            }
        }

        if(speed > 0){
            vx = (radioMsg->x * speed / ROCKER_RADIUS);
            vy = (radioMsg->y * speed / ROCKER_RADIUS);
            if(vx>=0){
                call Wheel.turnRight(vx);
                printf("turn right %i\n", vx);
            }else{
                call Wheel.turnLeft(-vx);
                printf("turn left %i\n", -vx);
            }
            if(vy>=0){
                call Wheel.goForward(vy);
                printf("go forward %i\n", vy);
            }else{
                call Wheel.goBackward(-vy);
                printf("go backward %i\n", -vy);
            }
        }
        printfflush();
    }

    event void Boot.booted(){
        call AMControl.start();//打开无线电模块
        speed = 0;
    }

    event void AMControl.startDone(error_t err){
        if(err == SUCCESS){
            call Timer0.startPeriodic(TIMER_PERIOD_MILLI);
        }else{
            call AMControl.start();
        }
    }

    event void AMControl.stopDone(error_t err){
    }

    r_message_t r_message;
    event void Timer0.fired(){
        r_message.S1 = FALSE;
        r_message.S2 = FALSE;
        r_message.S3 = TRUE;
        r_message.S4 = TRUE;
        r_message.S5 = TRUE;
        r_message.S6 = FALSE;
        r_message.x = 3000;
        r_message.y = 2000;
        processRadioMsg(&r_message);
    }

    event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len){
        if(len == sizeof(r_message_t)){
            r_message_t* radioMsg = (r_message_t*)payload;
            //根据radioMsg中的内容对小车进行操作
            processRadioMsg(radioMsg);
        }
        return msg;
    }
}