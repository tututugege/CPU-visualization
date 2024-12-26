#pragma once
#include "config.h"

class MEMU {
public:
  Pipeline_IO *EX2MEM;
  Pipeline_IO *MEM2WB;
  void comb();
  void seq();
  void fire();
  void init();
  bool valid;
  Inst_info inst;

private:
  bool valid_1;
  Inst_info inst_1;
};
