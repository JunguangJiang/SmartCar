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
    bool busy = FALSE;//无线电信道是否处于发送忙的状态
    message_t pkt;//发送的无线数据包

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
    //type:类型
    //value:数据
    //return: 发送成功返回TRUE；否则返回FALSE
    bool sendPkt(nx_uint8_t type, nx_uint16_t value){
        if(!busy){
            sc_message_t* scpkt = (sc_message_t*)(call Packet.getPayload(&pkt, NULL));
            scpkt->type = type;
            scpkt->value = value;
            if(call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(sc_message_t)) == SUCCESS){
                busy = TRUE;
            }
            return TRUE;
        }else{
            return FALSE;
        }
    }

    event void Timer0.fired(){
        //需要定时触发的命令或者信号写在这里
        //作为测试，定时发送无线数据包
        sendPkt(0, 1);
    }

    event void AMSend.sendDone(message_t *msg, error_t err){
        if(&pkt == msg){//检验已发送的消息和被要求发送的消息是否一致
            busy = FALSE;
        }
    }
}