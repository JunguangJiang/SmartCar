interface Arm{//机械臂
    command error_t raiseUp();//上升
    command error_t comeDown();//下降
    command error_t turnLeft();//左转
    command error_t turnRight();//右转
    command error_t home();//归位
}