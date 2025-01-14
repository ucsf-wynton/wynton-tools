SHELL=/bin/bash
PATH:=./bin:${PATH}

all: shellcheck check

README.md: bin/wynton
#	@bfr=`cat $<`; 
	@printf "# UCSF Wynton HPC Tools\n\n" > $@
	@printf "[![Build Status](https://travis-ci.org/UCSF-HPC/wynton-tools.svg?branch=master)](https://travis-ci.org/UCSF-HPC/wynton-tools)\n\n" >> $@
	@help=$$(bin/wynton --help); \
	echo '```' >> $@; \
	echo "$${help}" >> $@; \
	echo '```' >> $@
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

