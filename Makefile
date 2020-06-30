.PHONY: man test clean

HELP2MAN := help2man

# FILES without underscore (which are private)
PUBLIC_SUBCMD_SRC := $(shell find libexec/shsh-* | sed -e '/_/d' -e 's:^libexec/::')
PUBLIC_CMD_SRC := $(PUBLIC_SUBCMD_SRC)
PUBLIC_CMD_SRC += shsh
PUBLIC_CMD_SRC_WITH_DIR := $(addprefix libexec/, $(PUBLIC_CMD_SRC))

MAN_MAIN_TARGET := man/man1/shsh.1
MAN_SUBCMD_TARGET := $(addsuffix .1, $(addprefix man/man1/,$(PUBLIC_SUBCMD_SRC)))
MAN_SEE_ALSO := build/man/see_also.h2m
MAN_MAIN_SUBCMD_SECTION := build/man/sub_cmds.h2m

MAN_H2M_FLAGS := --no-info --include=$(MAN_SEE_ALSO) 

# linking bins
SHSH_SELF_LINKS := cellar/bin/shsh
# linking mans
SHSH_SELF_LINKS += $(addprefix cellar/, $(MAN_SUBCMD_TARGET))
# linking completions
SHSH_SELF_LINKS_COMPLETIONS := cellar/completions/bash/shsh.bash cellar/completions/fish/shsh.fish cellar/completions/zsh/compctl/shsh.zsh
SHSH_SELF_LINKS += $(SHSH_SELF_LINKS_COMPLETIONS)


all: man

man: $(MAN_SUBCMD_TARGET) $(MAN_MAIN_TARGET)


# Self-link shsh's man files, bins, and completions into cellar.
# This is useful to not add shsh's own bin folder into PATH, and
# instead only maintain one bin path (cellar) in PATH.
# TODO: make it respect env var regardless of install location of shsh
self-linking: $(SHSH_SELF_LINKS)

cellar/%: % | man
	ln -srf "$<" "$@"

# pairs of src, target for linking completion files
$(SHSH_SELF_LINKS_COMPLETIONS): $(wildcard completions/*)
	ln -srf completions/shsh.bash cellar/completions/bash/shsh.bash
	ln -srf completions/shsh.fish cellar/completions/fish/shsh.fish
	ln -srf completions/shsh.zsh cellar/completions/zsh/compctl/shsh.zsh


# Includes all subcommand's man to the main shsh man page
# The awk extract the useful parts, head and tail remove the first and last lines,
# sed replace section header to non-section bold text, and also add a header for the
# specific subcommand
$(MAN_MAIN_TARGET): $(MAN_SUBCMD_TARGET) $(MAN_MAIN_SUBCMD_SECTION) $(MAN_SEE_ALSO)
	# -$(HELP2MAN) --no-info "$(subst -, ,$<)" --include=$(MAN_SEE_ALSO) --output=$@
	-$(HELP2MAN) $(MAN_H2M_FLAGS) --include=$(MAN_MAIN_SUBCMD_SECTION) "shsh" --output="$@"

man/man1/%.1: libexec/% | $(MAN_SEE_ALSO)
	@ mkdir -p "$(dir $@)"
	-$(HELP2MAN) $(MAN_H2M_FLAGS) "shsh $(subst shsh-,,$(notdir $<))" --output="$@"

$(MAN_MAIN_SUBCMD_SECTION): $(MAN_SUBCMD_TARGET)
	@ mkdir -p "$(dir $@)"
	@ rm -rf "$@"
	$(foreach shsh_man,$^,awk '/^.SH SYNOPSIS/,/^.SH AUTHOR/' $(shsh_man) \
		| head -n -1 | tail -n+2 \
		| sed -e 's/^.SH/.SS/g' \
			-e '1s/^/[subcmd: $(subst -, ,$(basename $(notdir $(shsh_man))))]\n/' >> "$@";)

$(MAN_SEE_ALSO): $(PUBLIC_CMD_SRC_WITH_DIR)
	@ mkdir -p "$(dir $@)"
	echo "[see also]" > "$@"
	echo $(PUBLIC_CMD_SRC) | sed -e 's/ / \n/g' -e 's/ / (1),/g' -e 's/$$/ (1)/' | sed 's/^/.B /g' >> "$@"


test:
	bats tests

clean:
	rm -rf build/
	rm -rf man/
	rm -rf $(SHSH_SELF_LINKS)
	rm -rf $(MAN_SEE_ALSO)