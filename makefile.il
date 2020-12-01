# Developer's makefile for building Lua
# see luaconf.h for further customization

# == CHANGE THE SETTINGS BELOW TO SUIT YOUR ENVIRONMENT =======================

# Warnings valid for both C and C++
CWARNSCPP= \
	-fmax-errors=5 \
	-Wextra \
	-Wshadow \
	-Wsign-compare \
	-Wundef \
	-Wwrite-strings \
	-Wredundant-decls \
	-Wdisabled-optimization \
	-Wdouble-promotion \
	-Wlogical-op \
	-Wno-aggressive-loop-optimizations \
        # the next warnings might be useful sometimes,
	# but usually they generate too much noise
	# -Werror \
	# -pedantic   # warns if we use jump tables \
	# -Wconversion  \
	# -Wsign-conversion \
	# -Wstrict-overflow=2 \
	# -Wformat=2 \
	# -Wcast-qual \

# The next warnings are neither valid nor needed for C++
CWARNSC= -Wdeclaration-after-statement \
	-Wmissing-prototypes \
	-Wnested-externs \
	-Wstrict-prototypes \
	-Wc++-compat \
	-Wold-style-definition \


CWARNS= $(CWARNSCPP) $(CWARNSC)

# Some useful compiler options for internal tests:
# -DLUAI_ASSERT turns on all assertions inside Lua.
# -DHARDSTACKTESTS forces a reallocation of the stack at every point where
# the stack can be reallocated.
# -DHARDMEMTESTS forces a full collection at all points where the collector
# can run.
# -DEMERGENCYGCTESTS forces an emergency collection at every single allocation.
# -DEXTERNMEMCHECK removes internal consistency checking of blocks being
# deallocated (useful when an external tool like valgrind does the check).
# -DMAXINDEXRK=k limits range of constants in RK instruction operands.
# -DLUA_COMPAT_5_3

# -pg -malign-double
# -DLUA_USE_CTYPE -DLUA_USE_APICHECK
# ('-ftrapv' for runtime checks of integer overflows)
# -fsanitize=undefined -ftrapv -fno-inline
# TESTS= -DLUA_USER_H='"ltests.h"' -O0 -g


LOCAL = $(TESTS) $(CWARNS)


# enable Linux goodies
MYCFLAGS= $(LOCAL) -std=c99 -DLUA_USE_LINUX -march=rv64imafdcxcheri -mabi=l64pc128d --sysroot=$(HOME)/cheri/output/rootfs-riscv64-purecap -mno-relax -g
MYLDFLAGS= $(LOCAL) -Wl,-E --sysroot=$(HOME)/cheri/output/rootfs-riscv64-purecap -mabi=l64pc128d
MYLIBS= -ldl


CC=$(HOME)/cheri/output/sdk/bin/riscv64-unknown-freebsd13-clang
LINK=$(HOME)/cheri/output/sdk/bin/llvm-link
CFLAGS= -Wall -O2 $(MYCFLAGS) -fno-stack-protector -fno-common
AR= ar rc
RANLIB= ranlib
RM= rm -f



# == END OF USER SETTINGS. NO NEED TO CHANGE ANYTHING BELOW THIS LINE =========


LIBS = -lm

CORE_T=	lua.bc
CORE_O=	lapi.o lcode.o lctype.o ldebug.o ldo.o ldump.o lfunc.o lgc.o llex.o \
	lmem.o lobject.o lopcodes.o lparser.o lstate.o lstring.o ltable.o \
	ltm.o lundump.o lvm.o lzio.o ltests.o
AUX_O=	lauxlib.o
LIB_O=	lbaselib.o ldblib.o liolib.o lmathlib.o loslib.o ltablib.o lstrlib.o \
	lutf8lib.o loadlib.o lcorolib.o linit.o

