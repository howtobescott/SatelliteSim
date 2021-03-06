######## Build files for FileSystem ########
P_BASEDIR ?= $(CURDIR)/FileSystem/reliance-edge
P_PROJDIR ?= $(CURDIR)/Project/FileSystem/freeRTOS
B_DEBUG ?= 1

#either freertos, linux, stub, u-boot, win32
P_OS ?= freertos
B_OBJEXT ?= o


INCLUDES	+=		-I $(P_BASEDIR)/include
INCLUDES	+=		-I $(P_BASEDIR)/core/include
INCLUDES	+=		-I $(P_BASEDIR)/os/freertos/include
INCLUDES	+=		-I $(P_PROJDIR)

include $(P_BASEDIR)/build/reliance.mk




######## Build options ########

verbose = 0

######## Build setup ########

# SRCROOT should always be the current directory
SRCROOT         = $(CURDIR)

# .o directory
ODIR            = obj

# Source VPATHS
VPATH           += $(SRCROOT)/Source
VPATH	        += $(SRCROOT)/Source/portable/MemMang
VPATH	        += $(SRCROOT)/Source/portable/GCC/POSIX
VPATH           += $(SRCROOT)/Demo
VPATH			+= $(SRCROOT)/Project
VPATH			+= $(SRCROOT)/Project/FileSystem

# FreeRTOS Objects
C_FILES			+= croutine.c
C_FILES			+= event_groups.c
C_FILES			+= list.c
C_FILES			+= queue.c
C_FILES			+= tasks.c
C_FILES			+= timers.c
# C_FILES         += test.c

# portable Objects
C_FILES			+= heap_3.c
C_FILES			+= port.c

# Demo Objects
C_FILES			+= blocktim.c
C_FILES			+= countsem.c
C_FILES			+= GenQTest.c
C_FILES			+= QPeek.c
C_FILES			+= recmutex.c
C_FILES			+= BlockQ.c
C_FILES			+= death.c
C_FILES			+= dynamic.c
C_FILES			+= flop.c
C_FILES			+= integer.c
C_FILES			+= PollQ.c
C_FILES			+= semtest.c

C_FILES			+= AbortDelay.c
C_FILES			+= EventGroupsDemo.c
C_FILES			+= IntSemTest.c
C_FILES			+= QueueSet.c
C_FILES			+= QueueSetPolling.c
C_FILES			+= QueueOverwrite.c
C_FILES			+= TaskNotify.c
C_FILES			+= TimerDemo.c

# Main Object
C_FILES			+= main.c
C_FILES			+= FileSystemTasks.c


# Include Paths
INCLUDES        += -I$(SRCROOT)/Source/include
INCLUDES        += -I$(SRCROOT)/Source/portable/GCC/POSIX/
INCLUDES        += -I$(SRCROOT)/Demo/include
INCLUDES        += -I$(SRCROOT)/Project
INCLUDES		+= -I$(SRCROOT)/Project/FileSystem
INCLUDES		+= -I$(SRCROOT)/Project/FileTransfer/CCSDS_FileDeliveryProtocol/Program/include


INCLUDE 		+= -I$(SRCROOT)/libcsp/include/csp
INCLUDE			+= -I$(SRCROOT)/libcsp/include
INCLUDE 		+= -I$(SRCROOT)/libcsp/build/include

# includeing .a fils
STATIC_OBJS  	+= $(SRCROOT)/Project/FileTransfer/file_delivery_app.a
STATIC_OBJS  	+= $(SRCROOT)/libcsp/build/libcsp.a


# Generate OBJS names
OBJS = $(patsubst %.c,%.o,$(C_FILES))

######## C Flags ########

# Warnings
CWARNS += -W
CWARNS += -Wall
CWARNS += -Werror
CWARNS += -Wextra
CWARNS += -Wformat
CWARNS += -Wmissing-braces
CWARNS += -Wno-cast-align
CWARNS += -Wparentheses
CWARNS += -Wshadow
CWARNS += -Wno-sign-compare
CWARNS += -Wswitch
CWARNS += -Wuninitialized
CWARNS += -Wunknown-pragmas
CWARNS += -Wunused-function
CWARNS += -Wunused-label
CWARNS += -Wunused-parameter
CWARNS += -Wunused-value
CWARNS += -Wunused-variable
CWARNS += -Wmissing-prototypes

#CWARNS += -Wno-unused-function

CFLAGS += -m32
CFLAGS += -DDEBUG=1
#CFLAGS += -g -DUSE_STDIO=1 -D__GCC_POSIX__=1
CFLAGS += -g -UUSE_STDIO -D__GCC_POSIX__=1
ifneq ($(shell uname), Darwin)
CFLAGS += -pthread
endif

# MAX_NUMBER_OF_TASKS = max pthreads used in the POSIX port.
# Default value is 64 (_POSIX_THREAD_THREADS_MAX), the minimum number required by POSIX.
CFLAGS += -DMAX_NUMBER_OF_TASKS=300
CFLAGS += $(INCLUDES) $(CWARNS) -O2


######## Makefile targets ########



# Rules
.PHONY : all
all: setup
	#$(MAKE) -C $(SRCROOT)/Project/FileTransfer/CCSDS_FileDeliveryProtocol/Program/src/ lib
	$(MAKE) SatelliteSim

.PHONY : setup
setup:
# Make obj directory
	@mkdir -p $(ODIR)

# Fix to place .o files in ODIR
_OBJS = $(patsubst %,$(ODIR)/%,$(OBJS))


$(ODIR)/%.o: %.c
# If verbose, print gcc execution, else hide
ifeq ($(verbose),1)
	@echo ">> Compiling $<"
	$(CC) $(CFLAGS) -c -o $@ $<
else
	@echo ">> Compiling $(notdir $<)"
	@$(CC) $(CFLAGS) -c -o $@ $<
endif

# $(REDDRIVOBJ)
SatelliteSim: $(_OBJS) $(REDDRIVOBJ) $(STATIC_OBJS)

	@echo ">> Linking $@..."
ifeq ($(verbose),1)
	$(CC) $(CFLAGS) $^ $(LINKFLAGS) $(LIBS) -o $@
else
	@$(CC) $(CFLAGS) $^ $(LINKFLAGS) $(LIBS) -o $@
endif

	@echo "-------------------------"
	@echo "BUILD COMPLETE: $@"
	@echo "-------------------------"

.PHONY : clean
clean:
	@-rm -rf $(ODIR) FreeRTOS-Sim
	@echo "--------------"
	@echo "CLEAN COMPLETE"
	@echo "--------------"
