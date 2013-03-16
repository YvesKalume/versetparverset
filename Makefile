define LATEX_PREAMBLE
\usepackage[french]{babel}\usepackage{xunicode}\defaultfontfeatures{Ligatures=TeX}\setmainfont{Linux Libertine O}\setsansfont{Linux Biolinum O}\setmonofont[HyphenChar=None]{DejaVu Sans Mono}\usepackage{csquotes}\usepackage{nowidow}\usepackage{microtype}
endef

LATEX_DOCUMENTOPTIONS=fontsize=12pt
LATEX_DOCUMENTCLASS=scrartcl

KINDLE_PATH=/documents/raphael
SOURCES=$(wildcard *.rst)
AUTHOR=Raphaël Pinson
LANGUAGE=fr
PUBDATE=$(shell date)

EBOOK_CONVERT_OPTS=--authors "$(AUTHOR)" --language "$(LANGUAGE)" --pubdate "$(PUBDATE)" --keep-ligatures

all: $(SOURCES:.rst=.pdf) $(SOURCES:.rst=.epub)

kindle: $(DOCUMENT)-to-kindle

%.html: %.rst
	# h1 level is for the document title
	rst2html --initial-header-level=2 --no-toc-backlinks --stylesheet=style.css $< > $@

%.epub: %.html
	ebook-convert $< $@ $(EBOOK_CONVERT_OPTS)

%.mobi: %.epub
	#ebook-convert $< $@ $(EBOOK_CONVERT_OPTS)
	kindlegen $<

%-to-kindle: %.mobi
	# cp -f doesn't work, we need to remove
	ebook-device rm "$(KINDLE_PATH)/$<"
	-ebook-device mkdir "$(KINDLE_PATH)"
	ebook-device cp $< "prs500:$(KINDLE_PATH)/$<"

%.tex: %.rst
	rst2xetex --documentoptions='$(LATEX_DOCUMENTOPTIONS)' \
		  --documentclass='$(LATEX_DOCUMENTCLASS)' \
	          --latex-preamble='$(LATEX_PREAMBLE)' $< > $@

%.pdf: %.tex
	xelatex -interaction=batchmode $<
	xelatex -interaction=batchmode $<

clean:
	rm -f *.html *.tex
	rm -f *.out *.log *.aux *.toc *.pdf
	rm -f *.epub *.mobi