LUA_T= lua
LUA_O = lua.bc
LUA_BC = lzio.bc lapi.bc lauxlib.bc lbaselib.bc lcode.bc lcorolib.bc lctype.bc ldblib.bc ldebug.bc ldump.bc lfunc.bc lgc.bc linit.bc liolib.bc llex.bc lmathlib.bc lmem.bc loadlib.bc lobject.bc lopcodes.bc loslib.bc lparser.bc lstate.bc lstring.bc lstrlib.bc ltable.bc ltablib.bc ltests.bc ltm.bc lundump.bc lutf8lib.bc lvm.bc ldo.bc


ALL_T= $(CORE_T) $(LUA_T)
ALL_O= $(CORE_O) $(LUA_O) $(AUX_O) $(LIB_O)
ALL_A= $(CORE_T)

all: lua
	touch all

o:	$(ALL_O)

a:	$(ALL_A)

$(LUA_T): $(LUA_O) $(LUA_BC)
	$(LINK) -v -o lua-final.bc $(LUA_O) $(LUA_BC) 
	$(CC) -o lua $(MYCFLAGS) lua-final.bc -L. $(LIBS) $(MYLIBS) $(DL)


llex.o:
	$(CC) $(CFLAGS) -Os -c llex.c

lparser.o:
	$(CC) $(CFLAGS) -Os -c lparser.c

lcode.o:
	$(CC) $(CFLAGS) -Os -c lcode.c


clean:
	$(RM) $(ALL_T) $(ALL_O)

depend:
	@$(CC) $(CFLAGS) -MM *.c

echo:
	@echo "CC = $(CC)"
	@echo "CFLAGS = $(CFLAGS)"
	@echo "AR = $(AR)"
	@echo "RANLIB = $(RANLIB)"
	@echo "RM = $(RM)"
	@echo "MYCFLAGS = $(MYCFLAGS)"
	@echo "MYLDFLAGS = $(MYLDFLAGS)"
	@echo "MYLIBS = $(MYLIBS)"
	@echo "DL = $(DL)"

$(ALL_O): makefile ltests.h

# DO NOT EDIT
# automatically made with 'gcc -MM l*.c'

lzio.bc: lzio.c lprefix.h lua.h luaconf.h llimits.h lmem.h lstate.h \
 lobject.h ltm.h lzio.h
	$(CC) $(CFLAGS) -flto -emit-llvm -c $< -I. -o $@

lapi.bc: lapi.c lprefix.h lua.h luaconf.h lapi.h llimits.h lstate.h \
 lobject.h ltm.h lzio.h lmem.h ldebug.h ldo.h lfunc.h lgc.h lstring.h \
 ltable.h lundump.h lvm.h
	$(CC) $(CFLAGS) -flto -emit-llvm -c $< -I. -o $@

lauxlib.bc: lauxlib.c lprefix.h lua.h luaconf.h lauxlib.h
	$(CC) $(CFLAGS) -flto -emit-llvm -c $< -I. -o $@

lbaselib.bc: lbaselib.c lprefix.h lua.h luaconf.h lauxlib.h lualib.h
	$(CC) $(CFLAGS) -flto -emit-llvm -c $< -I. -o $@

lcode.bc: lcode.c lprefix.h lua.h luaconf.h lcode.h llex.h lobject.h \
 llimits.h lzio.h lmem.h lopcodes.h lparser.h ldebug.h lstate.h ltm.h \
 ldo.h lgc.h lstring.h ltable.h lvm.h
	$(CC) $(CFLAGS) -flto -emit-llvm -c $< -I. -o $@

lcorolib.bc: lcorolib.c lprefix.h lua.h luaconf.h lauxlib.h lualib.h
	$(CC) $(CFLAGS) -flto -emit-llvm -c $< -I. -o $@

lctype.bc: lctype.c lprefix.h lctype.h lua.h luaconf.h llimits.h
	$(CC) $(CFLAGS) -flto -emit-llvm -c $< -I. -o $@

