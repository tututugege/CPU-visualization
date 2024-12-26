#include "./include/RISCV.h"
#include "./include/config.h"
#include "./include/pipeline.h"

void load_data();
void store_data();

void Pipeline_Top::init() {
  ifu.IF2ID = &(this->IF2ID);
  idu.IF2ID = &IF2ID;
  idu.ID2EX = &ID2EX;
  exu.ID2EX = &ID2EX;
  exu.EX2MEM = &EX2MEM;
  memu.EX2MEM = &EX2MEM;
  memu.MEM2WB = &MEM2WB;
  wbu.MEM2WB = &MEM2WB;

  ifu.init();
  idu.init();
  exu.init();
  memu.init();
  wbu.init();
}

void Pipeline_Top::comb() {

  exu.MEM2EX_src1_bypass = exu.valid && memu.valid && memu.inst.dest_en &&
                           exu.inst.src1_en &&
                           memu.inst.dest_areg == exu.inst.src1_areg;

  exu.MEM2EX_src2_bypass = exu.valid && memu.valid && memu.inst.dest_en &&
                           exu.inst.src2_en &&
                           memu.inst.dest_areg == exu.inst.src2_areg;

  exu.WB2EX_src1_bypass = exu.valid && wbu.valid && wbu.inst.dest_en &&
                          exu.inst.src1_en &&
                          wbu.inst.dest_areg == exu.inst.src1_areg;

  exu.WB2EX_src2_bypass = exu.valid && wbu.valid && wbu.inst.dest_en &&
                          exu.inst.src2_en &&
                          wbu.inst.dest_areg == exu.inst.src2_areg;

  exu.WB2EX_data_bypass = wbu.inst.result;
  exu.MEM2EX_data_bypass = memu.inst.result;

  exu.comb();
  ifu.br_taken = exu.br_taken;
  ifu.br_pc = exu.br_pc;
  idu.br_taken = exu.br_taken;

  wbu.comb();
  memu.comb();
  idu.comb();

  bool stall =
      idu.valid && exu.valid && exu.inst.dest_en && exu.inst.op == LOAD &&
      ((exu.inst.dest_areg == ID2EX.inst.src1_areg && ID2EX.inst.src1_en) ||
       exu.inst.dest_areg == ID2EX.inst.src2_areg && ID2EX.inst.src2_en);

  IF2ID.ready = IF2ID.ready && !stall;
  ID2EX.valid = ID2EX.valid && !stall;

  ifu.comb();

  wbu.fire();
  memu.fire();
  exu.fire();
  idu.fire();
  ifu.fire();
  wbu.inst.stage[wbu.inst.time] = 5;
  wbu.inst.time++;
  commit = wbu.valid;
  commit_inst = wbu.inst;
}

void Pipeline_Top::seq() {
  wbu.seq();
  memu.seq();
  exu.seq();
  idu.seq();
  ifu.seq();
}
