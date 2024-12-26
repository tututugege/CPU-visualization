#include "./include/RISCV.h"
#include "./include/core.h"
#include "PainterEngine.h"
#include <Windows.h>
#include <fstream>
#include <iostream>
#include <string>

using namespace std;

PX_FontModule fontModule;

char* Stage[5] = {"IF", "ID", "EX", "MEM", "WB"};
char inst_str[MAX_SIM_TIME][32];
// int stageColor[5] = {PX_COLOR_GREEN, PX_COLOR_BLUE, PX_COLOR_RED, PX_COLOR_}


uint32_t *p_memory = new uint32_t[PHYSICAL_MEMORY_LENGTH];
uint32_t POS_MEMORY_SHIFT = (0x80000000 / 4);
RV_Core core;
Inst_info info[MAX_SIM_TIME][5]; // 所有指令数据
Inst_info info_0[MAX_SIM_TIME];
bool valid[MAX_SIM_TIME][5];     // 所有指令数据

bool good_trap = false;
int sim_time = 0;
int commit_num = 0;
px_surface *prendertarget;


void drawPipe();
void clearPipe();
void regUpdate();
void regCheckCreate();

// pc图 访存图
PX_Object *pcMapWidget, *memMapWidget, *regWidget;
PX_Object *pcMap, *memMap;
PX_Object *pcMapButton, *memMapButton;
PX_Object_OscilloscopeData pcData, memData;
px_double pcData_x[MAX_SIM_TIME];
px_double pcData_y[MAX_SIM_TIME];
px_double memData_x[MAX_SIM_TIME];
px_double memData_y[MAX_SIM_TIME];

// 时空图部分
PX_Object *pipelineArea;
PX_Object *scaleSlider; // 调整缩放比例
PX_Object *goButton;    // 手动执行按钮
PX_Object *autoButton;  // 自动执行按钮
PX_Object *regButton;  // 自动执行按钮

PX_Object *speedSlider; // 调整速度

int speed = 1;
int scale = 100;

// 时空图一个小块的大小
int block_width = 4;
int block_height = 1;

int max_pc = 0x10;
int max_mem = 0x10;

PX_OBJECT_EVENT_FUNCTION(showPcMapButton) {
  pcData.Size = sim_time;
  PX_Object_OscilloscopeSetHorizontalMax(pcMap, sim_time);
  PX_Object_OscilloscopeSetLeftVerticalMax(pcMap, max_pc + 0x10);
  PX_Object_OscilloscopeAddData(pcMap, pcData);
  PX_Object_WidgetShow(pcMapWidget);
}

PX_OBJECT_EVENT_FUNCTION(showMemMapButton) {

  memData.Size = sim_time;
  PX_Object_OscilloscopeSetHorizontalMax(memMap, sim_time);
  PX_Object_OscilloscopeSetLeftVerticalMax(memMap, max_mem);
  PX_Object_OscilloscopeAddData(memMap, memData);
  PX_Object_WidgetShow(memMapWidget);

  for (int i = 0; i < sim_time; i++) {
    cout << memData_x[i] << " " << memData_y[i] << endl;
  }
}

PX_OBJECT_EVENT_FUNCTION(goButtonClick) {
  core.cycle(speed);
  clearPipe();
  drawPipe();
  regUpdate();
  char str[10];
  sprintf(str, "%04d", sim_time);

  PX_SurfaceClear(prendertarget, 830, 400, 950, 450, PX_COLOR_WHITE);

  PX_FontModuleDrawText(prendertarget, &fontModule, 880, 420, PX_ALIGN_CENTER,
                        str, PX_COLOR_BLACK);

  pcData.Size = sim_time;
  PX_Object_OscilloscopeSetHorizontalMax(pcMap, sim_time);
  PX_Object_OscilloscopeSetLeftVerticalMax(pcMap, max_pc + 0x10);
  PX_Object_OscilloscopeAddData(pcMap, pcData);

  memData.Size = sim_time;
  PX_Object_OscilloscopeSetHorizontalMax(memMap, sim_time);
  PX_Object_OscilloscopeSetLeftVerticalMax(memMap, max_mem + 0x10);
  PX_Object_OscilloscopeAddData(memMap, memData);

}

PX_OBJECT_EVENT_FUNCTION(autoButtonClick) {
  while (!good_trap) {
    core.cycle(speed);
    clearPipe();
    drawPipe();
  }
}

