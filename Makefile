# override any locale settings the user might have - they are destructive
# to some of the things we do here (like sort).
#export LANG=C
#export LC_ALL=C
# Because the "export" directive is only supported by Gnu make, let's instead
# redfine all the relevant LC_* variables the user might have set... Note that
# the following only modified environment variables that were already exported
# by the user - which is actually ok (but this makes us have to set all these
# different variables).
LANG=C
LC_ALL=C
LC_CTYPE=C
LC_COLLATE=C

# build and installation paths
DESTDIR =
PREFIX = /usr/local
BIN = $(PREFIX)/bin
SHARE = $(PREFIX)/share/hspell
LIBEXEC = $(PREFIX)/lib/hspell
MAN1 = $(PREFIX)/man/man1


################################################
all: out.nouns out.verbs out.nouns-shemp hspell.pl_full \
     hspell.pl_wzip wunzip wordlist.wgz

out.nouns: wolig.pl wolig.dat
	./wolig.pl > out.nouns

out.nouns-shemp: wolig.pl shemp.dat
	./wolig.pl shemp.dat > out.nouns-shemp

shemp.dat out.verbs: woo woo.dat
	./woo > out.verbs

hspell.pl_full: hspell.pl
	sed 's+^my @dictionaries=.*$$+my @dictionaries=("$(SHARE)/out.nouns","$(SHARE)/out.nouns-shemp","$(SHARE)/out.verbs","$(SHARE)/milot","$(SHARE)/extrawords","$(SHARE)/biza-verbs","$(SHARE)/biza-nouns");+; s+my @likelyerror.*$$+my @likelyerror_dictionaries=("$(SHARE)/likelyerrors");+; s+@spellinghints_dictionaries=("spellinghints")+@spellinghints_dictionaries=("$(SHARE)/spellinghints")+' < hspell.pl > $@
	chmod 755 $@

hspell.pl_wzip: hspell.pl
	sed 's+^my @dictionaries=.*$$+my @dictionaries=("zcat $(SHARE)/wordlist.wgz|$(LIBEXEC)/wunzip|");+; s+my @likelyerror.*$$+my @likelyerror_dictionaries=("$(SHARE)/likelyerrors");+; s+@spellinghints_dictionaries=("spellinghints")+@spellinghints_dictionaries=("$(SHARE)/spellinghints")+' < hspell.pl > $@
	chmod 755 $@

CFLAGS=-O
LDFLAGS=-s
wunzip:

# experimental, not currently in use:
# TODO: use this instead of seperate out.nouns and out.nouns-shemp in the
# installation! It's 5% smaller. (not a major difference...)
out.nouns-all: wolig.pl wolig.dat shemp.dat
	cat wolig.dat shemp.dat | grep -v "^#"| sed "s/ *#.*$$//" | \
		sort -u | ./wolig.pl /dev/stdin > out.nouns-all

################################################

DICTS= out.nouns out.verbs out.nouns-shemp milot extrawords biza-verbs biza-nouns
wordlist.wgz: $(DICTS) wzip
	grep -h "^[à-úLB]" $(DICTS) | tr -d '-' | sort -u | ./wzip | gzip -9 \
		> wordlist.wgz

################################################

install: $(DICTS) likelyerrors spellinghints hspell.pl_full
	test -d $(DESTDIR)/$(BIN) || mkdir -m 755 -p $(DESTDIR)/$(BIN)
	cp hspell.pl_full $(DESTDIR)/$(BIN)/hspell
	chmod 755 $(DESTDIR)/$(BIN)/hspell
	test -L $(DESTDIR)/$(BIN)/hspell-i || ln -s hspell $(DESTDIR)/$(BIN)/hspell-i
	test -d $(DESTDIR)/$(SHARE) || mkdir -m 755 -p $(DESTDIR)/$(SHARE)
	cp $(DICTS) likelyerrors spellinghints $(DESTDIR)/$(SHARE)/
	(cd $(DESTDIR)/$(SHARE); chmod 644 $(DICTS) likelyerrors spellinghints)
	test -d $(DESTDIR)/$(MAN1) || mkdir -m 755 -p $(DESTDIR)/$(MAN1)
	cp hspell.1 $(DESTDIR)/$(MAN1)/
	chmod 644 $(DESTDIR)/$(MAN1)/hspell.1

# This will create a much smaller installation (60K instead of 1MB) but the
# -v option (for viewing the reasons for words' *correctness*) will not work
# properly.
install_compressed: wordlist.wgz likelyerrors spellinghints wunzip \
	            hspell.pl_wzip
	test -d $(DESTDIR)/$(BIN) || mkdir -m 755 -p $(DESTDIR)/$(BIN)
	cp hspell.pl_wzip $(DESTDIR)/$(BIN)/hspell
	chmod 755 $(DESTDIR)/$(BIN)/hspell
	test -L $(DESTDIR)/$(BIN)/hspell-i || ln -s hspell $(DESTDIR)/$(BIN)/hspell-i
	test -d $(DESTDIR)/$(SHARE) || mkdir -m 755 -p $(DESTDIR)/$(SHARE)
	cp wordlist.wgz likelyerrors spellinghints $(DESTDIR)/$(SHARE)/
	(cd $(DESTDIR)/$(SHARE); chmod 644 wordlist.wgz likelyerrors spellinghints)
	test -d $(DESTDIR)/$(LIBEXEC) || mkdir -m 755 -p $(DESTDIR)/$(LIBEXEC)
	cp wunzip $(DESTDIR)/$(LIBEXEC)/
	chmod 755 $(DESTDIR)/$(LIBEXEC)/wunzip
	test -d $(DESTDIR)/$(MAN1) || mkdir -m 755 -p $(DESTDIR)/$(MAN1)
	cp hspell.1 $(DESTDIR)/$(MAN1)/
	chmod 755 $(DESTDIR)/$(MAN1)/hspell.1

clean:
	rm -f out.nouns out.verbs out.nouns-shemp hspell.pl_full \
	      hspell.pl_wzip wunzip wordlist.wgz shemp.dat

################################################
# for creating an hspell distribution tar
PACKAGE = hspell
VERSION = 0.4
DISTFILES = COPYING INSTALL LICENSE README WHATSNEW TODO \
	Makefile stats wunzip.c wzip \
	hspell.pl hspell.1 \
	wolig.pl wolig.dat biza-nouns milot extrawords \
	woo woo.dat biza-verbs \
	likelyerrors spellinghints \
	hspell.spec

DISTDIR = $(PACKAGE)-$(VERSION)

distdir:
	rm -rf ./$(DISTDIR)
	mkdir -m 755 $(DISTDIR)
	cp -a $(DISTFILES) $(DISTDIR)
# Note that Oron Peled suggested a more eleborate version that makes hard
# links instead of copies:
#	for file in $(DISTFILES); do \
#		if test -d $$file; then \
#			cp -pr $$file $(distdir)/$$file; \
#		else \
#			test -f $(distdir)/$$file \
#			|| ln $$file $(distdir)/$$file 2> /dev/null \
#			|| cp -p $$file $(distdir)/$$file || :; \
#		fi; \
#	done

dist: distdir
	tar zcvf $(DISTDIR).tar.gz $(DISTDIR)
	rm -rf ./$(DISTDIR)
