include make/config.mk

SRC_DIR     := src
INCLUDE_DIR := include
DEPS_DIR    := deps

OBJ_ROOT_DIR := build/$(BUILD)/obj
DEP_ROOT_DIR := build/$(BUILD)/dep

OUT_DIR := out/$(BUILD)
LIB_DIR := $(OUT_DIR)/lib
BIN_DIR := $(OUT_DIR)/bin

EXE_EXT :=
ifeq ($(PLATFORM),windows)
	EXE_EXT    := .exe
	SHARED_EXT := .dll
	STATIC_EXT := .a
else ifeq ($(PLATFORM),posix)
	EXE_EXT    :=
	SHARED_EXT := .so
	STATIC_EXT := .a
endif

LIBOTK_NAME   := otk
LIBOTK_STATIC := $(LIB_DIR)/lib$(LIBOTK_NAME)$(STATIC_EXT)
LIBOTK_SHARED := $(LIB_DIR)/lib$(LIBOTK_NAME)$(SHARED_EXT)
OTK_BIN       := $(BIN_DIR)/otk$(EXE_EXT)

LIBOTP_NAME   := otp
LIBOTP_STATIC := $(LIB_DIR)/lib$(LIBOTP_NAME)$(STATIC_EXT)
LIBOTP_SHARED := $(LIB_DIR)/lib$(LIBOTP_NAME)$(SHARED_EXT)
OTP_BIN       := $(BIN_DIR)/otp$(EXE_EXT)
