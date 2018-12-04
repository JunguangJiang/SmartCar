#include "../SmartCar.h"
configuration HoldhandAppC{

}
implementation{
    components HoldhandC as App;

    components MainC;
    components LedsC;
    components new TimerMilliC() as Timer0;
    components ActiveMessageC as AM;
    components new AMSenderC(AM_SMARTCAR);
    //与控制手柄相关的组件
    //TO DO...

    App.Boot->MainC;
    App.LedsC->LedsC;
    App.Timer0->Timer0;
    //无线通信
    App.Packet->AM;
    App.AMPacket->AM.AMPacket;
    App.AMControl->AM;
    App.AMSend->AMSenderC;
    //和控制手柄的串口通信
    //TO DO...
}