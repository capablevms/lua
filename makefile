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
CFLAGS= -Wall -O2 $(MYCFLAGS) -fno-stack-protector -fno-common
AR= ar rc
RANLIB= ranlib
RM= rm -f



# == END OF USER SETTINGS. NO NEED TO CHANGE ANYTHING BELOW THIS LINE =========


LIBS = -lm

CORE_T=	liblua.so
CORE_O=	lapi.o lcode.o lctype.o ldebug.o ldo.o ldump.o lfunc.o lgc.o llex.o \
	lmem.o lobject.o lopcodes.o lparser.o lstate.o lstring.o ltable.o \
	ltm.o lundump.o lvm.o lzio.o ltests.o
AUX_O=	lauxlib.o
LIB_O=	lbaselib.o ldblib.o liolib.o lmathlib.o loslib.o ltablib.o lstrlib.o \
	lutf8lib.o loadlib.o lcorolib.o linit.o

LUA_T=	lua
LUA_O = lua.o
LUA_SO =	liblzio.so liblapi.so liblauxlib.so liblbaselib.so liblcode.so liblcorolib.so liblctype.so libldblib.so libldebug.so libldump.so liblfunc.so liblgc.so liblinit.so libliolib.so libllex.so liblmathlib.so liblmem.so libloadlib.so liblobject.so liblopcodes.so libloslib.so liblparser.so liblstate.so liblstring.so liblstrlib.so libltable.so libltablib.so libltests.so libltm.so liblundump.so liblutf8lib.so liblinterp.so


ALL_T= $(CORE_T) $(LUA_T)
ALL_O= $(CORE_O) $(LUA_O) $(AUX_O) $(LIB_O)
ALL_A= $(CORE_T)

all: lua
	touch all

o:	$(ALL_O)

a:	$(ALL_A)

$(CORE_T): $(CORE_O) $(AUX_O) $(LIB_O)
	
	$(RANLIB) $@

$(LUA_T): $(LUA_O) $(LUA_SO)
	$(CC) -o $@ $(MYLDFLAGS) $(LUA_O) -Wl,-rpath,/root/lua -L. -llzio -llapi -llauxlib -llbaselib -llcode -llcorolib -llctype -lldblib -lldebug -lldump -llfunc -llgc -llinit -lliolib -lllex -llmathlib -llmem -lloadlib -llobject -llopcodes -lloslib -llparser -llstate -llstring -llstrlib -lltable -lltablib -lltests -lltm -llundump -llutf8lib -llinterp $(LIBS) $(MYLIBS) $(DL)


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

liblzio.so: lzio.c lprefix.h lua.h luaconf.h llimits.h lmem.h lstate.h \
 lobject.h ltm.h lzio.h
	$(CC) $(CFLAGS) -fpie -shared $< -I. -o $@

liblapi.so: lapi.c lprefix.h lua.h luaconf.h lapi.h llimits.h lstate.h \
 lobject.h ltm.h lzio.h lmem.h ldebug.h ldo.h lfunc.h lgc.h lstring.h \
 ltable.h lundump.h lvm.h
	$(CC) $(CFLAGS) -fpie -shared $< -I. -o $@

liblauxlib.so: lauxlib.c lprefix.h lua.h luaconf.h lauxlib.h
	$(CC) $(CFLAGS) -fpie -shared $< -I. -o $@

liblbaselib.so: lbaselib.c lprefix.h lua.h luaconf.h lauxlib.h lualib.h
	$(CC) $(CFLAGS) -fpie -shared $< -I. -o $@

liblcode.so: lcode.c lprefix.h lua.h luaconf.h lcode.h llex.h lobject.h \
 llimits.h lzio.h lmem.h lopcodes.h lparser.h ldebug.h lstate.h ltm.h \
 ldo.h lgc.h lstring.h ltable.h lvm.h
	$(CC) $(CFLAGS) -fpie -shared $< -I. -o $@

