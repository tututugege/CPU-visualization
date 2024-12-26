#pragma once
#include "config.h"
#include <cstdint>

class IFU {
public:
  void init();
  void comb();
  void fire();
  void seq();

  bool br_taken;
  uint32_t br_pc;
  Pipeline_IO *IF2ID;
  uint32_t pc;

private:
  uint32_t pc_1;
};
