all: bin/prefer_external_main
	(cd event_providers && $(MAKE)) >/dev/null

bin/prefer_external_main: prefer_external_main.c | bin
	clang -std=c99 -O2 -framework CoreGraphics -framework CoreFoundation $< -o $@

bin:
	mkdir -p bin
