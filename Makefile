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
MAN3 = $(PREFIX)/man/man3
LIBDIR = $(PREFIX)/lib
INCLUDEDIR = $(PREFIX)/include

all: cfrontend

####################################################################
# This is for the old Perl front-end. Use "make hspell_pl" to compile
# it and "make install_pl" or "make install_pl_compressed" to install it.
# This front-end is depracated and will be removed in the future.
#
# See the cfrontend and install_cfrontend targets below for the new
# front-end.
####################################################################
hspell_pl: out.nouns out.verbs out.nouns-shemp hspell.pl_full \
     hspell.pl_wzip wunzip wordlist.wgz

out.nouns: wolig.pl wolig.dat
	./wolig.pl > out.nouns

out.nouns-shemp: wolig.pl shemp.dat
	./wolig.pl shemp.dat > out.nouns-shemp

# SEDCMD is left here as a non-user-friendly option to choose whether you want
# over a 150,000 more rare verb forms or not. The default here is not, but the
# RPM spec builds both forms (it can even play tricks and builds out.verbs only
# once without any sed and then does the sed itself).

#SEDCMD=s/\+//
SEDCMD=/\+/d

shemp.dat out.verbs: woo woo.dat
	./woo | sed "$(SEDCMD)" > out.verbs


hspell.pl_full: hspell.pl
	sed 's+^my @dictionaries=.*$$+my @dictionaries=("$(SHARE)/out.nouns","$(SHARE)/out.nouns-shemp","$(SHARE)/out.verbs","$(SHARE)/milot","$(SHARE)/extrawords","$(SHARE)/biza-verbs","$(SHARE)/biza-nouns");+; s+my @likelyerror.*$$+my @likelyerror_dictionaries=("$(SHARE)/likelyerrors");+; s+@spellinghints_dictionaries=("spellinghints")+@spellinghints_dictionaries=("$(SHARE)/spellinghints")+' < hspell.pl > $@
	chmod 755 $@

hspell.pl_wzip: hspell.pl
	sed 's+^my @dictionaries=.*$$+my @dictionaries=("gzip -dc $(SHARE)/wordlist.wgz|$(LIBEXEC)/wunzip|");+; s+my @likelyerror.*$$+my @likelyerror_dictionaries=("$(SHARE)/likelyerrors");+; s+@spellinghints_dictionaries=("spellinghints")+@spellinghints_dictionaries=("$(SHARE)/spellinghints")+' < hspell.pl > $@
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
	grep -h "^[à-úLB]" $(DICTS) | tr -d '-' | awk '{print $$1}' \
             | sort -u | ./wzip | gzip -9 > wordlist.wgz

################################################

install_pl: $(DICTS) likelyerrors spellinghints hspell.pl_full
	test -d $(DESTDIR)/$(BIN) || mkdir -m 755 -p $(DESTDIR)/$(BIN)
	cp hspell.pl_full $(DESTDIR)/$(BIN)/hspell
	chmod 755 $(DESTDIR)/$(BIN)/hspell
	-rm -f $(DESTDIR)/$(BIN)/hspell-i
	-ln -s hspell $(DESTDIR)/$(BIN)/hspell-i
	test -d $(DESTDIR)/$(SHARE) || mkdir -m 755 -p $(DESTDIR)/$(SHARE)
	cp $(DICTS) likelyerrors spellinghints $(DESTDIR)/$(SHARE)/
	(cd $(DESTDIR)/$(SHARE); chmod 644 $(DICTS) likelyerrors spellinghints)
	test -d $(DESTDIR)/$(MAN1) || mkdir -m 755 -p $(DESTDIR)/$(MAN1)
	cp hspell.1 $(DESTDIR)/$(MAN1)/
	chmod 644 $(DESTDIR)/$(MAN1)/hspell.1

# This will create a much smaller installation (60K instead of 1MB) but the
# -v option (for viewing the reasons for words' *correctness*) will not work
# properly.
install_pl_compressed: wordlist.wgz likelyerrors spellinghints wunzip \
	            hspell.pl_wzip
	test -d $(DESTDIR)/$(BIN) || mkdir -m 755 -p $(DESTDIR)/$(BIN)
	cp hspell.pl_wzip $(DESTDIR)/$(BIN)/hspell
	chmod 755 $(DESTDIR)/$(BIN)/hspell
	-rm -f $(DESTDIR)/$(BIN)/hspell-i
	-ln -s hspell $(DESTDIR)/$(BIN)/hspell-i
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
	      hspell.pl_wzip wunzip wordlist.wgz shemp.dat \
              c/corlist.o c/dict_radix.o c/find_sizes.o c/gimatria.o \
	      c/hspell.o c/tclHash.o c/hebrew.wgz c/hebrew.wgz.sizes \
	      c/hebrew.wgz.prefixes c/dout.nouns.shemp.gz c/shemp.dat \
	      c/dout.nouns.wolig.gz c/dout.verbs.gz c/hspell c/find_sizes \
	      c/prefixes.c c/libhspell.o c/libhspell.a \
	      c/hebrew.wgz.desc c/hebrew.wgz.stems