PX_OBJECT_EVENT_FUNCTION(changeSpeed) {
  speed = PX_Object_SliderBarGetValue(pObject);
}

PX_OBJECT_EVENT_FUNCTION(changeScale) {
  scale = PX_Object_SliderBarGetValue(pObject);
  clearPipe();
  drawPipe();
}

PX_OBJECT_EVENT_FUNCTION(regButtonClick) {
  PX_Object_WidgetShow(regWidget);
}

int main() {
  core.init();

  setbuf(stdout, NULL);
  long i = 0;

  ifstream inst_data("./memory", ios::in);

  /*初始化内存*/
  for (i = 0; i < PHYSICAL_MEMORY_LENGTH; i++) {
    if (inst_data.eof())
      break;
    char inst_data_line[9];
    inst_data.getline(inst_data_line, 9);
    inst_data_line[8] = 0;
    long inst_32b = strtoul(inst_data_line, NULL, 16);
    p_memory[i + POS_MEMORY_SHIFT] = inst_32b;
  }

  ifstream inst_str_in("./quick-sort.dump", ios::in);

  /*初始化内存*/
  for (i = 0; i < MAX_SIM_TIME; i++) {
    if (inst_str_in.eof())
      break;
    inst_str_in.getline(inst_str[i], 32);
  }


  PX_IO_Data io = PX_LoadFileToIOData("font.ttf"); // 加载字模文件

  PX_Object *pObject;
  px_texture tex;
  PainterEngine_Initialize(1000, 500);
  PX_FontModuleInitializeTTF(mp_static, &fontModule, PX_FONTMODULE_CODEPAGE_GBK,
                             32, io.buffer, io.size);
  PX_FreeIOData(&io);

  pObject = PX_Object_PanelCreate(mp, root, 0, 0, 1000, 500);
  // 取得画布表面
  prendertarget = PX_Object_PanelGetSurface(pObject);
  // 画布刷白

  PX_SurfaceClearAll(prendertarget, PX_COLOR_WHITE);
  PX_FontModuleDrawText(prendertarget, &fontModule, 800, 420, PX_ALIGN_CENTER,
                        "Cycle: ", PX_COLOR_BLACK);
  PX_FontModuleDrawText(prendertarget, &fontModule, 880, 420, PX_ALIGN_CENTER,
                        "0000", PX_COLOR_BLACK);

  PX_Object_Menu_Item *pItem, *pItem2;
  // menu 仅展示一下 懒得写实际作用了（（（
  pObject = PX_Object_MenuCreate(mp, root, 0, 0, 128, 0);
  pItem = PX_Object_MenuAddItem(pObject, NULL, "File", NULL, NULL);
  pItem2 = PX_Object_MenuAddItem(pObject, pItem, "New", NULL, NULL);
  PX_Object_MenuAddItem(pObject, pItem2, "New1", NULL, NULL);
  PX_Object_MenuAddItem(pObject, pItem2, "New2", NULL, NULL);
  PX_Object_MenuAddItem(pObject, pItem, "Open", NULL, NULL);
  PX_Object_MenuAddItem(pObject, pItem, "Save", NULL, NULL);
  PX_Object_MenuAddItem(pObject, pItem, "Save As", NULL, NULL);
  PX_Object_MenuAddItem(pObject, pItem, "Exit", NULL, NULL);
  pItem = PX_Object_MenuAddItem(pObject, NULL, "Edit", NULL, NULL);
  PX_Object_MenuAddItem(pObject, pItem, "Undo", NULL, NULL);
  PX_Object_MenuAddItem(pObject, pItem, "Redo", NULL, NULL);
  PX_Object_MenuAddItem(pObject, pItem, "Cut", NULL, NULL);
  PX_Object_MenuAddItem(pObject, pItem, "Copy", NULL, NULL);
  PX_Object_MenuAddItem(pObject, pItem, "Paste", NULL, NULL);
  pItem = PX_Object_MenuAddItem(pObject, NULL, "View", NULL, NULL);
  PX_Object_MenuAddItem(pObject, pItem, "Zoom In", NULL, NULL);
  PX_Object_MenuAddItem(pObject, pItem, "Zoom Out", NULL, NULL);
  PX_Object_MenuAddItem(pObject, pItem, "Zoom 100%", NULL, NULL);
  pItem = PX_Object_MenuAddItem(pObject, NULL, "Help", NULL, NULL);
  PX_Object_MenuAddItem(pObject, pItem, "About", NULL, NULL);
  PX_Object_MenuAddItem(pObject, pItem, "Help", NULL, NULL);
  PX_Object_MenuAddItem(pObject, pItem, "Check Update", NULL, NULL);
  PX_Object_MenuAddItem(pObject, pItem, "Feedback", NULL, NULL);
  PX_Object_MenuAddItem(pObject, pItem, "Donate", NULL, NULL);
  PX_Object_MenuAddItem(pObject, pItem, "Exit", NULL, NULL);
  pipelineArea = PX_Object_ScrollAreaCreate(mp, root, 20, 20, 960, 360);
  PX_Object_ScrollAreaSetBackgroundColor(pipelineArea,
                                         PX_CSS_COLOR_LightSlateGray);


  drawPipe();
  scaleSlider = PX_Object_SliderBarCreate(mp, root, 850, 50, 15, 150,
                                          PX_OBJECT_SLIDERBAR_TYPE_VERTICAL,
                                          PX_OBJECT_SLIDERBAR_STYLE_LINER);
  PX_ObjectRegisterEvent(scaleSlider, PX_OBJECT_EVENT_VALUECHANGED, changeScale,
                         0);
  PX_Object_SliderBarSetRange(scaleSlider, 10, 100);
  PX_Object_SliderBarSetValue(scaleSlider, 100);

  pObject = PX_Object_AutoTextCreate(mp, root, 849, 35, 20, 0);
  PX_Object_AutoTextSetText(pObject, "-");
  PX_Object_AutoTextSetTextColor(pObject, PX_COLOR_BLACK);
  pObject = PX_Object_AutoTextCreate(mp, root, 849, 205, 20, 0);
  PX_Object_AutoTextSetText(pObject, "+");
  PX_Object_AutoTextSetTextColor(pObject, PX_COLOR_BLACK);


  pcMapWidget = PX_Object_WidgetCreate(mp, root, 0, 0, 400, 400, "PC MAP", 0);
  memMapWidget = PX_Object_WidgetCreate(mp, root, 0, 0, 400, 400, "MEM MAP", 0);
  regWidget = PX_Object_WidgetCreate(mp, root, 0, 0, 400, 400, "REG CHECK", 0);
  regCheckCreate();

  pcMap = PX_Object_OscilloscopeCreate(mp, pcMapWidget, 0, 0, 400, 400, 0);
  memMap = PX_Object_OscilloscopeCreate(mp, memMapWidget, 0, 0, 400, 400, 0);


  // 初始化pcMap 和 memMap
  pcData.Color = PX_COLOR(255, 192, 255, 128); // 数据颜色
  pcData.ID = 0;
  pcData.linewidth = 2; // 数据线宽
  pcData.Map =
      PX_OBJECT_OSCILLOSCOPE_OSCILLOSCOPEDATA_MAP_LEFT; // 数据映射到左边垂直坐标
  pcData.MapHorizontalArray = pcData_x;              // 数据水平坐标
  pcData.MapVerticalArray = pcData_y;                // 数据垂直坐标
  pcData.Size = 0;                                   // 数据大小
  pcData.Visibled = PX_TRUE;                         // 数据可见
  pcData.Normalization = 1; // 数据归一化系数为1

  PX_Object_OscilloscopeSetHorizontalMin(pcMap, 0);
  PX_Object_OscilloscopeSetHorizontalMax(pcMap, 0);
  PX_Object_OscilloscopeSetLeftVerticalMin(pcMap, 0);
  PX_Object_OscilloscopeSetLeftVerticalMax(pcMap, 0x10);


  memData.Color = PX_COLOR(255, 192, 255, 128); // 数据颜色
  memData.ID = 1;
  memData.linewidth = 2; // 数据线宽
  memData.Map =
      PX_OBJECT_OSCILLOSCOPE_OSCILLOSCOPEDATA_MAP_LEFT; // 数据映射到左边垂直坐标
  memData.MapHorizontalArray = memData_x;              // 数据水平坐标
  memData.MapVerticalArray = memData_y;                // 数据垂直坐标
  memData.Size = 0;                                      // 数据大小
  memData.Visibled = PX_TRUE;                           // 数据可见
  memData.Normalization = 1; // 数据归一化系数为1
  PX_Object_OscilloscopeSetHorizontalMin(memMap, 0);
  PX_Object_OscilloscopeSetHorizontalMax(memMap, 0);
  PX_Object_OscilloscopeSetLeftVerticalMin(memMap, 0);
  PX_Object_OscilloscopeSetLeftVerticalMax(memMap, 0x10);


  pObject = PX_Object_AutoTextCreate(mp, root, 10, 450, 80, 0);
  PX_Object_AutoTextSetText(pObject, "Speed: ");
  PX_Object_AutoTextSetTextColor(pObject, PX_COLOR_BLACK);

  // 调整执行速度
  speedSlider = PX_Object_SliderBarCreate(mp, root, 100, 450, 100, 15,
                                          PX_OBJECT_SLIDERBAR_TYPE_HORIZONTAL,
                                          PX_OBJECT_SLIDERBAR_STYLE_BOX);
  PX_ObjectRegisterEvent(speedSlider, PX_OBJECT_EVENT_VALUECHANGED, changeSpeed,
                         0);
  PX_Object_SliderBarSetRange(speedSlider, 1, 100);

  goButton = PX_Object_PushButtonCreate(mp, root, 100, 400, 100, 32, "GO", 0);
  autoButton =
      PX_Object_PushButtonCreate(mp, root, 225, 400, 100, 32, "AUTO", 0);
  pcMapButton =
      PX_Object_PushButtonCreate(mp, root, 350, 400, 100, 32, "PC MAP", 0);
  memMapButton =
      PX_Object_PushButtonCreate(mp, root, 475, 400, 100, 32, "MEM MAP", 0);
  regButton =
      PX_Object_PushButtonCreate(mp, root, 600, 400, 100, 32, "REG CHECK", 0);


  // 按钮事件
  PX_ObjectRegisterEvent(pcMapButton, PX_OBJECT_EVENT_EXECUTE, showPcMapButton,
                         PX_NULL);
  PX_ObjectRegisterEvent(memMapButton, PX_OBJECT_EVENT_EXECUTE,
                         showMemMapButton, PX_NULL);
  PX_ObjectRegisterEvent(goButton, PX_OBJECT_EVENT_EXECUTE, goButtonClick,
                         PX_NULL);
  PX_ObjectRegisterEvent(autoButton, PX_OBJECT_EVENT_EXECUTE, autoButtonClick,
                         PX_NULL);
  PX_ObjectRegisterEvent(regButton, PX_OBJECT_EVENT_EXECUTE, regButtonClick,
                         PX_NULL);

  return 0;
}

