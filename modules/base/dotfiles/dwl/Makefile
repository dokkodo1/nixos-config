# Simple Makefile for DWL development
# Based on standard suckless Makefile pattern

PREFIX = /usr/local
MANDIR = ${PREFIX}/share/man

# Use system's pkg-config to find dependencies
PKGS      = wlroots-0.17 wayland-server xkbcommon libinput
DWLCFLAGS = `pkg-config --cflags $(PKGS)` $(CFLAGS) -DWLR_USE_UNSTABLE
LDLIBS    = `pkg-config --libs $(PKGS)` -lm $(LIBS)

CC = gcc

all: dwl

dwl: dwl.c config.h
	$(CC) $(DWLCFLAGS) -o $@ $< $(LDLIBS)

clean:
	rm -f dwl

install: dwl
	mkdir -p ${DESTDIR}${PREFIX}/bin
	cp -f dwl ${DESTDIR}${PREFIX}/bin
	chmod 755 ${DESTDIR}${PREFIX}/bin/dwl

uninstall:
	rm -f ${DESTDIR}${PREFIX}/bin/dwl

reload: clean dwl
	@echo "DWL recompiled successfully"
	@echo "Run: sudo systemctl restart display-manager  # or restart your session"

.PHONY: all clean install uninstall reload