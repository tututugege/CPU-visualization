#include "./include/EXU.h"
#include <cassert>
#include "./include/config.h"
#include <cstdint>

#define SUB 0b000
#define SLL 0b001
#define SLT 0b010
#define SLTU 0b011
#define XOR 0b100
#define SRL 0b101
#define OR 0b110
#define AND 0b111

#define BEQ 0b000
#define BNE 0b001
#define BLT 0b100
#define BGE 0b101
#define BLTU 0b110
#define BGEU 0b111

void alu(Inst_info *inst);
void bru(Inst_info *inst);
void operand_mux(Inst_info *inst, uint32_t &operand1, uint32_t &operand2) {
  if (inst->op == AUIPC || inst->op == JAL || inst->op == JALR)
    operand1 = inst->pc;
  else if (inst->op == LUI)
    operand1 = 0;
  else
    operand1 = inst->reg_rdata1;

  if (inst->src2_is_imm) {
    operand2 = inst->imm;
  } else if (inst->op == JALR || inst->op == JAL) {
    operand2 = 4;
  } else {
    operand2 = inst->reg_rdata2;
  }
}

void EXU::init() { valid = valid_1 = false; }

void EXU::comb() {
  if (MEM2EX_src1_bypass)
    inst.reg_rdata1 = MEM2EX_data_bypass;
  else if (WB2EX_src1_bypass)
    inst.reg_rdata1 = WB2EX_data_bypass;

  if (MEM2EX_src2_bypass)
    inst.reg_rdata2 = MEM2EX_data_bypass;
  else if (WB2EX_src2_bypass)
    inst.reg_rdata2 = WB2EX_data_bypass;

  alu(&inst);
  bru(&inst);
  EX2MEM->inst = inst;
  br_taken = valid && inst.br_taken;
  br_pc = inst.pc_next;
  if (valid) {
    EX2MEM->valid = true;
  } else {
    EX2MEM->valid = false;
  }

  ID2EX->ready = !valid || EX2MEM->valid && EX2MEM->ready;
}

void EXU::fire() {
  if (ID2EX->valid && ID2EX->ready) {
    inst_1 = ID2EX->inst;
  }

  if (ID2EX->ready) {
    valid_1 = ID2EX->valid;
  } else if (br_taken) {
    valid_1 = false;
  }
}

void EXU::seq() {
  inst = inst_1;
  valid = valid_1;
}

void alu(Inst_info *inst) {
  uint32_t result, src1, src2;
  operand_mux(inst, src1, src2);

  switch (inst->op) {
  case ADD: {
    switch (inst->func3) {
    case SUB:
      if (inst->func7_5 && !inst->src2_is_imm)
        result = src1 - src2;
      else
        result = src1 + src2;
      break;
    case SLL:
      result = src1 << src2;
      break;
    case SLT:
      result = ((signed)src1 < (signed)src2);
      break;
    case SLTU:
      result = ((unsigned)src1 < (unsigned)src2);
      break;
    case XOR:
      result = (src1 ^ src2);
      break;
    case SRL:
      if (inst->func7_5)
        result = ((signed)src1 >> src2);
      else
        result = ((unsigned)src1 >> src2);
      break;
    case OR:
      result = (src1 | src2);
      break;
    case AND:
      result = (src1 & src2);
      break;
    default:
      assert(0);
    }
    break;
  }
  case BR:
    switch (inst->func3) {
    case BEQ:
      result = (src1 == src2);
      break;
    case BNE:
      result = (src1 != src2);
      break;
    case BGE:
      result = ((signed)src1 >= (signed)src2);
      break;
    case BLT:
      result = ((signed)src1 < (signed)src2);
      break;
    case BGEU:
      result = ((unsigned)src1 >= (unsigned)src2);
      break;
    case BLTU:
      result = ((unsigned)src1 < (unsigned)src2);
      break;
    }

    break;

  default: {
    result = src1 + src2;
    break;
  }
  }

  inst->result = result;
}

void bru(Inst_info *inst) {
  uint32_t pc_br = inst->pc + inst->imm;
  bool br_taken;

  switch (inst->op) {
  case BR:
    br_taken = inst->result;
    break;
  case JAL:
    br_taken = true;
    break;
  case JALR:
    br_taken = true;
    pc_br = (inst->reg_rdata1 + inst->imm) & (~0x1);
    break;
  default:
    br_taken = false;
  }

  if (br_taken)
    inst->pc_next = pc_br;
  else
    inst->pc_next = inst->pc + 4;

  inst->br_taken = br_taken;
}