int mode = 0;
void drawPipe() {
  // PX_Object_ScrollAreaSetBackgroundColor(pipelineArea,
  //                                        PX_CSS_COLOR_LightSlateGray);

  PX_Object* pObject;
  
  if (mode == 1) {
    for (int i = 0; i < sim_time; i++) {
      for (int j = 0; j < 5; j++) {
        pObject = PX_Object_LabelCreate(
              mp, pipelineArea, 10 + block_width * scale *  i, 10 + block_height * scale * j, 
              block_width * scale, block_height * scale,
              Stage[j], 0, PX_COLOR_BLACK);

        if (valid[i][j]) {
          PX_Object_LabelSetBorder(pObject,PX_TRUE);
          PX_Object_LabelSetBackgroundColor(pObject, PX_COLOR(info[i][j].color & 0xFF, 
                                                    (info[i][j].color >> 8) & 0xFF,
                                                    (info[i][j].color >> 16) & 0xFF,
                                                    (info[i][j].color >> 24) & 0xFF));
        } else {
          PX_Object_LabelSetText(pObject, "Bubble");
        }
      }
    } 
  } else {
    int inst_i = 0;
    for (int i = 0; i < sim_time; i++) {
      int j = info_0[inst_i].inst_idx;

      if (inst_i >= commit_num)
        break;

      if (i < j) {
        pObject = PX_Object_LabelCreate(
            mp, pipelineArea, 10 + block_width * scale *  i, 10 + block_height * scale * i, 
            block_width * scale * 5, block_height * scale,
            "Bubble", 0, PX_COLOR_BLACK);
        PX_Object_LabelSetBorder(pObject,PX_TRUE);
        continue;
      }

      for (int k = 0; k < 6; k++) {
        if (info_0[inst_i].stage[k] == 0)
          break;
          pObject = PX_Object_LabelCreate(
              mp, pipelineArea, 10 + block_width * scale *  (j + k), 10 + block_height * scale * j, 
              block_width * scale, block_height * scale,
              Stage[info_0[inst_i].stage[k] - 1], 0, PX_COLOR_BLACK);
          PX_Object_LabelSetBackgroundColor(pObject, PX_COLOR(info_0[inst_i].color & 0xFF, 
                                                    (info_0[inst_i].color >> 8) & 0xFF,
                                                    (info_0[inst_i].color >> 16) & 0xFF,
                                                    (info_0[inst_i].color >> 24) & 0xFF));
      }

      char temp[10];
      sprintf(temp, "%X", info_0[inst_i].pc);
      temp[8] = ':';
      temp[9] = '\0';

      PX_Object_LabelCreate(
          mp, pipelineArea, 20 + block_width * scale *  (j + info_0[inst_i].time), 10 + block_height * scale * j, 
          block_width * scale * 4, block_height * scale,
          temp, 0, PX_COLOR_BLACK);

      PX_Object_LabelCreate(
          mp, pipelineArea, 100 + block_width * scale *  (j + info_0[inst_i].time), 10 + block_height * scale * j, 
          block_width * scale * 4, block_height * scale,
          inst_str[(info_0[inst_i].pc & 0x7fffffff) / 4], 0, PX_COLOR_BLACK);


      inst_i++;
    }
  }
}

