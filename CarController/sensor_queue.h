#include "../SmartCar.h"
#include "../Util.h"
#include "dance.h"
#define S_MAX 4 //队列大小
#define S_T uint16_t //队列中的数据类型
#define BLINK_THRESHOLD 500 //两次光照差值大于500认为是一次闪烁
#define BLINK_CONTROL 16
int8_t blink_sequence_number = 0;
static int8_t sign;
static uint16_t s_result;
static int8_t i_loop;
static int8_t sign_result;
enum DanceControl blink[] = {
    A_UP, A_UP, A_UP, A_UP, A_UP, A_UP, A_UP, A_UP, A_DOWN, A_DOWN, A_DOWN, A_DOWN, A_DOWN, A_DOWN, A_DOWN, A_DOWN
};

static S_T s_array[S_MAX] = {0};
static int8_t s_front = 0;
static int8_t s_rear = -1;
static int8_t s_count = 0;

S_T s_peekQueue(){
    return s_array[s_front];
}

bool s_isQueueEmpty(){
    return s_count == 0;
}

bool s_isQueueFull(){
    return s_count == S_MAX;
}

int8_t s_queueSize(){
    return s_count;
}

//从队首移除元素
//assert: isQueueEmpty() == FALSE
S_T s_removeFromQueue(){
    S_T data = s_array[s_front++];
    if(s_front == S_MAX){
        s_front = 0;
    }
    s_count--;
    return data;
}

//向队列中插入元素到末尾
//当队列满了后,前面的元素会被丢弃
void s_insertQueue(uint16_t value){
    if(s_isQueueFull()){
        s_removeFromQueue();
    }
    if(s_rear == S_MAX-1){
        s_rear=-1;
    }
    s_rear++;
    s_array[s_rear] = value;
    s_count++;
}

//光源是否正在以300ms/次的速度闪烁
int8_t s_isBlinking(){
    if(!s_isQueueFull()){
        return 0;
    }
    sign = s_array[0] < s_array[1] ? -1 : 1;
    for(i_loop = 0; i_loop < S_MAX; i_loop+=2){
        s_result = s_array[i_loop] - s_array[i_loop + 1];
        sign_result = s_result < 0 ? -1 : 1;
        if(sign != sign_result || abs(s_result) < BLINK_THRESHOLD){
            //认为不在闪烁
            return 0;
        }
    }
    return 1;
}