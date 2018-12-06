#include <Timer.h>
#include "../SmartCar.h"
#include "printf.h"

module CarControllerC{
    uses interface Boot;
    uses interface Leds;
    uses interface Timer<TMilli> as Timer0;
    uses interface Packet;
    uses interface AMPacket;
    uses interface SplitControl as AMControl;
    uses interface Receive;
    //uses interface Car;
}
implementation{
    message_t pkt;//接受到的数据包
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

    event void Timer0.fired(){
    }

    event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len){
        if(len == sizeof(r_message_t)){
            r_message_t* rmpkt = (r_message_t*)payload;
            //根据rmpkt中的内容对小车进行操作
            call Leds.set(rmpkt->S1);
            printf("button:%i\n", rmpkt->S1);
            printfflush();
        }
        return msg;
    }
}