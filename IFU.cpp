#include "./include/IFU.h"
#include "./include/config.h"
#include <cstdint>
#include <cstdlib>

uint32_t load_inst(uint32_t);

void IFU::init() {
  pc = 0x80000000;
  pc_1 = 0x80000000;
}

extern int sim_time;
void IFU::comb() {
  IF2ID->inst.instruction = load_inst(pc);
  IF2ID->inst.inst_idx = sim_time;
  IF2ID->inst.color = rand();
  IF2ID->inst.pc = pc;
  IF2ID->inst.time = 1;
  IF2ID->inst.stage[0] = 1;

  if (br_taken) {
    IF2ID->valid = false;
    pc_1 = br_pc;
  } else {
    IF2ID->valid = true;
  }
}

void IFU::fire() {
  if (IF2ID->ready && IF2ID->valid) {
    pc_1 = pc + 4;
  } else if (!br_taken) {
    pc_1 = pc;
  }
}

void IFU::seq() { pc = pc_1; }
