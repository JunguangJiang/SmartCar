#ifndef DANCE_H
#define DANCE_H
#define LED_CONTROL_LOOP 10
#define DANCE_CONTROL_LOOP 11
uint8_t led_sequence_number = 0; 
uint8_t led_control[] = {0, 1, 2, 4, 0, 7, 0, 6, 5, 3};
uint8_t dance_sequence_number = 0;
enum DanceControl{
    W_FORWARD, W_BACKWORD, W_LEFT, W_RIGHT, W_STOP,
    A_UP, A_DOWN, A_LEFT, A_RIGHT, A_HOME
};
enum DanceControl dance_control[] = {
    W_FORWARD, W_LEFT, W_BACKWORD, W_RIGHT, A_UP, A_LEFT, W_LEFT, A_RIGHT, A_DOWN, W_STOP, A_HOME 
};
#endif
