all: README WHATSNEW hspell.1.html hspell.3.html niqqudless.pdf

README: ../README
	cp -p ../README README

WHATSNEW: ../WHATSNEW
	cp -p ../WHATSNEW WHATSNEW

hspell.1.html: ../hspell.1
	groff -man -Thtml ../hspell.1 > hspell.1.html

hspell.3.html: ../hspell.3
	groff -man -Thtml ../hspell.3 > hspell.3.html

niqqudless.odt: ../doc/niqqudless.odt
	cp -p ../doc/niqqudless.odt niqqudless.odt

niqqudless.pdf: niqqudless.odt
	unoconv -f pdf niqqudless.odt
