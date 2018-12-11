#include "../SmartCar.h"
#define MAX 3 //队列大小
#define T cc_message_t //队列中的数据类型

static T array[MAX];
static int8_t front = 0;
static int8_t rear = -1;
static int8_t count = 0;

T peekQueue(){
    return array[front];
}

bool isQueueEmpty(){
    return count == 0;
}

bool isQueueFull(){
    return count == MAX;
}

int8_t queueSize(){
    return count;
}

//从队首移除元素
//assert: isQueueEmpty() == FALSE
T removeFromQueue(){
    T data = array[front++];
    if(front == MAX){
        front = 0;
    }
    count--;
    return data;
}

//向队列中插入元素到末尾
//当队列满了后,前面的元素会被丢弃
void insertQueue(uint8_t type, uint16_t value){
    if(isQueueFull()){
        removeFromQueue();
    }
    if(rear == MAX-1){
        rear=-1;
    }
    rear++;
    array[rear].type =type;
    array[rear].value = value;
    count++;
}