void clearPipe() {
  PX_Object_ScrollAreaClear(pipelineArea);
}

uint32_t load_data(uint32_t address) { 
  int addr = (address & 0x7fffffff) / 4;
  memData_x[sim_time] = sim_time;
  memData_y[sim_time] = addr;
  if (addr > max_mem)
    max_mem = addr;
  return p_memory[address / 4]; 
}

uint32_t load_inst(uint32_t pc) { 
  int addr = (pc & 0x7fffffff) / 4;
  pcData_x[sim_time] = sim_time;
  memData_x[sim_time] = sim_time;
  pcData_y[sim_time] = addr;
  if (addr > max_pc)
    max_pc = addr;

  return p_memory[pc / 4]; 
}

void store_data(uint32_t waddr, uint32_t wdata, uint32_t wstrb) {
  int addr = (waddr & 0x7fffffff) / 4;
  memData_y[sim_time] = addr;
  if (addr > max_mem)
    max_mem = addr;

  uint32_t old_data = p_memory[waddr / 4];
  uint32_t mask = 0;
  if (wstrb & 0b1)
    mask |= 0xFF;
  if (wstrb & 0b10)
    mask |= 0xFF00;
  if (wstrb & 0b100)
    mask |= 0xFF0000;
  if (wstrb & 0b1000)
    mask |= 0xFF000000;

  p_memory[waddr / 4] = (mask & wdata) | (~mask & old_data);
}

