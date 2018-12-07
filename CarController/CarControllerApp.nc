#define NEW_PRINTF_SEMANTICS
#include "../SmartCar.h"
#include "printf.h"

configuration CarControllerApp{

}
implementation{
    components CarControllerC as App;
    
    components MainC;
    components PrintfC;
    components SerialStartC;

    components LedsC;
    components new TimerMilliC() as Timer0;
    components ActiveMessageC as AM;
    components new AMReceiverC(AM_SMARTCAR);
    //与小车相关的组件
    components CarC as Car;

    App.Boot->MainC;
    App.Leds->LedsC;
    App.Timer0->Timer0;
    //无线通信
    App.Packet->AM;
    App.AMPacket->AM.AMPacket;
    App.AMControl->AM;
    App.Receive->AMReceiverC;
    //和小车的串口通信
    App.Wheel->Car;
    App.Arm->Car;
}