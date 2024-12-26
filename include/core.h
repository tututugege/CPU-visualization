#include "OoO.h"
#include "pipeline.h"
#include "single.h"
#include <cstdint>

enum Core_Type { PIPELINE, SINGLE_CYCLE, OUT_OF_ORDER };

class RV_Core {
public:
  void init();
  void cycle(int num);
  void comb();
  void seq();
  uint32_t reg_file[32];
  Core_Type type = PIPELINE;
  Pipeline_Top pip;
  Single_Top single;
  OutOfOrder ooo;
};
