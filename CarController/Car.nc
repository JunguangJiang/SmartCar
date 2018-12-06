interface Car{
    command error_t goForward(uint16_t value);//前进
    command error_t goBackward(uint16_t value);//后退
    command error_t turnLeft(uint16_t value);//左转
    command error_t turnRight(uint16_t value);//右转
    command error_t stop();//停止
}