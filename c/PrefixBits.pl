# Prefix specifiers currently generated:
 $PS_ALL=63;    # All legal prefixes are allowed for this word
 $PS_B=1;      # like B in hspell.pl
 $PS_L=3;      # like L in hspell.pl (note that L is more general than B)
 $PS_VERB=4;
 $PS_NONDEF=8;    # accept prefixes w/o ä
 $PS_IMPER=16;    # accept nothing/å
 $PS_MISC=32;
# These have to be bitmasks that can be or'ed easily, so that if one word
# can get prefixes of two types, it will have one combined prefix specifier
# that describes the prefixes.
#
# These prefixe spesifiers are used by genprefixes.pl to create prefixes.c 
# that is used by hspell.c

