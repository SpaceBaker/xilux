#----------------------------------------------------------------------
#	Makefile
#----------------------------------------------------------------------

ifndef CROSS_COMPILE
$(warning "Your environment is not set!)
$(error "Please source 'scripts/setup_env.sh'")
endif

#------------- APP_NAME -------------
APP_NAME = hello

#------------- Working directories -------------
SRC_DIR	   = src
BUILD_DIR  = build
BIN_DIR    = $(BUILD_DIR)/bin
OBJ_DIR    = $(BUILD_DIR)/obj
# MAKE_SCRIPT_DIR = mk

# List source files here
SRCS =	$(wildcard $(SRC_DIR)/*.c)

# List header file directories here
INCS =	$(SRC_DIR)

# List library directories here
LIBS = 

#------------- Defines -------------
DEFS = 

#------------- Optimization Level -------------
OPT	= -O2

#------------- Warnings Options -------------
WARNS = -Wall -Wundef -Wextra -Werror

#------------- Debugging Format -------------
DEBUG = 

#------------- C Language ISO Standard -------------
CSTD = -std=c23

#------------- Verbose -------------
# Comment the line to disable verbose output
# VERB = -v


#---------------------------------------------------------------------------------
# DO NOT EDIT BELOW THIS LINE, UNLESS YOU KNOW WHAT YOU ARE DOING
#---------------------------------------------------------------------------------

#------------- C Compiler Flags -------------
CFLAGS = $(VERB) $(OPT) $(DEBUG) $(WARNS) $(addprefix -I, $(INCS)) $(CSTD) $(DEFS) -fPIC

#------------- C Linker Flags -------------
LDFLAGS = $(VERB) -pie -s $(LIBS)

#------------- Objects -------------
OBJS = $(patsubst $(SRC_DIR)/%.c,$(OBJ_DIR)/%.o,$(SRCS))


#------------- Rules for building the elf file -------------
.PHONY: all

all: $(BIN_DIR)/$(APP_NAME)

$(BIN_DIR)/$(APP_NAME): $(OBJS)
	@echo Linking $<
	@mkdir -p $(@D)
	$(CC) $(LDFLAGS) $^ -o $@

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c
	@echo Compiling $<
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -c $< -o $@

#------------- Other Rules -------------
.PHONY: clean

clean:
	@rm -rv $(BUILD_DIR)/*
















# ------------------- NOTES -------------------------------------------------------------
# Automatic Variables
# Automatic variables are set by make after a rule is matched. There include:

# $@: the target filename.
# $*: the target filename without the file extension.
# $<: the first prerequisite filename.
# $^: the filenames of all the prerequisites, separated by spaces, discard duplicates.
# $+: similar to $^, but includes duplicates.
# $?: the names of all prerequisites that are newer than the target, separated by spaces.