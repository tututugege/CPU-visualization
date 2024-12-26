#include "./include/config.h"
#include "./include/IDU.h"
#include "./include/RISCV.h"
#include "./include/core.h"

extern RV_Core core;
Inst_info decode(uint32_t);

void IDU::init() {
  valid = false;
  valid_1 = false;
}

void IDU::comb() {
  ID2EX->valid = valid && !br_taken;
  ID2EX->inst = decode(inst.instruction);
  ID2EX->inst.pc = inst.pc;
  ID2EX->inst.time = inst.time;
  ID2EX->inst.color = inst.color;
  ID2EX->inst.inst_idx = inst.inst_idx;
  for (int i = 0; i < 6; i++) {
    ID2EX->inst.stage[i] = inst.stage[i];
  }

  ID2EX->inst.reg_rdata1 = core.reg_file[ID2EX->inst.src1_areg];
  ID2EX->inst.reg_rdata2 = core.reg_file[ID2EX->inst.src2_areg];
  IF2ID->ready = !valid || ID2EX->valid && ID2EX->ready;
}

void IDU::fire() {
  if (IF2ID->valid && IF2ID->ready) {
    inst_1 = IF2ID->inst;
  }

  if (IF2ID->ready) {
    valid_1 = IF2ID->valid;
  } else if (br_taken) {
    valid_1 = false;
  }
}

void IDU::seq() {
  inst = inst_1;
  valid = valid_1;
}
