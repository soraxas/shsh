.PHONY: man test clean self-linking install

XDG_DATA_HOME := $(or $(XDG_DATA_HOME),$(HOME)/.local/share/)
SHSH_ROOT := $(or $(SHSH_ROOT),$(XDG_DATA_HOME)/shsh)

HELP2MAN := help2man
LN_CMD := ln -srf

MAIN_SHSH_SRC := libexec/shsh
# FILES without underscore (which are private)
PUBLIC_SUBCMD_SRC := $(shell find libexec/shsh-* | sed -e '/_/d' -e 's:^libexec/::')
PUBLIC_CMD_SRC := shsh $(PUBLIC_SUBCMD_SRC)
PUBLIC_CMD_SRC_WITH_DIR := $(addprefix libexec/, $(PUBLIC_CMD_SRC))

MAN_MAIN_TARGET := man/man1/shsh.1
MAN_SUBCMD_TARGET := $(addsuffix .1, $(addprefix man/man1/,$(PUBLIC_SUBCMD_SRC)))
MAN_SEE_ALSO := build/man/see_also.h2m
MAN_MAIN_SUBCMD_SECTION := build/man/sub_cmds.h2m

MAN_H2M_FLAGS := --no-info --include=$(MAN_SEE_ALSO) 

SHSH_SELF_BINS_LINKS := cellar/bin/shsh
SHSH_SELF_MANS_LINKS := $(addprefix cellar/, $(MAN_SUBCMD_TARGET) $(MAN_MAIN_TARGET))
SHSH_SELF_COMPLETIONS_LINKS := cellar/completions/bash/shsh.bash cellar/completions/fish/shsh.fish cellar/completions/zsh/compctl/shsh.zsh


install: self-linking

man: $(MAN_SUBCMD_TARGET) $(MAN_MAIN_TARGET)

# Self-link shsh's man files, bins, and completions into cellar.
# This is useful to not add shsh's own bin folder into PATH, and
# instead only maintain one bin path (cellar) in PATH.
self-linking: $(addprefix $(SHSH_ROOT)/, $(SHSH_SELF_BINS_LINKS) $(SHSH_SELF_MANS_LINKS) $(SHSH_SELF_COMPLETIONS_LINKS))

$(SHSH_ROOT)/cellar/%: % | man
	@ mkdir -p "$(dir $@)"
	-$(LN_CMD) "$<" "$@"

# pairs of src, target for linking completion files
$(addprefix $(SHSH_ROOT)/, $(SHSH_SELF_COMPLETIONS_LINKS)): $(wildcard completions/*)
	@ mkdir -p $(addprefix $(SHSH_ROOT)/cellar/completions/, bash fish zsh/compctl)
	-$(LN_CMD) completions/shsh.bash $(SHSH_ROOT)/cellar/completions/bash/shsh.bash
	-$(LN_CMD) completions/shsh.fish $(SHSH_ROOT)/cellar/completions/fish/shsh.fish
	-$(LN_CMD) completions/shsh.zsh $(SHSH_ROOT)/cellar/completions/zsh/compctl/shsh.zsh

# Includes all subcommand's man to the main shsh man page
# The awk extract the useful parts, head and tail remove the first and last lines,
# sed replace section header to non-section bold text, and also add a header for the
# specific subcommand
$(MAN_MAIN_TARGET): $(MAN_SUBCMD_TARGET) $(MAN_MAIN_SUBCMD_SECTION) $(MAN_SEE_ALSO)
	# -$(HELP2MAN) --no-info "$(subst -, ,$<)" --include=$(MAN_SEE_ALSO) --output=$@
	-$(HELP2MAN) $(MAN_H2M_FLAGS) --include=$(MAN_MAIN_SUBCMD_SECTION) "shsh" --output="$@"

# The conditional perl command is to change the man format for any lines that begins
# with `shsh install` from
# """
# .IP                to    .TP
# shsh install...    ->    shsh install...
# .IP                      BlahBlah Blah
# BlahBlah Blah         
# """
# The end effect is workaround to making the command statement be left indented
# in th man page.
# The cat is just to passthrough from the pipe line, and '\n' & '$' needs extra escape
man/man1/%.1: libexec/% $(MAIN_SHSH_SRC) $(MAN_SEE_ALSO) 
	@ mkdir -p "$(dir $@)"
	@ $(eval CHANGE_MAN_TAG := $(shell case "$<" in \
		(*/"shsh-"*)  echo "perl -0777 -pe 's/.IP\\\n(shsh $(subst shsh-,,$(notdir $<)) .*?)\\\n.IP/.TP\\\n"'$$$$1'"/g'" ;; \
		(*) 		  echo cat ;;esac ))
	-$(HELP2MAN) $(MAN_H2M_FLAGS) "shsh $(subst shsh-,,$(notdir $<))" | $(CHANGE_MAN_TAG) > "$@"

$(MAN_MAIN_SUBCMD_SECTION): $(MAN_SUBCMD_TARGET)
	@ mkdir -p "$(dir $@)"
	@ rm -rf "$@"
	$(foreach shsh_man,$^,awk '/^.SH SYNOPSIS/,/^.SH AUTHOR/' $(shsh_man) \
		| head -n -1 | tail -n+2 \
		| sed -e 's/^.SH/.SS/g' \
			-e '1s/^/[subcmd: $(subst -, ,$(basename $(notdir $(shsh_man))))]\n/' >> "$@";)

# the sed link all public commands within the main libexec folder to the 'see also' section
$(MAN_SEE_ALSO): $(PUBLIC_CMD_SRC_WITH_DIR)
	@ mkdir -p "$(dir $@)"
	@ echo "[see also]" > "$@" && \
	echo $(PUBLIC_CMD_SRC) | sed -e 's/ / \n/g' -e 's/ / (1),/g' -e 's/$$/ (1)/' | sed 's/^/.B /g' >> "$@"

# update license notice
$(MAIN_SHSH_SRC): LICENSE
	copyright_authors="$(shell awk '/^Copyright \(c\)/' "$<")" && \
	sed -i "s/^Copyright (c).*$$/$$copyright_authors/" "$@"


test:
	bats tests

clean:
	rm -rf build/
	rm -rf man/
	rm -rf $(addprefix $(SHSH_ROOT)/, $(SHSH_SELF_BINS_LINKS) $(SHSH_SELF_MANS_LINKS) $(SHSH_SELF_COMPLETIONS_LINKS))
	rm -rf $(MAN_SEE_ALSO)
