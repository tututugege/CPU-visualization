#include "./include/RISCV.h"
#include "./include/config.h"
#include "./include/core.h"
#include <cstring>
#include <iostream>
using namespace std;

extern RV_Core core;

inline long cvt_bit_to_number_unsigned(bool input_data[], int k) {

  uint32_t output_number = 0;
  int i;
  for (i = 0; i < k; i++) {
    output_number += uint32_t(input_data[i]) << (k - 1 - i);
    // cout<<input_data[i];
  }
  // cout<<' '<<dec<<output_number<<endl;
  return output_number;
};

void inline copy_indice(bool *dst, uint32_t dst_idx, bool *src,
                        uint32_t src_idx, uint32_t num) {
  memcpy(dst + dst_idx, src + src_idx, num * sizeof(bool));
}

void inline init_indice(bool *arr, uint32_t idx, uint32_t num) {
  memset(arr + idx, 0, num * sizeof(bool));
}

inline void sign_extend(bool *bit_output, int output_length, bool *bit_input,
                        int input_length) {
  for (int i = 0; i < output_length - input_length; i++)
    bit_output[i] = bit_input[0];
  for (int i = 0; i < input_length; i++)
    bit_output[output_length - input_length + i] = bit_input[i];
}

void inline cvt_number_to_bit_unsigned(bool *output_number, uint32_t input_data,
                                       int k) {
  int i;
  for (i = 0; i < k; i++) {
    output_number[i] = (input_data >> (k - 1 - i)) & uint32_t(1);
  }
};

char* reg_names[32] = {"zero", "ra", "sp",  "gp",  "tp", "t0", "t1", "t2",
                        "fp",   "s1", "a0",  "a1",  "a2", "a3", "a4", "a5",
                        "a6",   "a7", "s2",  "s3",  "s4", "s5", "s6", "s7",
                        "s8",   "s9", "s10", "s11", "t3", "t4", "t5", "t6"};

