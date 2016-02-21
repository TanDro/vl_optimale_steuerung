# Makefile for LaTeX files

# .tex ----> latex ----> bibtex ----> latex ----> latex ----> .dvi ----> dvips ----> ps2pdf

# $Id: Makefile,v 1.00 2013-11-30 $
ifeq ($(OS),Windows_NT)
	LATEX = /cygdrive/d/texlive/2015/bin/win32/latex.exe
	PDFLATEX = /cygdrive/d/texlive/2015/bin/win32/pdflatex.exe
	BIBTEX = /cygdrive/d/texlive/2015/bin/win32/bibtex.exe
	DVIPS = /cygdrive/d/texlive/2015/bin/win32/dvips.exe
	PS2PDF = /cygdrive/d/texlive/2015/bin/win32/ps2pdf.exe
	RM = /usr/bin/rm	
	OPEN = /usr/bin/cygstart
	FIND = /usr/bin/find
	SED = /usr/bin/sed
	CUT = /usr/bin/cut
	ECHO = /usr/bin/echo
	CONVERT = /cygdrive/c/Program\ Files/ImageMagick-6.9.0-Q16/convert.exe
else
	LATEX = /usr/texbin/latex
	PDFLATEX = /usr/texbin/pdflatex
	BIBTEX = /usr/texbin/bibtex
	DVIPS = /usr/texbin/dvips
	PS2PDF = /opt/local/bin/ps2pdf
	RM = /bin/rm
	CONVERT = /opt/local/bin/convert
	OPEN = /usr/bin/open
	FIND = /usr/bin/find
	SED = /usr/bin/sed
	CUT = /usr/bin/cut
	ECHO = /bin/echo
endif



PNGFILES = $(shell $(FIND) images -type f -name '*.png')
EPSFILES = $(shell $(FIND) images -type f -name '*.png' | $(SED) -e "s/.png/.eps/g")

TEXFILE = $(shell $(FIND) . -type f -maxdepth 1 -depth -name '*.tex' | $(CUT) -d '.' -f2 | $(SED) 's|/||')

#======================================================================
#	alles generieren
#======================================================================
all: images dvi ps pdf
	
#======================================================================
#	Bilder erzeugen
#======================================================================
images: $(EPSFILES)

#======================================================================
#	Bibliothek erzeugen
#======================================================================
bib: $(TEXFILE).bbl

#======================================================================
#	DVI erzeugen
#======================================================================
dvi: $(TEXFILE).dvi

#======================================================================
#	PS erzeugen
#======================================================================
ps: $(TEXFILE).ps

#======================================================================
#	PDF erzeugen
#======================================================================
pdf: $(TEXFILE).pdf
	$(OPEN) $(TEXFILE).pdf
	
#======================================================================
#	PDF erzeugen
#======================================================================
ppdf: 
	@echo '---------------------------------------------------'
	@echo 'PDF:  $(TEXFILE)'
	@echo '---------------------------------------------------' 
	$(PDFLATEX) $(TEXFILE); \
	( \
	$(PDFLATEX) $(TEXFILE); \
	while grep -q "Rerun to get cross-references right." $(TEXFILE).log; \
	do \
		$(PDFLATEX) $(TEXFILE); \
	done \
	)
	$(OPEN) $(TEXFILE).pdf

#======================================================================
#	Hilfe
#======================================================================
help:
	@echo '----------------------------------------------------------------'
	@echo 'Hilfe'
	@echo '----------------------------------------------------------------'
	@echo 'make dvi      :  latex 							-> dvi'
	@echo 'make ps       :  latex + dvips                   -> ps'
	@echo 'make pdf      :  latex + dvips + ps2pdf          -> pdf'
	@echo 'make bib   	 :  bibtex							-> dvi'
	@echo 'make images   :  png to eps  					-> eps'
	@echo 'make clean    :  Temporaere Dateien loeschen'
	@echo 'make help     :  Diese Hilfe'
	@echo '----------------------------------------------------------------'
	
#======================================================================
#	Aufraeumen
#======================================================================
clean:
	$(RM) -f *.ps
	$(RM) -f *.dvi
	$(RM) -f *.aux
	$(RM) -f *.idx
	$(RM) -f *.lof
	$(RM) -f *.log
	$(RM) -f *.lot
	$(RM) -f *.nlo
	$(RM) -f *.out
	$(RM) -f *.toc*
	$(RM) -f *.bbl
	$(RM) -f *.blg
	
#======================================================================
#	TEX to DVI
#======================================================================	
%.dvi: %.tex content/*.tex tikz/*.tex
	@echo '---------------------------------------------------'
	@echo 'DVI:  $(TEXFILE)'
	@echo '---------------------------------------------------'
	$(LATEX) $(TEXFILE); \
	( \
	$(LATEX) $(TEXFILE); \
	while grep -q "Rerun to get cross-references right." $(<:.tex=.log); \
	do \
		$(LATEX) $(TEXFILE); \
	done \
	)
	
#======================================================================
#	BBL File
#======================================================================
%.bbl: bib/*.bib *.aux
	@echo '---------------------------------------------------'
	@echo 'BBL: $(TEXFILE)'
	@echo '---------------------------------------------------'
	$(BIBTEX) $(TEXFILE)
	$(RM) -f *.dvi
#======================================================================
#	Aux File
#======================================================================
%.aux: %.tex
	@echo '---------------------------------------------------'
	@echo 'AUX: $(TEXFILE)'
	@echo '---------------------------------------------------'
	$(LATEX) $(TEXFILE)		
	
#======================================================================
#	DVI to PS
#======================================================================
%.ps: %.dvi
	@echo '---------------------------------------------------'
	@echo 'PS:  $(TEXFILE)'
	@echo '---------------------------------------------------'
	$(DVIPS) -Ppdf -Go $< -o $(<:.dvi=.ps)

#======================================================================
#	PS to PDF
#======================================================================
%.pdf: %.ps
	@echo '---------------------------------------------------'
	@echo 'PDF:  $(TEXFILE)'
	@echo '---------------------------------------------------'
	$(PS2PDF) $<
	
#======================================================================
#	PNG to EPS
#======================================================================
%.eps: %.png
	@echo '---------------------------------------------------'
	@echo 'PNG: $<'
	@echo '---------------------------------------------------'
	$(CONVERT) -compress zip $< eps2:$@
#======================================================================
#	SVG to EPS
#======================================================================
%.eps: %.svg
	@echo '---------------------------------------------------'
	@echo 'SVG: $<'
	@echo '---------------------------------------------------'
	$(CONVERT) $< eps2:$@
