.PHONY: test

ci-install-deps:
	./scripts/install-supported-languages.sh

test:
	nvim --headless --noplugin -u scripts/minimal_init.vim -c "PlenaryBustedDirectory tests/ { minimal_init = './scripts/minimal_init.vim' }"
