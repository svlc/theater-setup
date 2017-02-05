SHELL = /bin/sh

# clear, then define suffix list
.SUFFIXES:
.SUFFIXES: .rst .html .pdf

INSTALL = install
INSTALL_PROGRAM = $(INSTALL)

IN_FILES = $(wildcard *.rst)
HTML_FILES = $(patsubst %.rst,%.html,$(IN_FILES))
PDF_FILES = $(patsubst %.rst,%.pdf,$(IN_FILES))
SVG_FILES = $(wildcard figures/*.svg)
PNG_FILES = $(patsubst %.svg,%.png,$(SVG_FILES))

prefix = /usr/local
datarootdir = $(prefix)/share
exec_prefix = $(prefix)
bindir = $(exec_prefix)/bin

.PHONY: all clean
all   : $(PNG_FILES) $(HTML_FILES) $(PDF_FILES)

installdirs:
	mkdir -p $(DESTDIR)$/$(bindir)

install-scripts: installdirs
	$(INSTALL_PROGRAM) scripts/tv $(DESTDIR)/$(bindir)
	$(INSTALL_PROGRAM) scripts/speaker $(DESTDIR)/$(bindir)
	$(INSTALL_PROGRAM) scripts/submplay $(DESTDIR)/$(bindir)

uninstall-scripts:
	rm $(DESTDIR)/$(bindir)/tv
	rm $(DESTDIR)/$(bindir)/speaker
	rm $(DESTDIR)/$(bindir)/submplay

icons:
	for dim in "16x16" "32x32" "48x48" "64x64" "96x96" "128x128" "192x192" "256x256" "512x512"; do \
		mkdir -p icons/$${dim}/; \
		for svg in "theater-setup-speaker-pc.svg" "theater-setup-speaker-tv.svg" "theater-setup-tv-start.svg" "theater-setup-tv-stop.svg"; do \
			inkscape -f icons/$${svg} -e icons/$${dim}/$${svg%.svg}.png --export-width=$${dim%x*}; \
		done; \
	done;

html:	$(HTML_FILES)

pdf:	$(PDF_FILES)

png:	 $(PNG_FILES)

%.png: %.svg
	inkscape -f $< -e $(@) --export-width=400;

%.pdf: %.rst
	rst2pdf $(<)

%.html: %.rst
	rst2html $(<) > $(@)
clean :
	rm -f $(HTML_FILES) $(PDF_FILES)
	find . -name "*~" -type f -print0 | xargs -0 rm -f
	rm -rf icons/{16x16,32x32,48x48,64x64,96x96,128x128,192x192,256x256,512x512}
