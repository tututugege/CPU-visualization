#pragma once
#include "config.h"
#include <cstdint>

typedef struct ALU_op {
  Inst_op op;
  uint32_t func3;
  bool func7_5;
  bool src2_is_imm;
} ALU_op;

class EXU {
public:
  void init();
  void comb();
  void fire();
  void seq();
  Pipeline_IO *ID2EX;
  Pipeline_IO *EX2MEM;
  uint32_t br_pc;
  bool br_taken;

  bool MEM2EX_src1_bypass;
  bool MEM2EX_src2_bypass;
  bool WB2EX_src1_bypass;
  bool WB2EX_src2_bypass;

  uint32_t MEM2EX_data_bypass;
  uint32_t WB2EX_data_bypass;

  bool valid;
  Inst_info inst;

private:
  bool valid_1;
  Inst_info inst_1;
};
