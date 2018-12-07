#include <Msp430Adc12.h>

configuration JoyStickC {
  provides interface Read<uint16_t> as ReadX;
  provides interface Read<uint16_t> as ReadY;
}

implementation {
  components new AdcReadClientC() as AdcReadClientX;
  components new AdcReadClientC() as AdcReadClientY;
  ReadX = AdcReadClientX.Read;
  ReadY = AdcReadClientY.Read;
  components JoyStickP;
  AdcReadClientX.AdcConfigure -> JoyStickP.AdcConfigureX;
  AdcReadClientY.AdcConfigure -> JoyStickP.AdcConfigureY;
}
