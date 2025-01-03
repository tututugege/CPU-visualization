project_path := D:\HCI\HCI
painterengine_path := .\include
target :=PainterEngine.exe
#####################################################
#mingw32-64 makefile
#####################################################
project_build := $(wildcard $(project_path)/*.c)
project_build_cpp = $(wildcard $(project_path)/*.cpp)

project_build_o := $(patsubst %.c,%.o,$(project_build))
project_build_o += $(patsubst %.cpp,%.o,$(project_build_cpp))

painterengine_build_core := $(wildcard $(painterengine_path)/core/*.c)
painterengine_build_painterengine_o := $(patsubst %.c,%.o,$(painterengine_build_core))

painterengine_build_kernel := $(wildcard $(painterengine_path)/kernel/*.c)
painterengine_build_painterengine_o += $(patsubst %.c,%.o,$(painterengine_build_kernel))

painterengine_build_runtime := $(wildcard $(painterengine_path)/runtime/*.c)
painterengine_build_painterengine_o += $(patsubst %.c,%.o,$(painterengine_build_runtime))

painterengine_build_platform := $(wildcard $(painterengine_path)/platform/windows/*.c)
painterengine_build_painterengine_o += $(patsubst %.c,%.o,$(painterengine_build_platform))

painterengine_build_platform := $(wildcard $(painterengine_path)/platform/windows/*.cpp)
painterengine_build_painterengine_o += $(patsubst %.cpp,%.o,$(painterengine_build_platform))

all:$(project_build_o)  $(painterengine_build_painterengine_o) 
	g++ $(project_build_o) $(painterengine_build_painterengine_o) \
	-O3 -g -o "$(project_path)\$(target)" \
	-I "$(painterengine_path)" \
	-I "$(project_path)" \
	-I "$(painterengine_path)\platform\windows" \
	-L. -lwinmm -ld2d1 -lws2_32 -ldsound -lcomdlg32

	

$(project_path)/%.o:$(project_path)/%.c
	gcc -O3 -c -g $^ -o $@ -I "$(painterengine_path)" -I "$(painterengine_path)/platform/windows" -I "$(painterengine_path)/runtime"

$(project_path)/%.o:$(project_path)/%.cpp
	gcc -O3 -c -g $^ -o $@ -I "$(painterengine_path)" -I "$(painterengine_path)/platform/windows" -I "$(painterengine_path)/runtime"

$(painterengine_path)/runtime/%.o:$(painterengine_path)/runtime/%.c 
	gcc -O3 -c -g $^ -o $@ -I "$(painterengine_path)"

$(painterengine_path)/kernel/%.o:$(painterengine_path)/kernel/%.c
	gcc -O3 -c -g $^ -o $@

$(painterengine_path)/core/%.o:$(painterengine_path)/core/%.c
	gcc -O3 -c -g $^ -o $@

$(painterengine_path)/platform/windows/%.o:$(painterengine_path)/platform/windows/%.c
	gcc -O3 -c -g $^ -o $@ -I "$(project_path)" -I "$(painterengine_path)" -I "$(painterengine_path)/platform/windows"


.PHONY:clean
clean:
	-del  "$(painterengine_path)\core\*.o"
	-del  "$(painterengine_path)\kernel\*.o"
	-del  "$(painterengine_path)\runtime\*.o"
	-del  "$(painterengine_path)\platform\windows\*.o"
	-del  "$(project_path)\*.o"

	
