all: out.nouns out.verbs out.nouns-shemp

out.nouns: wolig.pl wolig.dat
	./wolig.pl > out.nouns

out.nouns-shemp: wolig.pl shemp.dat
	./wolig.pl shemp.dat > out.nouns-shemp

shemp.dat out.verbs: woo woo.dat
	./woo > out.verbs

CFLAGS=-O
LDFLAGS=-s
wunzip:

################################################

DICTS= out.nouns out.verbs out.nouns-shemp milot extrawords biza-verbs biza-nouns
wordlist.wgz: $(DICTS) wzip
	grep -h "^[à-ú]" $(DICTS) | tr -d '-' | sort -u | wzip | gzip -9 \
		> wordlist.wgz

################################################
PREFIX=/usr/local
BIN=$(PREFIX)/bin
SHARE=$(PREFIX)/share/hspell
LIBEXEC=$(PREFIX)/lib/hspell
install: $(DICTS) likelyerrors
	sed 's+^my @dictionaries=.*$$+my @dictionaries=("$(SHARE)/out.nouns","$(SHARE)/out.nouns-shemp","$(SHARE)/out.verbs","$(SHARE)/milot","$(SHARE)/extrawords","$(SHARE)/biza-verbs","$(SHARE)/biza-nouns");+; s+my @likelyerror.*$$+my @likelyerror_dictionaries=("$(SHARE)/likelyerrors");+' < hspell.pl > $(BIN)/hspell
	chmod 755 $(BIN)/hspell
	test -d $(SHARE) || mkdir $(SHARE)
	chmod 755 $(SHARE)
	cp $(DICTS) likelyerrors $(SHARE)/
	(cd $(SHARE); chmod 644 $(DICTS) likelyerrors)
	
# This will create a much smaller installation (60K instead of 1MB) but the
# -v option (for viewing the reasons for words' *correctness*) will not be
# available.
install_compressed: wordlist.wgz likelyerrors wunzip
	sed 's+^my @dictionaries=.*$$+my @dictionaries=("zcat $(SHARE)/wordlist.wgz|$(LIBEXEC)/wunzip|");+; s+my @likelyerror.*$$+my @likelyerror_dictionaries=("$(SHARE)/likelyerrors");+' < hspell.pl > $(BIN)/hspell
	chmod 755 $(BIN)/hspell
	test -d $(SHARE) || mkdir $(SHARE)
	chmod 755 $(SHARE)
	cp wordlist.wgz likelyerrors $(SHARE)/
	(cd $(SHARE); chmod 644 wordlist.wgz likelyerrors)
	test -d $(LIBEXEC) || mkdir $(LIBEXEC)
	chmod 755 $(LIBEXEC)
	cp wunzip $(LIBEXEC)
	chmod 755 $(LIBEXEC)/wunzip
