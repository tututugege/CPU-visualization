#pragma once
#include "config.h"

class WBU {
public:
  void init();
  void seq();
  void fire();
  void comb();

  Pipeline_IO *MEM2WB;
  Pipeline_IO *WBout;

  bool valid;
  Inst_info inst;

private:
  bool valid_1;
  Inst_info inst_1;
};