ldblib.bc: ldblib.c lprefix.h lua.h luaconf.h lauxlib.h lualib.h
	$(CC) $(CFLAGS) -flto -emit-llvm -c $< -I. -o $@

ldebug.bc: ldebug.c lprefix.h lua.h luaconf.h lapi.h llimits.h lstate.h \
 lobject.h ltm.h lzio.h lmem.h lcode.h llex.h lopcodes.h lparser.h \
 ldebug.h ldo.h lfunc.h lstring.h lgc.h ltable.h lvm.h
	$(CC) $(CFLAGS) -flto -emit-llvm -c $< -I. -o $@
	

ldump.bc: ldump.c lprefix.h lua.h luaconf.h lobject.h llimits.h lstate.h \
 ltm.h lzio.h lmem.h lundump.h
	$(CC) $(CFLAGS) -flto -emit-llvm -c $< -I. -o $@

lfunc.bc: lfunc.c lprefix.h lua.h luaconf.h ldebug.h lstate.h lobject.h \
 llimits.h ltm.h lzio.h lmem.h ldo.h lfunc.h lgc.h
	$(CC) $(CFLAGS) -flto -emit-llvm -c $< -I. -o $@

lgc.bc: lgc.c lprefix.h lua.h luaconf.h ldebug.h lstate.h lobject.h \
 llimits.h ltm.h lzio.h lmem.h ldo.h lfunc.h lgc.h lstring.h ltable.h
	$(CC) $(CFLAGS) -flto -emit-llvm -c $< -I. -o $@

linit.bc: linit.c lprefix.h lua.h luaconf.h lualib.h lauxlib.h
	$(CC) $(CFLAGS) -flto -emit-llvm -c $< -I. -o $@

liolib.bc: liolib.c lprefix.h lua.h luaconf.h lauxlib.h lualib.h
	$(CC) $(CFLAGS) -flto -emit-llvm -c $< -I. -o $@

llex.bc: llex.c lprefix.h lua.h luaconf.h lctype.h llimits.h ldebug.h \
 lstate.h lobject.h ltm.h lzio.h lmem.h ldo.h lgc.h llex.h lparser.h \
 lstring.h ltable.h
	$(CC) $(CFLAGS) -flto -emit-llvm -c $< -I. -o $@

lmathlib.bc: lmathlib.c lprefix.h lua.h luaconf.h lauxlib.h lualib.h
	$(CC) $(CFLAGS) -flto -emit-llvm -c $< -I. -o $@

lmem.bc: lmem.c lprefix.h lua.h luaconf.h ldebug.h lstate.h lobject.h \
 llimits.h ltm.h lzio.h lmem.h ldo.h lgc.h
	$(CC) $(CFLAGS) -flto -emit-llvm -c $< -I. -o $@

loadlib.bc: loadlib.c lprefix.h lua.h luaconf.h lauxlib.h lualib.h
	$(CC) $(CFLAGS) -flto -emit-llvm -c $< -I. -o $@

lobject.bc: lobject.c lprefix.h lua.h luaconf.h lctype.h llimits.h \
 ldebug.h lstate.h lobject.h ltm.h lzio.h lmem.h ldo.h lstring.h lgc.h \
 lvm.h
	$(CC) $(CFLAGS) -flto -emit-llvm -c $< -I. -o $@

lopcodes.bc: lopcodes.c lprefix.h lopcodes.h llimits.h lua.h luaconf.h
	$(CC) $(CFLAGS) -flto -emit-llvm -c $< -I. -o $@

loslib.bc: loslib.c lprefix.h lua.h luaconf.h lauxlib.h lualib.h
	$(CC) $(CFLAGS) -flto -emit-llvm -c $< -I. -o $@
	
lparser.bc: lparser.c lprefix.h lua.h luaconf.h lcode.h llex.h lobject.h \
 llimits.h lzio.h lmem.h lopcodes.h lparser.h ldebug.h lstate.h ltm.h \
 ldo.h lfunc.h lstring.h lgc.h ltable.h
	$(CC) $(CFLAGS) -flto -emit-llvm -c $< -I. -o $@
	
