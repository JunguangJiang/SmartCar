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
    components new TimerMilliC() as Timer1;
    components new TimerMilliC() as Timer2;
    components new TimerMilliC() as Timer3;
    components new TimerMilliC() as Timer4;
    components ActiveMessageC as AM;
    components new AMReceiverC(AM_SMARTCAR);
    //与小车相关的组件
    components CarC as Car;

    components new SensirionSht11C(); //温湿度传感器
    components new HamamatsuS1087ParC(); //光照传感器

    App.Boot->MainC;
    App.Leds->LedsC;
    App.Timer0->Timer0;
    App.Timer1->Timer1;
    App.Timer2->Timer2;
    App.Timer3->Timer3;
    App.Timer4->Timer4;
    //无线通信
    App.Packet->AM;
    App.AMPacket->AM.AMPacket;
    App.AMControl->AM;
    App.Receive->AMReceiverC;
    //和小车的串口通信
    App.Wheel->Car;
    App.Arm->Car;
    //传感器
    App.Temperature -> SensirionSht11C.Temperature;
    App.Humidity -> SensirionSht11C.Humidity;
    App.Light -> HamamatsuS1087ParC;
}