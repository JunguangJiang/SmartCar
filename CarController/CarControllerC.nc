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
        if(radioMsg->x < XMIN){//小车向左
            vx = XMIN - radioMsg->x;
            printf("Car turn left %i\n", vx);
            call Wheel.turnLeft(vx);
            call Leds.set(1);
        }else if(radioMsg->x > XMAX){//小车向右
            vx = radioMsg->x - XMAX;
            printf("Car turn right %i\n", vx);
            call Wheel.turnRight(vx);
            call Leds.set(2);
        }else if(radioMsg->y < YMIN){//小车向前
            vy = YMIN - radioMsg->y;
            printf("Car go forward %i\n", vy);
            call Wheel.goForward(vy);
            call Leds.set(3);
        }else if(radioMsg->y > YMAX){//小车向后
            vy = radioMsg->y - YMAX;
            printf("Car go backward %i\n", vy);
            call Wheel.goBackward(vy);
            call Leds.set(4);
        }else{
            printf("Car stops\n");
            call Wheel.stop();
            call Leds.set(0);
        }
        if(radioMsg->S2){//机械臂向左
            printf("Arm turns left\n");
            call Arm.turnLeft();
            call Leds.set(5);
        }
        if(radioMsg->S3){//机械臂向右
            printf("Arm turns right\n");
            call Arm.turnRight();
            call Leds.set(5);
        }
        if(radioMsg->S4){//按下机械臂上升按钮
            printf("Arm raises up\n");
            call Arm.raiseUp();
            call Leds.set(6);
        }
        if(radioMsg->S6){//按下机械臂下降按钮
            printf("Arm comes down\n");
            call Arm.comeDown();
            call Leds.set(6);
        }
        if(radioMsg->S1){//按下机械臂归位按钮
            printf("Arm returns home\n");
            call Arm.home();
            call Leds.set(7);
        }
        printfflush();
    }

    void initDanceShow(){//一开始的编舞表演
        //TO DO
        //以下步骤仅供参考
        //先将编舞动作存到一个数组中
        //然后每隔400ms从数组中取出一个动作并执行。注意：机械臂归位动作完成后需要间隔800ms。
        //执行一个动作的例子：
        //call Arm.comeDown();//让机械臂下降
        //call Leds.set(6);//点亮小灯助兴

        //定时器周期触发 call Timer0.startPeriodic(400);
        //定时器只触发1次 call Timer0.startOneShot(400);
    }

    event void Timer0.fired(){
    }

    event void Boot.booted(){
        call AMControl.start();//打开无线电模块
    }

    event void AMControl.startDone(error_t err){
        if(err == SUCCESS){
            initDanceShow();
        }else{
            call AMControl.start();
        }
    }

    event void AMControl.stopDone(error_t err){
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