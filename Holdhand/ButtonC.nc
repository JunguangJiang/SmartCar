module ButtonC {
  uses interface HplMsp430GeneralIO as PortA;
  uses interface HplMsp430GeneralIO as PortB;
  uses interface HplMsp430GeneralIO as PortC;
  uses interface HplMsp430GeneralIO as PortD;
  uses interface HplMsp430GeneralIO as PortE;
  uses interface HplMsp430GeneralIO as PortF;
  provides interface Button;
}

implementation {

  command void Button.start() {
    call PortA.clr();
    call PortB.clr();
    call PortC.clr();
    call PortD.clr();
    call PortE.clr();
    call PortF.clr();
    call PortA.makeInput();
    call PortB.makeInput();
    call PortC.makeInput();
    call PortD.makeInput();
    call PortE.makeInput();
    call PortF.makeInput();
    signal Button.startDone(SUCCESS);
  }

  default event void Button.startDone(error_t error) {
    if (error == SUCCESS) {
    }
    else {
      call Button.start();
    }
  }

  command void Button.readS1() {
    signal Button.readS1Done(call PortA.get());
  }

  default event void Button.readS1Done(error_t error) {
  }

  command void Button.readS2() {
    signal Button.readS2Done(call PortB.get());
  }

  default event void Button.readS2Done(error_t error) {
  }

  command void Button.readS3() {
    signal Button.readS3Done(call PortC.get());
  }

  default event void Button.readS3Done(error_t error) {
  }

  command void Button.readS4() {
    signal Button.readS4Done(call PortD.get());
  }

  default event void Button.readS4Done(error_t error) {
  }

  command void Button.readS5() {
    signal Button.readS5Done(call PortE.get());
  }

  default event void Button.readS5Done(error_t error) {
  }

  command void Button.readS6() {
    signal Button.readS6Done(call PortF.get());
  }

  default event void Button.readS6Done(error_t error) {
  }
}