################################################
# for the C front-end
cfrontend:
	(cd c; $(MAKE) EXTRACFLAGS='-DDICTIONARY_BASE=\"$(SHARE)/hebrew.wgz\"')


# To include a full morphological analyzer in "hspell -l", run "make linginfo"
# instead of just "make". But watch out - this slows down the build, and the
# installed data files will be 4 times as large. But don't worry - this feature
# has no speed impact on hspell unless the -l option is actually used.
linginfo:
	(cd c; $(MAKE) EXTRACFLAGS='-DDICTIONARY_BASE=\"$(SHARE)/hebrew.wgz\" -DUSE_LINGINFO' EXTRAOBJECTS='linginfo.o' dolinginfo)

install: install_cfrontend
CHSPELL=hspell
install_cfrontend: cfrontend
	test -d $(DESTDIR)/$(BIN) || mkdir -m 755 -p $(DESTDIR)/$(BIN)
	strip c/hspell
	cp c/hspell $(DESTDIR)/$(BIN)/$(CHSPELL)
	chmod 755 $(DESTDIR)/$(BIN)/$(CHSPELL)
	cp multispell $(DESTDIR)/$(BIN)/multispell
	chmod 755 $(DESTDIR)/$(BIN)/multispell
	test -d $(DESTDIR)/$(SHARE) || mkdir -m 755 -p $(DESTDIR)/$(SHARE)
	cp c/hebrew.wgz c/hebrew.wgz.prefixes c/hebrew.wgz.sizes $(DESTDIR)/$(SHARE)/
	gzip -9 < spellinghints > $(DESTDIR)/$(SHARE)/hebrew.wgz.hints
	(cd $(DESTDIR)/$(SHARE); chmod 644 hebrew.wgz hebrew.wgz.prefixes hebrew.wgz.sizes hebrew.wgz.hints)
	test ! -f c/hebrew.wgz.stems || cp c/hebrew.wgz.stems c/hebrew.wgz.desc $(DESTDIR)/$(SHARE)/
	(cd $(DESTDIR)/$(SHARE); test ! -f hebrew.wgz.stems || chmod 644 hebrew.wgz.stems hebrew.wgz.desc)
	-rm -f $(DESTDIR)/$(BIN)/hspell-i
	-ln -s $(CHSPELL) $(DESTDIR)/$(BIN)/hspell-i
	test -d $(DESTDIR)/$(MAN1) || mkdir -m 755 -p $(DESTDIR)/$(MAN1)
	cp hspell.1 $(DESTDIR)/$(MAN1)/
	chmod 644 $(DESTDIR)/$(MAN1)/hspell.1
	test -d $(DESTDIR)/$(MAN3) || mkdir -m 755 -p $(DESTDIR)/$(MAN3)
	cp c/hspell.3 $(DESTDIR)/$(MAN3)/
	chmod 644 $(DESTDIR)/$(MAN3)/hspell.3
	test -d $(DESTDIR)/$(LIBDIR) || mkdir -m 755 -p $(DESTDIR)/$(LIBDIR)
	cp c/libhspell.a $(DESTDIR)/$(LIBDIR)/
	chmod 644 $(DESTDIR)/$(LIBDIR)/libhspell.a
	test -d $(DESTDIR)/$(INCLUDEDIR) || mkdir -m 755 -p $(DESTDIR)/$(INCLUDEDIR)
	cp c/hspell.h c/linginfo.h $(DESTDIR)/$(INCLUDEDIR)/
	chmod 644 $(DESTDIR)/$(INCLUDEDIR)/hspell.h $(DESTDIR)/$(INCLUDEDIR)/linginfo.h

################################################
# for creating an hspell distribution tar
PACKAGE = hspell
VERSION = 0.7
DISTFILES = COPYING INSTALL LICENSE README WHATSNEW TODO \
	Makefile stats wunzip.c wzip \
	hspell.pl hspell.1 \
	wolig.pl wolig.dat biza-nouns milot extrawords \
	woo woo.dat biza-verbs \
	likelyerrors spellinghints \
	hspell.spec \
	c/Makefile c/README c/corlist.c c/dict_radix.c \
	c/dict_radix.h c/find_sizes.c c/gimatria.c c/hspell.c \
	c/hspell.h c/libhspell.c \
	c/pmerge c/PrefixBits.pl c/genprefixes.pl \
	c/hash.h c/tclHash.c c/tclHash.h \
        c/binarize-desc.pl c/pack-desc.pl c/linginfo.c c/linginfo.h \
	multispell c/hspell.3

DISTDIR = $(PACKAGE)-$(VERSION)

distdir:
	rm -rf ./$(DISTDIR)
	mkdir -m 755 $(DISTDIR)
	cp -a --parents $(DISTFILES) $(DISTDIR)
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
