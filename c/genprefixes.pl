#!/usr/bin/perl -w

my %prefixes;
my $INQUISITIVE_HE=0;
my ($mask,$prefix);
#my ($PS_BIT_L,$PS_BIT_B,$PS_BIT_VERB,$PS_BIT_NONDEF,$PS_BIT_IMPER,$PS_BIT_MISC)= (1,2,4,8,16,32);
require "PrefixBits.pl";

foreach $W ('','ו')
{foreach $S ('','ה','ש')
{foreach $K ('','כש','מש','לכש')
{foreach $k ('','כ')
{foreach $B ('','ב','ה','כ','ל','מ','מה')
{next if (!$INQUISITIVE_HE && $S eq 'ה');
next if ($k eq 'כ' && $B eq 'ה');
$prefix = "$W$S$K$k$B";
$mask = $PS_MISC;
$mask |= $PS_L if $B =~ m/[בכלמ]$/;
$mask |= $PS_B if $prefix =~ m/^ו?ש?ב$/;
$mask |= $PS_VERB if ($k eq "" && $B eq "");
$mask |= $PS_NONDEF if $B !~ m/ה$/;
$prefixes{$prefix} = 0 if !defined $prefixes{$prefix};
$prefixes{$prefix} |= $mask;
}}}}}

foreach $W ('','ו')
{foreach $S ('','ה','ש')
{foreach $K ('','כש','מש','לכש')
{foreach $B ('','ב','ל','מ')
{foreach $k ('','כ')
{next if (!$INQUISITIVE_HE && $S eq 'ה');
$prefix = "$W$S$K$B$k";
$mask = $PS_MISC;
$mask |= $PS_L if $B =~ m/[בכלמ]$/;
$mask |= $PS_B if $prefix =~ m/^ו?ש?ב$/;
$mask |= $PS_VERB if ($k eq "" && $B eq "");
$mask |= $PS_NONDEF if $B !~ m/ה$/;
$prefixes{$prefix} = 0 if !defined $prefixes{$prefix};
$prefixes{$prefix} |= $mask;
}}}}}

foreach $B ('ב','ל')
{$prefix = "מ$B";
$mask = $PS_MISC;
$mask |= $PS_L if $B =~ m/[בכלמ]$/;
$mask |= $PS_B if $prefix =~ m/^ו?ש?ב$/;
$mask |= $PS_NONDEF if $B !~ m/ה$/;
$prefixes{$prefix} = 0 if !defined $prefixes{$prefix};
$prefixes{$prefix} |= $mask;
}

$prefixes{""} |= $PS_IMPER;
$prefixes{"ו"} |= $PS_IMPER;

print "static char *prefixes[]={";
foreach (sort keys %prefixes) {print "\"$_\",\n"}
print "0};\n";

print "static int masks[]={";
foreach (sort keys %prefixes) {print "$prefixes{$_},\n"}
print "-1};\n";

