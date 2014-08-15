CC=gcc
CFLAGS=-Wall
LDFLAGS=
LINKLIBS=

default: cl.c
	$(CC) $(CFLAGS) -O2 -shared -fPIC cl.c $(LDFLAGS) $(LINKLIBS) -o libchainladder.$(LIBEXT)

platform=$(shell uname)
ifeq ($(platform),Linux)
        LIBEXT=so
else ifeq ($(platform),Darwin)
        LIBEXT=dylib
else
        LIBEXT=dll
endif

clean:
	-rm libchainladder.$(LIBEXT)

.PHONY: \
	default
