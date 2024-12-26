#pragma once
#include "config.h"
#include <cstdint>

class IDU {
public:
  void init();
  void comb();
  void fire();
  void seq();

  Pipeline_IO *IF2ID;
  Pipeline_IO *ID2EX;
  bool br_taken;
  bool valid;
  bool stall;
  Inst_info inst;

private:
  Inst_info inst_1;
  bool valid_1;
  uint32_t prf[ARF_NUM];
  uint32_t prf_1[ARF_NUM];
};
