.PHONY: install uninstall

PREFIX     ?= /usr/local
DESTDIR    ?=
BINDIR     ?= $(PREFIX)/bin
LIBDIR     ?= $(PREFIX)/lib
INCLUDEDIR ?= $(PREFIX)/include

install: all
ifneq ($(PLATFORM),posix)
	$(error install unsupported on non-posix platforms)
else
	@$(call CMD_MKDIR_P,$(DESTDIR)$(BINDIR))
	@$(call CMD_MKDIR_P,$(DESTDIR)$(LIBDIR))
	@$(call CMD_MKDIR_P,$(DESTDIR)$(INCLUDEDIR))

	$(ECHO) "INSTALL $(DESTDIR)$(BINDIR)/$(notdir $(OTK_BIN))"
	$(Q)install -m755 $(OTK_BIN) $(DESTDIR)$(BINDIR)/

	$(ECHO) "INSTALL $(DESTDIR)$(BINDIR)/$(notdir $(OTP_BIN))"
	$(Q)install -m755 $(OTP_BIN) $(DESTDIR)$(BINDIR)/

	$(ECHO) "INSTALL $(DESTDIR)$(LIBDIR)/$(notdir $(LIBOTK_STATIC))"
	$(Q)install -m644 $(LIBOTK_STATIC) $(DESTDIR)$(LIBDIR)/

	$(ECHO) "INSTALL $(DESTDIR)$(LIBDIR)/$(notdir $(LIBOTK_SHARED))"
	$(Q)install -m755 $(LIBOTK_SHARED) $(DESTDIR)$(LIBDIR)/

	$(ECHO) "INSTALL $(DESTDIR)$(LIBDIR)/$(notdir $(LIBOTP_STATIC))"
	$(Q)install -m644 $(LIBOTP_STATIC) $(DESTDIR)$(LIBDIR)/

	$(ECHO) "INSTALL $(DESTDIR)$(LIBDIR)/$(notdir $(LIBOTP_SHARED))"
	$(Q)install -m755 $(LIBOTP_SHARED) $(DESTDIR)$(LIBDIR)/

	$(ECHO) "INSTALL $(DESTDIR)$(INCLUDEDIR)"
	$(Q)cp -R $(INCLUDE_DIR)/. $(DESTDIR)$(INCLUDEDIR)/
endif

uninstall:
ifneq ($(PLATFORM),posix)
	$(error install unsupported on non-posix platforms)
else
	$(ECHO) "RM $(DESTDIR)$(BINDIR)/$(notdir $(OTK_BIN))"
	@$(call CMD_RM_F,$(DESTDIR)$(BINDIR)/$(notdir $(OTK_BIN)))

	$(ECHO) "RM $(DESTDIR)$(BINDIR)/$(notdir $(OTP_BIN))"
	@$(call CMD_RM_F,$(DESTDIR)$(BINDIR)/$(notdir $(OTP_BIN)))

	$(ECHO) "RM $(DESTDIR)$(LIBDIR)/$(notdir $(LIBOTK_STATIC))"
	@$(call CMD_RM_F,$(DESTDIR)$(LIBDIR)/$(notdir $(LIBOTK_STATIC)))

	$(ECHO) "RM $(DESTDIR)$(LIBDIR)/$(notdir $(LIBOTK_SHARED))"
	@$(call CMD_RM_F,$(DESTDIR)$(LIBDIR)/$(notdir $(LIBOTK_SHARED)))

	$(ECHO) "RM $(DESTDIR)$(LIBDIR)/$(notdir $(LIBOTP_STATIC))"
	@$(call CMD_RM_F,$(DESTDIR)$(LIBDIR)/$(notdir $(LIBOTP_STATIC)))

	$(ECHO) "RM $(DESTDIR)$(LIBDIR)/$(notdir $(LIBOTP_SHARED))"
	@$(call CMD_RM_F,$(DESTDIR)$(LIBDIR)/$(notdir $(LIBOTP_SHARED)))

	$(ECHO) "RM $(DESTDIR)$(INCLUDEDIR)/otk"
	@$(call CMD_RM_RF,$(DESTDIR)$(INCLUDEDIR)/otk)

	$(ECHO) "RM $(DESTDIR)$(INCLUDEDIR)/otp"
	@$(call CMD_RM_RF,$(DESTDIR)$(INCLUDEDIR)/otp)
endif