liblcorolib.so: lcorolib.c lprefix.h lua.h luaconf.h lauxlib.h lualib.h
	$(CC) $(CFLAGS) -fpie -shared $< -I. -o $@

liblctype.so: lctype.c lprefix.h lctype.h lua.h luaconf.h llimits.h
	$(CC) $(CFLAGS) -fpie -shared $< -I. -o $@

libldblib.so: ldblib.c lprefix.h lua.h luaconf.h lauxlib.h lualib.h
	$(CC) $(CFLAGS) -fpie -shared $< -I. -o $@

libldebug.so: ldebug.c lprefix.h lua.h luaconf.h lapi.h llimits.h lstate.h \
 lobject.h ltm.h lzio.h lmem.h lcode.h llex.h lopcodes.h lparser.h \
 ldebug.h ldo.h lfunc.h lstring.h lgc.h ltable.h lvm.h
	$(CC) $(CFLAGS) -fpie -shared $< -I. -o $@
	

libldump.so: ldump.c lprefix.h lua.h luaconf.h lobject.h llimits.h lstate.h \
 ltm.h lzio.h lmem.h lundump.h
	$(CC) $(CFLAGS) -fpie -shared $< -I. -o $@

liblfunc.so: lfunc.c lprefix.h lua.h luaconf.h ldebug.h lstate.h lobject.h \
 llimits.h ltm.h lzio.h lmem.h ldo.h lfunc.h lgc.h
	$(CC) $(CFLAGS) -fpie -shared $< -I. -o $@

liblgc.so: lgc.c lprefix.h lua.h luaconf.h ldebug.h lstate.h lobject.h \
 llimits.h ltm.h lzio.h lmem.h ldo.h lfunc.h lgc.h lstring.h ltable.h
	$(CC) $(CFLAGS) -fpie -shared $< -I. -o $@

liblinit.so: linit.c lprefix.h lua.h luaconf.h lualib.h lauxlib.h
	$(CC) $(CFLAGS) -fpie -shared $< -I. -o $@

libliolib.so: liolib.c lprefix.h lua.h luaconf.h lauxlib.h lualib.h
	$(CC) $(CFLAGS) -fpie -shared $< -I. -o $@

libllex.so: llex.c lprefix.h lua.h luaconf.h lctype.h llimits.h ldebug.h \
 lstate.h lobject.h ltm.h lzio.h lmem.h ldo.h lgc.h llex.h lparser.h \
 lstring.h ltable.h
	$(CC) $(CFLAGS) -fpie -shared $< -I. -o $@

liblmathlib.so: lmathlib.c lprefix.h lua.h luaconf.h lauxlib.h lualib.h
	$(CC) $(CFLAGS) -fpie -shared $< -I. -o $@

liblmem.so: lmem.c lprefix.h lua.h luaconf.h ldebug.h lstate.h lobject.h \
 llimits.h ltm.h lzio.h lmem.h ldo.h lgc.h
	$(CC) $(CFLAGS) -fpie -shared $< -I. -o $@

libloadlib.so: loadlib.c lprefix.h lua.h luaconf.h lauxlib.h lualib.h
	$(CC) $(CFLAGS) -fpie -shared $< -I. -o $@

liblobject.so: lobject.c lprefix.h lua.h luaconf.h lctype.h llimits.h \
 ldebug.h lstate.h lobject.h ltm.h lzio.h lmem.h ldo.h lstring.h lgc.h \
 lvm.h
	$(CC) $(CFLAGS) -fpie -shared $< -I. -o $@

liblopcodes.so: lopcodes.c lprefix.h lopcodes.h llimits.h lua.h luaconf.h
	$(CC) $(CFLAGS) -fpie -shared $< -I. -o $@

libloslib.so: loslib.c lprefix.h lua.h luaconf.h lauxlib.h lualib.h
	$(CC) $(CFLAGS) -fpie -shared $< -I. -o $@
	
