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
    int16_t vx,vy;//x轴和y轴的速度

    void processRadioMsg(r_message_t* radioMsg){//处理无线信息
        if(radioMsg->x < XMIN){//小车向前
            vx = XMIN - radioMsg->x;
            printf("Car goes forward %i\n", vx);
            call Wheel.goForward(vx);
            call Leds.set(6);
        }else if(radioMsg->x > XMAX){//小车向后
            vx = radioMsg->x - XMAX;
            printf("Car goes backward %i\n", vx);
            call Wheel.goBackward(vx);
            call Leds.set(6);
        }else if(radioMsg->y < YMIN){//小车向左
            vy = YMIN - radioMsg->y;
            printf("Car turns left %i\n", vy);
            call Wheel.turnLeft(vy);
            call Leds.set(7);
        }else if(radioMsg->y > YMAX){
            vy = radioMsg->y - YMAX;
            printf("Car turns right %i\n", vy);
            call Wheel.turnRight(vy);
            call Leds.set(7);
        }else{
            printf("Car stops\n");
            call Wheel.stop();
            call Leds.set(0);
        }
        if(radioMsg->S1){//按下停止按钮
            printf("Car stops\n");
            call Wheel.stop();
            call Leds.set(0);
        }
        if(radioMsg->S2){//机械臂向左
            printf("Arm turns left\n");
            call Arm.turnLeft();
            call Leds.set(1);
        }
        if(radioMsg->S3){//机械臂向右
            printf("Arm turns right\n");
            call Arm.turnRight();
            call Leds.set(2);
        }
        if(radioMsg->S4){//按下机械臂归位按钮
            printf("Arm returns home\n");
            call Arm.home();
            call Leds.set(3);
        }
        if(radioMsg->S5){//按下机械臂下降按钮
            printf("Arm comes down\n");
            call Arm.comeDown();
            call Leds.set(4);
        }
        if(radioMsg->S6){//按下机械臂上升按钮
            printf("Arm raises up\n");
            call Arm.raiseUp();
            call Leds.set(5);
        }
        printfflush();
    }

    event void Boot.booted(){
        call AMControl.start();//打开无线电模块
    }

    event void AMControl.startDone(error_t err){
        if(err == SUCCESS){
            call Timer0.startPeriodic(TIMER_PERIOD_MILLI_TEST);
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
        r_message.S4 = FALSE;
        r_message.S5 = TRUE;
        r_message.S6 = FALSE;
        r_message.x = 2000;
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