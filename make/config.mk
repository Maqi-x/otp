ifndef OTP_CONFIG
OTP_CONFIG :=

########## the toolchain ###########
CC ?= cc
AR ?= ar
BUILD ?= release

###### platform & shell detection #######
IS_POSIX_SHELL := $(shell echo posix 2>/dev/null)

ifeq ($(IS_POSIX_SHELL),posix)
	USE_POSIX_SHELL := yes
else
	USE_POSIX_SHELL := no
endif

ifeq ($(OS),Windows_NT)
	PLATFORM := windows
else
	PLATFORM := posix
endif

###### compiler kind detection ######
CC_VERSION_OUTPUT := $(shell $(CC) --version)

FSF := Free Software Foundation
ifeq ($(findstring clang,$(CC_VERSION_OUTPUT)),clang)
    CCKIND := clang
else ifeq ($(findstring GCC,$(CC_VERSION_OUTPUT)),GCC)
    CCKIND := gcc
else ifeq ($(findstring $(FSF),$(CC_VERSION_OUTPUT)),$(FSF))
    CCKIND := gcc
else ifeq ($(findstring Microsoft,$(CC_VERSION_OUTPUT)),Microsoft)
    CCKIND := msvc
else ifeq ($(findstring Intel,$(CC_VERSION_OUTPUT)),Intel)
    CCKIND := icx
else
    CCKIND := unknown
endif

########### flags ###########
CSTD       := -std=c11
PIC_CFLAGS := -fPIC

ifneq ($(CCKIND),unknown)
	WARNINGS := \
		-Wall -Wextra \
		-Werror=implicit-fallthrough -Werror=switch \
		-Werror=uninitialized -Werror=return-type \
		-Werror=write-strings -Werror=undef
else
	WARNINGS :=
endif
ifeq ($(CCKIND),gcc)
	WARNINGS += -Werror=discarded-qualifiers
endif

COMMON_CFLAGS  := $(CSTD) $(WARNINGS) -I$(INCLUDE_DIR)
COMMON_LDFLAGS := -lm

IS_DEBUG := $(filter debug rel-debug debug-san rel-debug-san,$(BUILD))
IS_SAN   := $(filter debug-san rel-debug-san,$(BUILD))

DEFAULT_LDFLAGS := $(COMMON_LDFLAGS)
ifeq ($(BUILD),debug)
	DEFAULT_CFLAGS  := $(COMMON_CFLAGS) -O0 -g -DOTP_DEBUG
else ifeq ($(BUILD),debug-san)
	DEFAULT_CFLAGS  := $(COMMON_CFLAGS) -O0 -g -DOTP_DEBUG
else ifeq ($(BUILD),release)
	DEFAULT_CFLAGS  := $(COMMON_CFLAGS) -O3 -DNDEBUG
else ifeq ($(BUILD),rel-debug)
	DEFAULT_CFLAGS  := $(COMMON_CFLAGS) -O3 -g -DNDEBUG
else ifeq ($(BUILD),rel-debug-san)
	DEFAULT_CFLAGS  := $(COMMON_CFLAGS) -O3 -g -DNDEBUG
else ifeq ($(BUILD),manual)
	DEFAULT_CFLAGS  := $(COMMON_CFLAGS)
else
	$(error Unknown BUILD=$(BUILD))
endif

ifneq ($(IS_DEBUG),)
ifneq ($(filter gcc clang,$(strip $(CCKIND))),)
	DEFAULT_CFLAGS += -ftrivial-auto-var-init=pattern
endif
endif

ifneq ($(IS_SAN),)
	SAN_FLAGS       := -fsanitize=address,undefined
	DEFAULT_CFLAGS  += $(SAN_FLAGS)
	DEFAULT_LDFLAGS += $(SAN_FLAGS)
endif

EXTRA_CFLAGS  ?=
EXTRA_LDFLAGS ?=

CFLAGS  ?= $(DEFAULT_CFLAGS) $(EXTRA_CFLAGS)
LDFLAGS ?= $(DEFAULT_LDFLAGS) $(EXTRA_LDFLAGS)

###### platform specific commands abstraction ####
ifeq ($(USE_POSIX_SHELL),yes)
	CMD_MKDIR_P = mkdir -p "$(1)"
	CMD_RM_RF   = rm -rf "$(1)"
	CMD_RM_F    = rm -f "$(1)"
	FIXPATH     = $(1)
else
	CMD_MKDIR_P = powershell -NoProfile -Command "New-Item -ItemType Directory -Force -Path '$(subst /,\,$(1))' | Out-Null"
	CMD_RM_RF   = powershell -NoProfile -Command "Remove-Item -Recurse -Force -Path '$(subst /,\,$(1))' | Out-Null"
	CMD_RM_F    = powershell -NoProfile -Command "Remove-Item -Force -Path '$(subst /,\,$(1))' | Out-Null"
	FIXPATH     = $(subst /,\,$(1))
endif

############### logging #################
ifeq ($(V),1)
    Q =
    ifeq ($(OS),Windows_NT)
        ECHO = @rem
    else
        ECHO = @:
    endif
else
    Q = @
    ECHO = @echo
endif

############ useful "functions" ##########
rwildcard = \
	$(foreach d,$(wildcard $(1)/*),$(call rwildcard,$(d),$(2))) \
	$(filter $(subst *,%,$(2)),$(wildcard $(1)/$(2)))

endif
