#include "./include/RISCV.h"
#include "./include/WBU.h"
#include "./include/config.h"
#include "./include/core.h"

extern RV_Core core;

void WBU::comb() {
  MEM2WB->ready = true;
  if (valid) {
    if (inst.dest_en) {
      core.reg_file[inst.dest_areg] = inst.result;
    }
  }
}

void WBU::fire() {
  if (MEM2WB->valid && MEM2WB->ready) {
    inst_1 = MEM2WB->inst;
  }

  if (MEM2WB->ready) {
    valid_1 = MEM2WB->valid;
  }
}

void WBU::seq() {

  valid = valid_1;
  inst = inst_1;
}

void WBU::init() {
  valid = false;
  valid_1 = false;
}
