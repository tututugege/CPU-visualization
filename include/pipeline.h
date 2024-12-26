#pragma once
#include "EXU.h"
#include "IDU.h"
#include "IFU.h"
#include "MEMU.h"
#include "WBU.h"
#include "config.h"

class Pipeline_Top {
public:
  void init();
  void seq();
  void comb();

  bool commit;
  Inst_info commit_inst;

  IFU ifu;
  IDU idu;
  EXU exu;
  MEMU memu;
  WBU wbu;

  Pipeline_IO IF2ID;
  Pipeline_IO ID2EX;
  Pipeline_IO EX2MEM;
  Pipeline_IO MEM2WB;
};
