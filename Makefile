.PHONY: man test clean

HELP2MAN := help2man

# FILES without underscore (which are private)
PUBLIC_SUBCMD_SRC := $(shell find libexec/shsh-* | sed -e '/_/d' -e 's:^libexec/::')
PUBLIC_CMD_SRC := $(PUBLIC_SUBCMD_SRC)
PUBLIC_CMD_SRC += shsh

MAN_TARGET := $(addsuffix .1, $(addprefix man/man1/,$(PUBLIC_CMD_SRC)))

# linking bins
SHSH_SELF_LINKS := cellar/bin/shsh
# linking mans
SHSH_SELF_LINKS += $(addprefix cellar/, $(MAN_TARGET))
# linking completions
SHSH_SELF_LINKS_COMPLETIONS := cellar/completions/bash/shsh.bash cellar/completions/fish/shsh.fish cellar/completions/zsh/compctl/shsh.zsh
SHSH_SELF_LINKS += $(SHSH_SELF_LINKS_COMPLETIONS)

# a: $(addprefix libexec/,$(PUBLIC_SUBCMD_SRC))
# 	@echo $(subst shsh-, ,$(notdir $^)) | xargs -n1 | xargs -I {} sh -c 'echo "[subcommand: shsh {}]" && shsh {} --help' > include

all: man

man: $(MAN_TARGET)

# Self-link shsh's man files, bins, and completions into cellar.
# This is useful to not add shsh's own bin folder into PATH, and
# instead only maintain one bin path (cellar) in PATH.
self-linking: $(SHSH_SELF_LINKS)

cellar/completions/: % | man
	ln -srf "$<" "$@"

cellar/%: % | man
	ln -srf "$<" "$@"

# pairs of src, target for linking completion files
$(SHSH_SELF_LINKS_COMPLETIONS): $(wildcard completions/*)
	ln -srf completions/shsh.bash cellar/completions/bash/shsh.bash
	ln -srf completions/shsh.fish cellar/completions/fish/shsh.fish
	ln -srf completions/shsh.zsh cellar/completions/zsh/compctl/shsh.zsh

# cellar/bin/shsh: bin/shsh
# 	ln -srf "$<" "$@"

man/man1/%.1: libexec/%
	@ mkdir -p "$(dir $@)"
	-$(HELP2MAN) --no-info "$(subst -, ,$<)" --output=$@

test:
	bats tests

clean:
	rm -rf man/
	rm -rf $(SHSH_SELF_LINKS)