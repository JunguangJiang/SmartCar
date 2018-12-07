interface Button {
  command void start();
  event void startDone(error_t error);
  command void readS1();
  event void readS1Done(error_t error);
  command void readS2();
  event void readS2Done(error_t error);
  command void readS3();
  event void readS3Done(error_t error);
  command void readS4();
  event void readS4Done(error_t error);
  command void readS5();
  event void readS5Done(error_t error);
  command void readS6();
  event void readS6Done(error_t error);
}