extern char* reg_names[];

PX_Object* regObj[32];
void regCheckCreate() {
  for (int i = 0; i < 16; i++) {
    PX_Object_LabelCreate(mp, regWidget, 20, 20 + 20 * i, 50, 20, reg_names[i], 0, PX_COLOR_BLACK);
    regObj[i] = PX_Object_LabelCreate(mp, regWidget, 60, 20 + 20 * i, 80, 20, "00000000", 0, PX_COLOR_BLACK);
    PX_Object_LabelSetBorder(regObj[i], PX_TRUE);
    PX_Object_LabelSetAlign(regObj[i], PX_ALIGN_CENTER);
  }

  for (int i = 0; i < 16; i++) {
    PX_Object_LabelCreate(mp, regWidget, 220, 20 + 20 * i, 50, 20, reg_names[i + 16], 0, PX_COLOR_BLACK);
    regObj[i + 16] = PX_Object_LabelCreate(mp, regWidget, 260, 20 + 20 * i, 80, 20, "00000000", 0, PX_COLOR_BLACK);
    PX_Object_LabelSetBorder(regObj[i + 16], PX_TRUE);
    PX_Object_LabelSetAlign(regObj[i + 16], PX_ALIGN_CENTER);
  }
}

int last_change = -1;
void regUpdate() {
  if (core.pip.commit && core.pip.commit_inst.dest_en) {
    if (last_change != -1) {
      PX_Object_LabelSetTextColor(regObj[last_change], PX_COLOR_BLACK);
    }

    char str[10];
    last_change = core.pip.commit_inst.dest_areg;
    sprintf(str, "%X", core.reg_file[last_change]);
    PX_Object_LabelSetText(regObj[last_change], str);
    PX_Object_LabelSetTextColor(regObj[last_change], PX_COLOR_RED);
  }
}

