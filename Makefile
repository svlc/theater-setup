SHELL = /bin/sh

# clear, then define suffix list
.SUFFIXES:
.SUFFIXES: .rst .html .pdf

INSTALL = install
INSTALL_PROGRAM = $(INSTALL)

RST_FILES = $(wildcard *.rst)
HTML_FILES = $(patsubst %.rst,%.html,$(RST_FILES))
PDF_FILES = $(patsubst %.rst,%.pdf,$(RST_FILES))
SVG_FIGURES = $(wildcard figures/*.svg)
SVG_ICONS = $(wildcard icons/*.svg)
PNG_FIGURES = $(patsubst %.svg,%.png,$(SVG_FIGURES))
SCREEN_FILES = $(wildcard figures/screenshot_[1-9].png)
SCREEN_THUMB_FILES = $(patsubst %.png,%_small.png,$(SCREEN_FILES))

prefix = /usr/local
datarootdir = $(prefix)/share
exec_prefix = $(prefix)
bindir = $(exec_prefix)/bin

.PHONY: all clean
all   : $(SCREEN_THUMB_FILES) $(PNG_FILES) $(HTML_FILES) $(PDF_FILES)

installdirs:
	mkdir -p $(DESTDIR)$/$(bindir)

install-scripts: installdirs
	$(INSTALL_PROGRAM) scripts/tv $(DESTDIR)/$(bindir)
	$(INSTALL_PROGRAM) scripts/speaker $(DESTDIR)/$(bindir)
	$(INSTALL_PROGRAM) scripts/submplay $(DESTDIR)/$(bindir)
	$(INSTALL_PROGRAM) scripts/movewin $(DESTDIR)/$(bindir)
	$(INSTALL_PROGRAM) scripts/controller $(DESTDIR)/$(bindir)

uninstall-scripts:
	rm $(DESTDIR)/$(bindir)/tv
	rm $(DESTDIR)/$(bindir)/speaker
	rm $(DESTDIR)/$(bindir)/submplay
	rm $(DESTDIR)/$(bindir)/movewin
	rm $(DESTDIR)/$(bindir)/controller

icons:
	for dim in "16x16" "32x32" "48x48" "64x64" "96x96" "128x128" "192x192" "256x256" "512x512"; do \
		mkdir -p icons/$${dim}/; \
		for svg in $(SVG_ICONS); do \
			dest=$$( echo $${svg} | sed -r "s/(.*\/)?(.*)/\1$${dim}\/\2/" ); \
			inkscape -f $${svg} -e $${dest%.svg}.png --export-width=$${dim%x*}; \
		done; \
	done;

clean-icons:
	rm -rf icons/{16x16,32x32,48x48,64x64,96x96,128x128,192x192,256x256,512x512}

html:	$(HTML_FILES)

pdf:	$(PDF_FILES)

png:	$(PNG_FILES)

figures/us_keyboard_bindings.png: figures/us_keyboard_bindings.svg
	inkscape -f $< -e $(@) --export-width=900;

figures/evolveo_wn160.png: figures/evolveo_wn160.svg
	inkscape -f $< -e $(@) --export-height=200;

figures/evolveo_wn160_bindings.png: figures/evolveo_wn160_bindings.svg
	inkscape -f $< -e $(@) --export-width=600;

figures/ps3_navigation_controller.png: figures/ps3_navigation_controller.svg
	inkscape -f $< -e $(@) --export-height=200;

figures/ps3_navigation_controller_bindings.png: figures/ps3_navigation_controller_bindings.svg
	inkscape -f $< -e $(@) --export-width=600;

figures/theater_setup.png: figures/theater_setup.svg
	inkscape -f $< -e $(@) --export-width=400;

%_small.png: %.png
	convert -resize "x200^" -gravity center -crop "x200+0+0" -extent "x200" $(<) $(@)

%.pdf: %.rst
	rst2pdf $(<)

%.html: %.rst
	rst2html $(<) > $(@)
clean :
	rm -f $(HTML_FILES) $(PDF_FILES)
	find . -name "*~" -type f -print0 | xargs -0 rm -f