liblparser.so: lparser.c lprefix.h lua.h luaconf.h lcode.h llex.h lobject.h \
 llimits.h lzio.h lmem.h lopcodes.h lparser.h ldebug.h lstate.h ltm.h \
 ldo.h lfunc.h lstring.h lgc.h ltable.h
	$(CC) $(CFLAGS) -fpie -shared $< -I. -o $@
	
liblstate.so: lstate.c lprefix.h lua.h luaconf.h lapi.h llimits.h lstate.h \
 lobject.h ltm.h lzio.h lmem.h ldebug.h ldo.h lfunc.h lgc.h llex.h \
 lstring.h ltable.h
	$(CC) $(CFLAGS) -fpie -shared $< -I. -o $@

liblstring.so: lstring.c lprefix.h lua.h luaconf.h ldebug.h lstate.h \
 lobject.h llimits.h ltm.h lzio.h lmem.h ldo.h lstring.h lgc.h
	$(CC) $(CFLAGS) -fpie -shared $< -I. -o $@

liblstrlib.so: lstrlib.c lprefix.h lua.h luaconf.h lauxlib.h lualib.h
	$(CC) $(CFLAGS) -fpie -shared $< -I. -o $@

libltable.so: ltable.c lprefix.h lua.h luaconf.h ldebug.h lstate.h lobject.h \
 llimits.h ltm.h lzio.h lmem.h ldo.h lgc.h lstring.h ltable.h lvm.h
	$(CC) $(CFLAGS) -fpie -shared $< -I. -o $@

libltablib.so: ltablib.c lprefix.h lua.h luaconf.h lauxlib.h lualib.h
	$(CC) $(CFLAGS) -fpie -shared $< -I. -o $@

libltests.so: ltests.c lprefix.h lua.h luaconf.h lapi.h llimits.h lstate.h \
 lobject.h ltm.h lzio.h lmem.h lauxlib.h lcode.h llex.h lopcodes.h \
 lparser.h lctype.h ldebug.h ldo.h lfunc.h lopnames.h lstring.h lgc.h \
 ltable.h lualib.h
	$(CC) $(CFLAGS) -fpie -shared $< -I. -o $@

libltm.so: ltm.c lprefix.h lua.h luaconf.h ldebug.h lstate.h lobject.h \
 llimits.h ltm.h lzio.h lmem.h ldo.h lgc.h lstring.h ltable.h lvm.h
	$(CC) $(CFLAGS) -fpie -shared $< -I. -o $@

lua.o: lua.c lprefix.h lua.h luaconf.h lauxlib.h lualib.h

liblundump.so: lundump.c lprefix.h lua.h luaconf.h ldebug.h lstate.h \
 lobject.h llimits.h ltm.h lzio.h lmem.h ldo.h lfunc.h lstring.h lgc.h \
 lundump.h
	$(CC) $(CFLAGS) -fpie -shared $< -I. -o $@

liblutf8lib.so: lutf8lib.c lprefix.h lua.h luaconf.h lauxlib.h lualib.h
	$(CC) $(CFLAGS) -fpie -shared $< -I. -o $@

ldo.o: ldo.c lprefix.h lua.h luaconf.h lapi.h llimits.h lstate.h \
 lobject.h ltm.h lzio.h lmem.h ldebug.h ldo.h lfunc.h lgc.h lopcodes.h \
 lparser.h lstring.h ltable.h lundump.h lvm.h

lvm.o: lvm.c lprefix.h lua.h luaconf.h ldebug.h lstate.h lobject.h \
 llimits.h ltm.h lzio.h lmem.h ldo.h lfunc.h lgc.h lopcodes.h lstring.h \
 ltable.h lvm.h ljumptab.h

liblinterp.so: lvm.o ldo.o
	$(CC) $(CFLAGS) -fpie -shared lvm.o ldo.o -I. -o $@

# (end of Makefile)
