CFLAGS=-O $(EXTRACFLAGS)

PERL=perl

#all: test.wgz.sizes
all: hebrew.wgz.sizes hspell

hspell: hspell.o dict_radix.o gimatria.o corlist.o tclHash.o
	cc -o hspell hspell.o dict_radix.o gimatria.o corlist.o tclHash.o

hspell.o dict_radix.o: dict_radix.h
hspell.o gimatria.o: gimatria.h
hspell.o corlist.o: corlist.h
hspell.o: prefixes.c hash.h tclHash.h
tclHash.o: tclHash.c tclHash.h

prefixes.c: genprefixes.pl
	$(PERL) -w ./genprefixes.pl >prefixes.c

find_sizes: find_sizes.o dict_radix.o
	$(CC) $(LDFLAGS) -o find_sizes find_sizes.o dict_radix.o

GZDICTS= dout.nouns.wolig.gz dout.verbs.gz dout.nouns.shemp.gz
DICTS=../milot ../extrawords ../biza-verbs ../biza-nouns


# hebrew.wgz contains all the words without any prefix hints like B,L,+ we
#   previously had. 
# hebrew.wgz.prefixes is the prefix hints (one byte per word, compressed).
# hebrew.wgz.sizes contains the memory sizes that reading hebrew.wgz will
#   require (this makes it easier for hspell to preallocate the needed sizes).
hebrew.wgz hebrew.wgz.prefixes: pmerge $(DICTS) $(GZDICTS)
	(gzip -dc $(GZDICTS); cat $(DICTS)) | ./pmerge -p hebrew.wgz.tmp | ../wzip | gzip -9 > hebrew.wgz
	-rm -f hebrew.wgz.prefixes
	gzip -9 < hebrew.wgz.tmp >hebrew.wgz.prefixes
	-rm -f hebrew.wgz.tmp
hebrew.wgz.sizes: hebrew.wgz find_sizes
	gzip -dc hebrew.wgz | ./find_sizes >hebrew.wgz.sizes


# dout.* are the outputs from the various word-list generators with the
# -d option (i.e., with an explanation on how each word was derived)
#
# The dout files are quite large, as much as 10MB. To lower the amount
# of temporary space needed during compilation (is this necessary nowadays?)
#
dout.nouns.%:  ../%.dat ../wolig.pl
	$(PERL) -w ../wolig.pl -d $< > $@
dout.nouns.%.gz:  ../%.dat ../wolig.pl
	$(PERL) -w ../wolig.pl -d $< | gzip -4 > $@
dout.nouns.shemp.gz:  shemp.dat ../wolig.pl
	$(PERL) -w ../wolig.pl -d $< | gzip -4 > $@

# SEDCMD is left here as a non-user-friendly option to choose whether you want
# over a 150,000 more rare verb forms or not. The default here is not, but the
# RPM spec builds both forms (it even plays tricks and builds out.verbs only
# once without any sed and then does the sed itself).

#SEDCMD=s/\+//
SEDCMD=/\+/d

dout.verbs.gz: ../woo ../woo.dat
	$(PERL) -w ../woo -d ../woo.dat | sed "$(SEDCMD)" | gzip -4 > $@
