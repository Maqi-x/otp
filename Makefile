include make/directories.mk
include make/config.mk

# Sources
LIBOTK_C_SRCS  := $(filter-out $(SRC_DIR)/otk/main.c,$(call rwildcard,$(SRC_DIR)/otk,*.c))
OTK_MAIN_C_SRC := $(SRC_DIR)/otk/main.c

LIBOTP_C_SRCS  := $(filter-out $(SRC_DIR)/otp/main.c,$(call rwildcard,$(SRC_DIR)/otp,*.c))
OTP_MAIN_C_SRC := $(SRC_DIR)/otp/main.c

ALL_C_SRCS := $(LIBOTK_C_SRCS) $(OTK_MAIN_C_SRC) $(LIBOTP_C_SRCS) $(OTP_MAIN_C_SRC)

# Objects
LIBOTK_OBJ_STATIC := $(patsubst %.c,$(OBJ_ROOT_DIR)/%.o,$(LIBOTK_C_SRCS))
LIBOTK_OBJ_SHARED := $(patsubst %.c,$(OBJ_ROOT_DIR)/shared/%.o,$(LIBOTK_C_SRCS))
OTK_MAIN_OBJ      := $(patsubst %.c,$(OBJ_ROOT_DIR)/%.o,$(OTK_MAIN_C_SRC))

LIBOTP_OBJ_STATIC := $(patsubst %.c,$(OBJ_ROOT_DIR)/%.o,$(LIBOTP_C_SRCS))
LIBOTP_OBJ_SHARED := $(patsubst %.c,$(OBJ_ROOT_DIR)/shared/%.o,$(LIBOTP_C_SRCS))
OTP_MAIN_OBJ      := $(patsubst %.c,$(OBJ_ROOT_DIR)/%.o,$(OTP_MAIN_C_SRC))

DEPS := $(patsubst %.c,$(DEP_ROOT_DIR)/%.d,$(ALL_C_SRCS)) \
        $(patsubst %.c,$(DEP_ROOT_DIR)/shared/%.d,$(LIBOTK_C_SRCS) $(LIBOTP_C_SRCS))

.PHONY: all dirs clean lint inspect
.PHONY: libotk libotk-shared libotk-static otk
.PHONY: libotp libotp-shared libotp-static otp

all: dirs otk libotk otp libotp

dirs:
	@$(call CMD_MKDIR_P,$(LIB_DIR))
	@$(call CMD_MKDIR_P,$(BIN_DIR))
	@$(call CMD_MKDIR_P,$(OBJ_ROOT_DIR))
	@$(call CMD_MKDIR_P,$(DEP_ROOT_DIR))
	@$(call CMD_MKDIR_P,$(OBJ_ROOT_DIR)/shared)
	@$(call CMD_MKDIR_P,$(DEP_ROOT_DIR)/shared)

inspect:
	$(MAKE) clean
	$(MAKE) libotk libotp otk otp >/dev/null

libotk-static: $(LIBOTK_STATIC)
libotk-shared: $(LIBOTK_SHARED)
libotk: libotk-static libotk-shared
otk: $(OTK_BIN)

libotp-static: $(LIBOTP_STATIC)
libotp-shared: $(LIBOTP_SHARED)
libotp: libotp-static libotp-shared
otp: $(OTP_BIN)

$(LIBOTK_STATIC): $(LIBOTK_OBJ_STATIC)
	@$(call CMD_MKDIR_P,$(dir $@))
	$(ECHO) "AR $@"
	$(Q)$(AR) rcs $@ $^

$(LIBOTK_SHARED): $(LIBOTK_OBJ_SHARED)
	@$(call CMD_MKDIR_P,$(dir $@))
	$(ECHO) "CC $@"
	$(Q)$(CC) -shared $^ $(LDFLAGS) -o $@

$(OTK_BIN): $(OTK_MAIN_OBJ) $(LIBOTK_STATIC)
	@$(call CMD_MKDIR_P,$(dir $@))
	$(ECHO) "LD $@"
	$(Q)$(CC) $(OTK_MAIN_OBJ) $(LIBOTK_STATIC) $(LDFLAGS) -o $@

$(LIBOTP_STATIC): $(LIBOTP_OBJ_STATIC)
	@$(call CMD_MKDIR_P,$(dir $@))
	$(ECHO) "AR $@"
	$(Q)$(AR) rcs $@ $^

$(LIBOTP_SHARED): $(LIBOTP_OBJ_SHARED) $(LIBOTK_SHARED)
	@$(call CMD_MKDIR_P,$(dir $@))
	$(ECHO) "LD $@"
	$(Q)$(CC) -shared $(LIBOTP_OBJ_SHARED) -L$(LIB_DIR) -lotk $(LDFLAGS) -o $@

$(OTP_BIN): $(OTP_MAIN_OBJ) $(LIBOTP_STATIC) $(LIBOTK_STATIC)
	@$(call CMD_MKDIR_P,$(dir $@))
	$(ECHO) "LD $@"
	$(Q)$(CC) $(OTP_MAIN_OBJ) $(LIBOTP_STATIC) $(LIBOTK_STATIC) $(LDFLAGS) -o $@

$(OBJ_ROOT_DIR)/%.o: %.c
	@$(call CMD_MKDIR_P,$(dir $@))
	@$(call CMD_MKDIR_P,$(DEP_ROOT_DIR)/$(dir $<))
	$(ECHO) "CC $@"
	$(Q)$(CC) $(CFLAGS) -MMD -MP -MF $(DEP_ROOT_DIR)/$*.d -c $< -o $@

$(OBJ_ROOT_DIR)/shared/%.o: %.c
	@$(call CMD_MKDIR_P,$(dir $@))
	@$(call CMD_MKDIR_P,$(DEP_ROOT_DIR)/shared/$(dir $<))
	$(ECHO) "CC $@"
	$(Q)$(CC) $(CFLAGS) $(PIC_CFLAGS) -MMD -MP -MF $(DEP_ROOT_DIR)/shared/$*.d -c $< -o $@

-include $(DEPS)

include make/install.mk

clean:
	@$(call CMD_RM_RF,build)
	@$(call CMD_RM_RF,out)
