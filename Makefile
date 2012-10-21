prefix = ${shell arc --show-prefix}

libdir = $(DESTDIR)/$(prefix)/lib/arc/site

all:

install:
	mkdir -p $(libdir)
	cp parseopt.arc $(libdir)/parseopt.arc

uninstall:
	rm -rf $(libdir)/parseopt.arc

test:
	prove -fe arc t
