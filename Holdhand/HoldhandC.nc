#include <Timer.h>
#include "../SmartCar.h"
module HoldhandC{
    uses interface Boot;
    uses interface Leds;
    uses interface Timer<TMilli> as Timer0;
    uses interface Packet;
    uses interface AMPacket;
    uses interface SplitControl as AMControl;
    uses interface AMSend;
}
implementation{
    bool radioBusy = FALSE;//无线电信道是否处于发送忙的状态
    message_t radioPkt;//发送的无线数据包
    uint8_t counter=0;

    event void Boot.booted(){
        call AMControl.start();//打开无线电模块
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

    //发送无线数据包
    //return: 发送成功返回TRUE；否则返回FALSE
    bool sendPacket(){
        if(!radioBusy){
            r_message_t* rpkt = (r_message_t*)(call Packet.getPayload(&radioPkt, NULL));
            //To Do:将按钮和手柄的状态写入到rpkt中
            rpkt->button = counter&7;//用计数器做测试
            counter++;
            printf("button:%i\n", rpkt->button);
            printfflush();

            if(call AMSend.send(AM_BROADCAST_ADDR, &radioPkt, sizeof(r_message_t)) == SUCCESS){
                radioBusy = TRUE;
            }
            return TRUE;
        }else{
            return FALSE;
        }
    }

    event void Timer0.fired(){
        //需要定时触发的命令或者信号写在这里
        //作为测试，定时发送无线数据包
        sendPacket();
    }

    event void AMSend.sendDone(message_t *msg, error_t err){
        if(&radioPkt == msg){//检验已发送的消息和被要求发送的消息是否一致,如果一致，说明确实完成了发送
            radioBusy = FALSE;
        }
    }
}