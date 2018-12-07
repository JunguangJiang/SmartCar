#ifndef SMARTCAR_H
#define SMARTCAR_H

enum{
    AM_SMARTCAR=5,//无线通信时的AM标志号，接收方和发送方需要相同
    TIMER_PERIOD_MILLI = 250,//定时器触发时间间隔

    DELTA_SPEED = 100,//速度间隔
    MIN_SPEED = 100,//最小速度
    MAX_SPEED = 700,//最大速度
    MIN_ANGLE = 1800,//最小转动角度
    MAX_ANGLE = 5000,//最大转动角度
    DELTA_ANGLE0 = 800,
    DELTA_ANGLE1 = 800,
    DELTA_ANGLE2 = 800,
    INIT_ANGLE0 = 3000,//初始转动角度
    INIT_ANGLE1 = 3000,
    INIT_ANGLE2 = 3000,

    ROCKER_RADIUS = 4000,//摇杆半径

    CONTROL_UP_DOWN = 0,//S3控制机械臂上升还是下降
    CONTROL_LEFT_RIGHT = 1,//S3控制机械臂左右移动
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