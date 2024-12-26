#pragma once
#include <cstdint>
#include <stdbool.h>
#include <stdint.h>

#define MAX_SIM_TIME 3500
#define ARF_NUM 32
#define LOG 0

#define UART_BASE 0x10000000

enum Inst_type {
  INVALID,
  UTYPE,
  JTYPE,
  ITYPE,
  BTYPE,
  STYPE,
  RTYPE,
};

typedef enum Inst_op {
  NONE,
  LUI,
  AUIPC,
  JAL,
  JALR,
  ADD,
  BR,
  LOAD,
  STORE,
  EBREAK
} Inst_op;

typedef struct Inst_info {
  uint32_t instruction;
  int dest_areg, src1_areg, src2_areg;
  bool dest_en, src1_en, src2_en;
  Inst_op op;
  bool src2_is_imm;
  uint32_t func3;
  bool func7_5;
  uint32_t reg_rdata1;
  uint32_t reg_rdata2;
  uint32_t imm;
  uint32_t pc;
  uint32_t result;
  uint32_t pc_next;
  bool br_taken;
  int inst_idx;
  uint32_t color;
  int time = 0;  
  int stage[6];  
} Inst_info;

inline bool is_branch(Inst_op op) {
  return op == BR || op == JALR || op == JAL;
}

typedef struct {
  bool valid;
  bool ready;
  Inst_info inst;
} Pipeline_IO;
