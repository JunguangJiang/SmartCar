#define NEW_PRINTF_SEMANTICS
#include "../SmartCar.h"
#include "printf.h"

configuration HoldhandApp{

}
implementation{
    components HoldhandC as App;
    components MainC;
    
    //与打印结果到终端相关
    components PrintfC;
    components SerialStartC;

    components LedsC;
    components new TimerMilliC() as Timer0;

    //与无线通信相关
    components ActiveMessageC as AM;
    components new AMSenderC(AM_SMARTCAR);
    
    //与控制手柄相关的组件
    //TO DO...

    App.Boot->MainC;
    App.Leds->LedsC;
    App.Timer0->Timer0;
    
    //无线通信
    App.Packet->AM;
    App.AMPacket->AM.AMPacket;
    App.AMControl->AM;
    App.AMSend->AMSenderC;
    
    //和控制手柄的串口通信
    //TO DO...
}