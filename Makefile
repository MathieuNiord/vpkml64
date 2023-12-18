.PHONY: build
.SILENT:

build:
	rm -f vpkml64.exe libgmp-10.dll
	dune build .
	cp ./bin/libgmp-10.dll .
	cp ./_build/default/src/vpkml64.exe .