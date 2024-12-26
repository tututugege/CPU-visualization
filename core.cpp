#include "./include/config.h"
#include "./include/core.h"
#include <iostream>

void RV_Core::init() {
  this->pip.init();
  this->single.init();
}



extern bool good_trap;
extern int sim_time;
extern int commit_num;
extern Inst_info info[MAX_SIM_TIME][5]; // 所有指令数据
extern Inst_info info_0[MAX_SIM_TIME]; // 所有指令数据
extern bool valid[MAX_SIM_TIME][5]; // 所有指令数据


#define IF  1
#define ID  2
#define EXE 3
#define MEM 4
#define WB  5

void RV_Core::comb() {
  if (this->type == PIPELINE) {

    this->pip.idu.inst.stage[this->pip.idu.inst.time] = ID;
    this->pip.idu.inst.time++;
    this->pip.exu.inst.stage[this->pip.exu.inst.time] = EXE;
    this->pip.exu.inst.time++;
    this->pip.memu.inst.stage[this->pip.memu.inst.time] = MEM;
    this->pip.memu.inst.time++;
    this->pip.comb();


    info[sim_time][0] = this->pip.ifu.IF2ID->inst;
    info[sim_time][1] = this->pip.idu.inst;
    info[sim_time][2] = this->pip.exu.inst;
    info[sim_time][3] = this->pip.memu.inst;
    info[sim_time][4] = this->pip.wbu.inst;

    valid[sim_time][0] = true;
    valid[sim_time][1] = this->pip.idu.valid;
    valid[sim_time][2] = this->pip.exu.valid;
    valid[sim_time][3] = this->pip.memu.valid;
    valid[sim_time][4] = this->pip.wbu.valid;

  } else if (this->type == SINGLE_CYCLE) {
    this->single.comb();
  }
}


void RV_Core::cycle(int num) {
  for (int i = 0; i < num; i++) {
    if (good_trap)
      break;
    
    comb();
    seq();
  }

}

void RV_Core::seq() {
  if (this->type == PIPELINE) {
    this->pip.seq();
    if (this->pip.commit) {
      info_0[commit_num++] = this->pip.commit_inst;
      if (this->pip.commit_inst.op == EBREAK)
        good_trap = (reg_file[10] == 0);
    }
  } else if (this->type == SINGLE_CYCLE) {
    this->single.seq();
  }

  sim_time++;

}
