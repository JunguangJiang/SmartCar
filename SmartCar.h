#ifndef SMARTCAR_H
#define SMARTCAR_H

enum{
    AM_SMARTCAR=5,//无线通信时的AM标志号，接收方和发送方需要相同
    TIMER_PERIOD_MILLI = 250;//定时器触发时间间隔
};

typedef nx_struct SmartCarMsg{//小车和手柄之间的通信数据
    nx_uint8_t type;//类型
    nx_uint16_t value;//数据
} sc_message_t;
#endif