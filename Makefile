SHELL=/bin/bash
PATH:=./bin:${PATH}

all: README.md shellcheck check

README.md: bin/wynton
	help=$$(bin/wynton --help); \
	{ \
	   printf "# UCSF Wynton HPC Tools\n\n"; \
	   echo '```'; \
	   echo '$$ wynton --help'; \
	   echo "$${help}"; \
	   echo '```'; \
	} >> $@
	@echo "README.md"


.PHONY: test

shellcheck:
	(cd bin; \
	   shellcheck --shell=bash --external-sources -- incl/*.sh; \
	   shellcheck --shell=bash --external-sources -- utils/*.sh; \
	   find . -mindepth 1 -maxdepth 1 -type f ! -name '*~' -exec shellcheck --external-sources {} \; \
	)

check:
	wynton --version
	wynton --help
	wynton account --help
	wynton account --user=hb-test
	wynton account --user=hb-test --check || true ## FIXME: Use an account that doesn't have FAILs
