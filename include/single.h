#include "config.h"
#include <cstdint>
class OutOfOrder {
};

class Single_Top {
private:
  uint32_t pc;
  uint32_t pc_1;

public:
  void init();
  void seq();
  void comb();
  uint32_t RegFile[32];
};
