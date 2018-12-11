#ifndef SMARTCAR_H
#define SMARTCAR_H

enum{
    AM_SMARTCAR=5,//无线通信时的AM标志号，接收方和发送方需要相同
    TIMER_PERIOD_MILLI = 250,//定时器触发时间间隔
    TIMER_PERIOD_MILLI_TEST = 2500,//小车控制中测试用，定时器触发时间间隔

    MIN_SPEED = 0,//最小速度
    MAX_SPEED = 1600,//最大速度
    
    MIN_ANGLE = 700,//最小转动角度
    MAX_ANGLE = 5000,//最大转动角度
    DELTA_ANGLE0 = 400,
    DELTA_ANGLE1 = 400,
    DELTA_ANGLE2 = 400,
    INIT_ANGLE0 = 3200,//初始转动角度
    INIT_ANGLE1 = 2600,
    INIT_ANGLE2 = 3400,

    ROCKER_RANGE = 4096,//摇杆半径
    THRESHOLD = 450,
    XMIN = ROCKER_RANGE/2 - THRESHOLD,
    XMAX = ROCKER_RANGE/2 + THRESHOLD,
    YMIN = ROCKER_RANGE/2 - THRESHOLD,
    YMAX = ROCKER_RANGE/2 + THRESHOLD,
};

typedef struct CarControlMsg{//小车串口通信数据
    uint8_t type;//类型
    uint16_t value;//数据
} cc_message_t;

typedef nx_struct RadioMsg{//小车和手柄之间通信数据
    nx_bool S1;//按下S1为TRUE
    nx_bool S2;
    nx_bool S3;
    nx_bool S4;
    nx_bool S5;
    nx_bool S6;
    nx_int16_t x;
    nx_int16_t y;
} r_message_t;
#endif
