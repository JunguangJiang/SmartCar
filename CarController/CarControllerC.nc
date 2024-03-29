#include <Timer.h>
#include "../SmartCar.h"
#include "../Util.h"
#include "printf.h"
#include "dance.h"
#include "sensor_queue.h"

module CarControllerC{
    uses interface Boot;
    uses interface Leds;
    uses interface Timer<TMilli> as Timer0;
    uses interface Timer<TMilli> as Timer1;
    uses interface Timer<TMilli> as Timer2;
    uses interface Timer<TMilli> as Timer3;
    uses interface Timer<TMilli> as Timer4;
    uses interface Packet;
    uses interface AMPacket;
    uses interface SplitControl as AMControl;
    uses interface Receive;
    uses interface Wheel;
    uses interface Arm;
    uses interface Read<uint16_t> as Temperature;
    uses interface Read<uint16_t> as Humidity;
    uses interface Read<uint16_t> as Light;
}
implementation{
    int16_t vx,vy;//x轴和y轴的速度
    
    #define LIGHT_SAMPLING_FREQUENCY 300 //光照传感器采样间隔(单位:毫秒)
    #define HUMIDITY_SAMPLING_FREQUENCY 200 //温湿度传感器采样间隔(单位:毫秒)
    #define HUMIDITY_INITIAL_TIME 20 //先测量20次湿度取平均值作为环境的初始湿度
    #define LIGHT_THRESHOLD 500 //驱动小车前进的光照强度临界值为500
    #define HUMIDITY_THRESHOLD_RATE 2 //驱动小车后退的湿度临界值为初始湿度的2倍
    uint16_t temperature = 0; //当前温度
    uint16_t humidity = 0; //当前湿度
    uint16_t light = 0; //当前光强
    uint16_t last_light = 0; //上次传感器取样得到的光强
    uint16_t last_humidity = 0; //上次传感器取样得到的湿度
    uint16_t initial_humidity = 0; //环境湿度

    uint16_t speed = 500; //编舞时小车前进和后退的速度
    uint16_t angle_speed = 3900; //编舞时小车左转和右转的角度
    uint8_t h_measure_time = 0; //测量湿度的次数，用于测量初始湿度

    uint8_t is_dancing = 1; //是否正在编舞
    
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
        call Timer0.startPeriodic(1000);
        call Timer1.startPeriodic(500);
        call Timer4.startOneShot(1000 * DANCE_CONTROL_LOOP);
    }
    
    void actByControl(enum DanceControl c){
        switch(c){
            case W_FORWARD:
                call Wheel.goForward(speed);
                break;
            case W_BACKWORD:
                call Wheel.goBackward(speed);
                break;
            case W_LEFT:
                call Wheel.turnLeft(angle_speed);
                break;
            case W_RIGHT:
                call Wheel.turnRight(angle_speed);
                break;
            case W_STOP:
                call Wheel.stop();
                break;
            case A_DOWN:
                call Arm.comeDown();
                break;
            case A_UP:
                call Arm.raiseUp();
                break;
            case A_LEFT:
                call Arm.turnLeft();
                break;
            case A_RIGHT:
                call Arm.turnRight();
                break;
            case A_HOME:
                call Arm.home();
                break;
        }
    }

    void moveByLightAndHumidity(){//根据光照改变小车的运动
        if(s_isBlinking()){//外部光源正在以当前光照传感器采样频率闪烁
            if(blink_sequence_number < BLINK_CONTROL){
                actByControl(blink[blink_sequence_number]);
                blink_sequence_number++;
            }
            else{
                blink_sequence_number = 0;
            }
        }
        else if(light > LIGHT_THRESHOLD){//强光驱动前进
            call Wheel.goForward(speed);
            // call Leds.led2Toggle();
            last_light = light;
        }
        else if(last_light > LIGHT_THRESHOLD){//光源离开后停止前进
            call Wheel.stop();
            last_light = light;
        }
        else if(humidity > HUMIDITY_THRESHOLD_RATE * initial_humidity){//湿度较大时后退
            call Wheel.goBackward(speed);
            last_humidity = humidity;
        }
        else if(last_humidity > HUMIDITY_THRESHOLD_RATE * initial_humidity){//湿度降低后停止后退
            call Wheel.stop();
            last_humidity = humidity;
        }
    }

    event void Timer0.fired(){//控制编舞动作
        if(dance_sequence_number < DANCE_CONTROL_LOOP){
            actByControl(dance_control[dance_sequence_number]);
            dance_sequence_number++;
        }
    }

    event void Timer1.fired(){//控制编舞过程中LED灯的亮灭
        if(is_dancing){
            call Leds.set(led_control[led_sequence_number]);
            if(led_sequence_number == LED_CONTROL_LOOP - 1){
                led_sequence_number = 0;
            }
            else{
                led_sequence_number++;
            }
        }
    }

    event void Timer2.fired(){ //定时检测光照强度
        call Light.read(); //读取光照值
        moveByLightAndHumidity();
    }

    event void Timer3.fired(){
        call Temperature.read(); //读取温度值
        call Humidity.read(); //读取湿度值
    }

    event void Timer4.fired(){
        call Timer0.stop();
        call Timer1.stop();
        is_dancing = 0;
        call Leds.set(0);
        call AMControl.start();//打开无线电模块
        call Timer2.startPeriodic(LIGHT_SAMPLING_FREQUENCY); //定时读取光照传感器数据
        call Timer3.startPeriodic(HUMIDITY_SAMPLING_FREQUENCY); //定时读取温湿度传感器数据
    }

    event void Temperature.readDone(error_t result, uint16_t value) {
        printf("Temperature origin val=%u\n", value);
        if (result == SUCCESS){
            value = -40.00 + 0.01*value; //转换成摄氏度
            temperature = value;
        }
        else{
            temperature = 0xffff;
        }
        printf("Temperature=%u\n", temperature);
    }

    event void Humidity.readDone(error_t result, uint16_t value) {
        printf("Humidity origin value=%u\n", value);
        if (result == SUCCESS){
            humidity = -4 + 0.0405*value + (-0.0000028)*(value*value); //转换成相对湿度(百分比)
            //humidity = (temperature-25)*(0.01+0.00008*value)+humidity; //转换成带温度补偿的湿度值
            if(h_measure_time < HUMIDITY_INITIAL_TIME){
                h_measure_time++;
                initial_humidity += humidity;
            }
            else if(h_measure_time == HUMIDITY_INITIAL_TIME){
                initial_humidity /= HUMIDITY_INITIAL_TIME;
                h_measure_time++;
            }
        }
        else
            humidity = 0xffff;
        printf("Humidity=%u\n", humidity);
    }

    event void Light.readDone(error_t result, uint16_t value) {
        if (result == SUCCESS){ 
            light = value;
            s_insertQueue(value);
        }
        else
            light = 0xffff;
        printf("Light=%u\n", light);
    }

    event void Boot.booted(){
        initDanceShow();//开始编舞表演
    }

    event void AMControl.startDone(error_t err){
        if(err == SUCCESS){//打开无线电模块后，
            call Timer1.startPeriodic(TIMER_PERIOD_MILLI);//才开始进行光照检测
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