lstate.bc: lstate.c lprefix.h lua.h luaconf.h lapi.h llimits.h lstate.h \
 lobject.h ltm.h lzio.h lmem.h ldebug.h ldo.h lfunc.h lgc.h llex.h \
 lstring.h ltable.h
	$(CC) $(CFLAGS) -flto -emit-llvm -c $< -I. -o $@

lstring.bc: lstring.c lprefix.h lua.h luaconf.h ldebug.h lstate.h \
 lobject.h llimits.h ltm.h lzio.h lmem.h ldo.h lstring.h lgc.h
	$(CC) $(CFLAGS) -flto -emit-llvm -c $< -I. -o $@

lstrlib.bc: lstrlib.c lprefix.h lua.h luaconf.h lauxlib.h lualib.h
	$(CC) $(CFLAGS) -flto -emit-llvm -c $< -I. -o $@

ltable.bc: ltable.c lprefix.h lua.h luaconf.h ldebug.h lstate.h lobject.h \
 llimits.h ltm.h lzio.h lmem.h ldo.h lgc.h lstring.h ltable.h lvm.h
	$(CC) $(CFLAGS) -flto -emit-llvm -c $< -I. -o $@

ltablib.bc: ltablib.c lprefix.h lua.h luaconf.h lauxlib.h lualib.h
	$(CC) $(CFLAGS) -flto -emit-llvm -c $< -I. -o $@

ltests.bc: ltests.c lprefix.h lua.h luaconf.h lapi.h llimits.h lstate.h \
 lobject.h ltm.h lzio.h lmem.h lauxlib.h lcode.h llex.h lopcodes.h \
 lparser.h lctype.h ldebug.h ldo.h lfunc.h lopnames.h lstring.h lgc.h \
 ltable.h lualib.h
	$(CC) $(CFLAGS) -flto -emit-llvm -c $< -I. -o $@

ltm.bc: ltm.c lprefix.h lua.h luaconf.h ldebug.h lstate.h lobject.h \
 llimits.h ltm.h lzio.h lmem.h ldo.h lgc.h lstring.h ltable.h lvm.h
	$(CC) $(CFLAGS) -flto -emit-llvm -c $< -I. -o $@

lua.bc: lua.c lprefix.h lua.h luaconf.h lauxlib.h lualib.h
	$(CC) $(CFLAGS) -flto -emit-llvm -c $< -I. -o $@

lundump.bc: lundump.c lprefix.h lua.h luaconf.h ldebug.h lstate.h \
 lobject.h llimits.h ltm.h lzio.h lmem.h ldo.h lfunc.h lstring.h lgc.h \
 lundump.h
	$(CC) $(CFLAGS) -flto -emit-llvm -c $< -I. -o $@

lutf8lib.bc: lutf8lib.c lprefix.h lua.h luaconf.h lauxlib.h lualib.h
	$(CC) $(CFLAGS) -flto -emit-llvm -c $< -I. -o $@

ldo.bc: ldo.c lprefix.h lua.h luaconf.h lapi.h llimits.h lstate.h \
 lobject.h ltm.h lzio.h lmem.h ldebug.h ldo.h lfunc.h lgc.h lopcodes.h \
 lparser.h lstring.h ltable.h lundump.h lvm.h
	$(CC) $(CFLAGS) -flto -emit-llvm -c $< -I. -o $@

lvm.bc: lvm.c lprefix.h lua.h luaconf.h ldebug.h lstate.h lobject.h \
 llimits.h ltm.h lzio.h lmem.h ldo.h lfunc.h lgc.h lopcodes.h lstring.h \
 ltable.h lvm.h ljumptab.h
	$(CC) $(CFLAGS) -flto -emit-llvm -c $< -I. -o $@

# (end of Makefile)
