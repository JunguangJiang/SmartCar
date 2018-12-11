#include <Timer.h>
#include "../SmartCar.h"
#include "printf.h"
module HoldhandC {
    uses interface Boot;
    uses interface Leds;
    uses interface Timer<TMilli> as Timer0;
    uses interface Packet;
    uses interface AMPacket;
    uses interface SplitControl as AMControl;
    uses interface AMSend;
    uses interface Read<uint16_t> as ReadX;
    uses interface Read<uint16_t> as ReadY;
    uses interface Button;
}

implementation {
    bool radioBusy = FALSE;//无线电信道是否处于发送忙的状态
    message_t radioPkt;//发送的无线数据包
    bool isButtonBusy = TRUE;
    nx_uint16_t lastX;
    nx_uint16_t lastY;
    r_message_t currentPkt;

    event void Boot.booted() {
        call AMControl.start();//打开无线电模块
    }

    event void AMControl.startDone(error_t err) {
        if (err == SUCCESS) {
            currentPkt.S1 = FALSE;
            currentPkt.S2 = FALSE;
            currentPkt.S3 = FALSE;
            currentPkt.S4 = FALSE;
            currentPkt.S5 = FALSE;
            currentPkt.S6 = FALSE;

            call Leds.led1On();
            call Timer0.startPeriodic(TIMER_PERIOD_MILLI);
            call Button.start();
        } else {
            call AMControl.start();
        }
    }

    event void AMControl.stopDone(error_t err) {
    }

    event void Button.startDone(error_t error) {
        if (error == SUCCESS) {
            isButtonBusy = FALSE;
        }
        else {
            call Button.start();
        }
    }

    bool isToSend() {
      return !((currentPkt.x - lastX < 100 || lastX - currentPkt.x  < 100) && (currentPkt.y - lastY < 100 || lastY - currentPkt.y < 100) &&
         currentPkt.S1 == FALSE && currentPkt.S2 == FALSE && currentPkt.S3 == FALSE &&
         currentPkt.S4 == FALSE && currentPkt.S5 == FALSE && currentPkt.S6 == FALSE);
    }

    //发送无线数据包
    //return: 发送成功返回TRUE；否则返回FALSE
    bool sendPacket() {
        if (!radioBusy && isToSend()) {
            r_message_t* rpkt = (r_message_t*)(call Packet.getPayload(&radioPkt, sizeof(r_message_t)));
            printf("%d %d ", currentPkt.x - lastX, currentPkt.y - lastY);
            lastX = currentPkt.x;
            lastY = currentPkt.y;
            call Leds.led2Toggle();
            rpkt->S1 = currentPkt.S1;
            rpkt->S2 = currentPkt.S2;
            rpkt->S3 = currentPkt.S3;
            rpkt->S4 = currentPkt.S4;
            rpkt->S5 = currentPkt.S5;
            rpkt->S6 = currentPkt.S6;
            printf("S1:%d ", currentPkt.S1);
            printf("S2:%d ", currentPkt.S2);
            printf("S3:%d ", currentPkt.S3);
            printf("S4:%d ", currentPkt.S4);
            printf("S5:%d ", currentPkt.S5);
            printf("S6:%d\n", currentPkt.S6);
            printfflush();
            rpkt->x = currentPkt.x;
            rpkt->y = currentPkt.y;
            /* printf("button:%i\n", rpkt->S1);
            printfflush(); */

            if (call AMSend.send(AM_BROADCAST_ADDR, &radioPkt, sizeof(r_message_t)) == SUCCESS) {
                radioBusy = TRUE;
            }
            return TRUE;
        }else{
            return FALSE;
        }
    }

    event void Timer0.fired() {
      call ReadX.read();
      call ReadY.read();
      if (!isButtonBusy) {
          call Button.readS1();
          call Button.readS2();
          call Button.readS3();
          call Button.readS4();
          call Button.readS5();
          call Button.readS6();
      }
      atomic {
          sendPacket();
      }
    }

    event void Button.readS1Done(error_t state) {
        currentPkt.S1 = !state;
    }

    event void Button.readS2Done(error_t state) {
        currentPkt.S4 = !state;
    }

    event void Button.readS3Done(error_t state) {
        currentPkt.S2 = !state;
    }

    event void Button.readS4Done(error_t state) {
        currentPkt.S5 = FALSE;
    }

    event void Button.readS5Done(error_t state) {
        currentPkt.S3 = !state;
    }

    event void Button.readS6Done(error_t state) {
        currentPkt.S6 = !state;
    }

    event void ReadX.readDone(error_t result, uint16_t data) {
        if (result == SUCCESS)
            currentPkt.x = data;
    }

    event void ReadY.readDone(error_t result, uint16_t data) {
        if (result == SUCCESS)
            currentPkt.y = data;
    }

    event void AMSend.sendDone(message_t *msg, error_t err) {
        if (&radioPkt == msg) {//检验已发送的消息和被要求发送的消息是否一致,如果一致，说明确实完成了发送
            radioBusy = FALSE;
        }
    }
}