Inst_info decode(uint32_t instruction) {
  // 操作数来源以及type
  bool dest_en, src1_en, src2_en;
  bool src2_is_imm;
  bool src2_is_4;
  Inst_op op;
  uint32_t imm;
  uint32_t csr_idx;
  bool inst_bit[32];
  char name[16];
  cvt_number_to_bit_unsigned(inst_bit, instruction, 32);

  // split instruction
  bool *bit_op_code = inst_bit + 25; // 25-31
  bool *rd_code = inst_bit + 20;     // 20-24
  bool *rs_a_code = inst_bit + 12;   // 12-16
  bool *rs_b_code = inst_bit + 7;    // 7-11
  bool *bit_csr_code = inst_bit + 0; // 0-11

  // 准备opcode、funct3、funct7
  uint32_t number_op_code_unsigned = cvt_bit_to_number_unsigned(bit_op_code, 7);
  bool *bit_funct3 = inst_bit + 17; // 3
  uint32_t number_funct3_unsigned = cvt_bit_to_number_unsigned(bit_funct3, 3);
  bool *bit_funct7 = inst_bit + 0; // 7
  uint32_t number_funct7_unsigned = cvt_bit_to_number_unsigned(bit_funct7, 7);

  // 准备立即数
  bool bit_immi_u_type[32]; // U-type
  bool bit_immi_j_type[21]; // J-type
  bool bit_immi_i_type[12]; // I-type
  bool bit_immi_b_type[13]; // B-type
  bool bit_immi_s_type[12]; // S-type
  init_indice(bit_immi_u_type, 0, 32);
  copy_indice(bit_immi_u_type, 0, inst_bit, 0, 20);
  init_indice(bit_immi_j_type, 0, 21);
  bit_immi_j_type[0] = (*(inst_bit + 0));
  copy_indice(bit_immi_j_type, 1, inst_bit, 12, 8);
  bit_immi_j_type[9] = (*(inst_bit + 11));
  copy_indice(bit_immi_j_type, 10, inst_bit, 1, 10);
  copy_indice(bit_immi_i_type, 0, inst_bit, 0, 12);
  init_indice(bit_immi_b_type, 0, 13);
  bit_immi_b_type[0] = (*(inst_bit + 0));
  bit_immi_b_type[1] = (*(inst_bit + 24));
  copy_indice(bit_immi_b_type, 2, inst_bit, 1, 6);
  copy_indice(bit_immi_b_type, 8, inst_bit, 20, 4);
  copy_indice(bit_immi_s_type, 0, inst_bit, 0, 7);
  copy_indice(bit_immi_s_type, 7, inst_bit, 20, 5);

  // 准备寄存器
  int reg_d_index = cvt_bit_to_number_unsigned(rd_code, 5);
  int reg_a_index = cvt_bit_to_number_unsigned(rs_a_code, 5);
  int reg_b_index = cvt_bit_to_number_unsigned(rs_b_code, 5);

  src2_is_imm = true;

  switch (number_op_code_unsigned) {
  case number_0_opcode_lui: { // lui
    dest_en = true;
    src1_en = false;
    src2_en = false;
    op = LUI;
    imm = cvt_bit_to_number_unsigned(bit_immi_u_type, 32);
    break;
  }
  case number_1_opcode_auipc: { // auipc
    dest_en = true;
    src1_en = false;
    src2_en = false;
    op = AUIPC;
    imm = cvt_bit_to_number_unsigned(bit_immi_u_type, 32);
    break;
  }
  case number_2_opcode_jal: { // jal
    dest_en = true;
    src1_en = false;
    src2_en = false;
    src2_is_imm = false;
    op = JAL;
    bool bit_temp[32];
    sign_extend(bit_temp, 32, bit_immi_j_type, 21);
    imm = cvt_bit_to_number_unsigned(bit_temp, 32);
    break;
  }
  case number_3_opcode_jalr: { // jalr
    dest_en = true;
    src1_en = true;
    src2_en = false;
    op = JALR;
    src2_is_imm = false;

    bool bit_temp[32];
    sign_extend(bit_temp, 32, bit_immi_i_type, 21);
    imm = cvt_bit_to_number_unsigned(bit_temp, 32);

    break;
  }
  case number_4_opcode_beq: { // beq, bne, blt, bge, bltu, bgeu
    dest_en = false;
    src1_en = true;
    src2_en = true;
    op = BR;
    src2_is_imm = false;
    bool bit_temp[32];
    sign_extend(bit_temp, 32, bit_immi_b_type, 13);
    imm = cvt_bit_to_number_unsigned(bit_temp, 32);

    break;
  }
  case number_5_opcode_lb: { // lb, lh, lw, lbu, lhu
    dest_en = true;
    src1_en = true;
    src2_en = false;
    op = LOAD;

    bool bit_temp[32];
    sign_extend(bit_temp, 32, bit_immi_i_type, 12);
    imm = cvt_bit_to_number_unsigned(bit_temp, 32);

    break;
  }
  case number_6_opcode_sb: { // sb, sh, sw
    dest_en = false;
    src1_en = true;
    src2_en = true;
    op = STORE;

    bool bit_temp[32];
    sign_extend(bit_temp, 32, bit_immi_s_type, 12);
    imm = cvt_bit_to_number_unsigned(bit_temp, 32);

    break;
  }
  case number_7_opcode_addi: { // addi, slti, sltiu, xori, ori, andi, slli,
    // srli, srai
    dest_en = true;
    src1_en = true;
    src2_en = false;
    op = ADD;

    bool bit_temp[32];
    sign_extend(bit_temp, 32, bit_immi_i_type, 12);
    imm = cvt_bit_to_number_unsigned(bit_temp, 32);

    break;
  }
  case number_8_opcode_add: { // add, sub, sll, slt, sltu, xor, srl, sra, or,
    dest_en = true;
    src1_en = true;
    src2_en = true;
    src2_is_imm = false;
    op = ADD;
    break;
  }
  case number_9_opcode_fence: { // fence, fence.i
    dest_en = false;
    src1_en = false;
    src2_en = false;
    op = ADD;
    break;
  }
  case number_10_opcode_ebreak: { // ebreak
    dest_en = false;
    src1_en = false;
    src2_en = false;
    op = EBREAK;
    break;
  }

  default: {
    if (LOG) {
      cerr << "*****************************************" << endl;
      cerr << "Error: unknown instruction: ";
      cerr << cvt_bit_to_number_unsigned(inst_bit, 32) << endl;
      cerr << "*****************************************" << endl;
    }
    /*assert(0);*/
    break;
  }
  }

  // 不写0寄存器
  if (reg_d_index == 0)
    dest_en = 0;

  Inst_info info = {.dest_areg = reg_d_index,
                    .src1_areg = reg_a_index,
                    .src2_areg = reg_b_index,
                    .dest_en = dest_en,
                    .src1_en = src1_en,
                    .src2_en = src2_en,
                    .op = op,
                    .src2_is_imm = src2_is_imm,
                    .func3 = number_funct3_unsigned,
                    .func7_5 = (bool)(number_funct7_unsigned >> 5),
                    .imm = imm};

  return info;
}