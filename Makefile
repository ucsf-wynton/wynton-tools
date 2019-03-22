SHELL:=/bin/bash

README.md: bin/wynton
#	@bfr=`cat $<`; 
	@printf "# UCSF Wynton HPC Tools\n\n" > $@
	@help=$$(bin/wynton --help); \
	echo '```' >> $@; \
	echo "$${help}" >> $@; \
	echo '```' >> $@
	@echo "README.md"


.PHONY: test

check:
	shellcheck bin/*
