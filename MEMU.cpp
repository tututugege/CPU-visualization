#include "./include/MEMU.h"
#include "./include/config.h"
#include <cstdint>

uint32_t load_data(uint32_t address);
void store_data(uint32_t waddr, uint32_t wdata, uint32_t wstrb);

void MEMU::init() { valid_1 = valid = false; }

void MEMU::comb() {

  MEM2WB->inst = inst;
  if (valid) {
    MEM2WB->valid = true;
    if (inst.op == LOAD) {
      uint32_t data = load_data(inst.result);
      int size = inst.func3 & 0b11;
      int offset = inst.result & 0b11;
      uint32_t mask = 0;
      uint32_t sign = 0;

      data = data >> (offset * 8);
      if (size == 0) {
        mask = 0xFF;
        if (data & 0x80)
          sign = 0xFFFFFF00;
      } else if (size == 0b01) {
        mask = 0xFFFF;
        if (data & 0x8000)
          sign = 0xFFFF0000;
      } else {
        mask = 0xFFFFFFFF;
      }

      data = data & mask;

      // 有符号数
      if (!(inst.func3 & 0b100)) {
        data = data | sign;
      }

      MEM2WB->inst.result = data;
    }
  } else {
    MEM2WB->valid = false;
  }
  EX2MEM->ready = !valid || MEM2WB->valid && MEM2WB->ready;
}

void MEMU::fire() {
  if (EX2MEM->valid && EX2MEM->ready) {
    inst_1 = EX2MEM->inst;
  }

  if (EX2MEM->ready) {
    valid_1 = EX2MEM->valid;
  }
}

void MEMU::seq() {
  if (valid) {
    if (inst.op == STORE) {
      int size = inst.func3 & 0b11;
      uint32_t wstrb, wdata;
      wdata = inst.reg_rdata2;
      if (size == 0b00)
        wstrb = 0b1;
      else if (size == 0b01)
        wstrb = 0b11;
      else
        wstrb = 0b1111;

      int offset = inst.result & 0x3;
      wstrb = wstrb << offset;
      wdata = wdata << (offset * 8);

      store_data(inst.result, wdata, wstrb);
    }
  }
  valid = valid_1;
  inst = inst_1;
}
