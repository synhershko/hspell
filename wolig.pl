#!/usr/bin/perl -w
#
# Copyright (C) 2000-2002 Nadav Har'El, Dan Kenigsberg
#
#BEGIN {push @INC, (".")}
use Carp;
use FileHandle;

my ($fh,$word,$optstring,%opts);

sub outword {
  my $word = shift;
  # change otiot-sofiot in the middle of the word
  $word =~ s/ך(?=[א-ת])/כ/go;
  $word =~ s/ן(?=[א-ת])/נ/go;
  $word =~ s/ם(?=[א-ת])/מ/go;
  $word =~ s/ץ(?=[א-ת])/צ/go;
  $word =~ s/ף(?=[א-ת])/פ/go;
  print $word."\n";
}

##################################### ROUTINES FOR VERB CONJUGATION ########
#guf constants (any idea for a better declaration in perl?)
my ($ani, $ata, $at, $hu, $hi, $anu, $atem, $aten, $hem, $hen) =
        (1,2,3,4,5,6,7,8,9,10);
sub legal_guf {
  my $tense = shift;

  if ($tense==$past) {return ($ani,$ata,$hu,$hi,$anu,$atem,$aten,$hem) }
  elsif ($tense==$present) {return ($ata,$at,$atem,$aten) }
  elsif ($tense==$future) {
    return ($ani,$ata,$at,$hu,$anu,$atem,$aten,$hem) }
  elsif ($tense==$imperative) {return ($ata,$at,$atem,$aten) }
  else {return $ani};
}
# same for binyan
my @all_binyan = 
        ($qal, $nifgal, $pigel, $pugal, $hitpagel, $hifgil, $hufgal) =
        (101,102,103,104,105,106,107);
my @all_tense = 
        ($past, $present, $future, $imperative, $maqor, $shempoal) =
        (201,202,203,204,205,206,207);
## a function like this MUST exist in perl:
sub myinlist {
  my $s = shift;
  foreach $param (@_) {
    return 1 if ($param eq $s);
  }
  return 0;
}

sub sakel_hitpael {
  my $word = shift, $p = shift;
  $word =~ s/תp/pת/ if ($p =~ /ס|ש/);
  $word =~ s/תp/pד/ if ($p =~ /ז/);
  $word =~ s/תp/pט/ if ($p =~ /צ/);
  $word =~ s/תp/p/ if ($p =~ /ת|ט|ד/); 
  # todo: sometime the tav is is kept 
  return $word;
}

sub assign_root {
  my ($p, $g, $l, $word) = @_;
  $word =~ s/p/$p/;
  $word =~ s/g/$g/;
  $word =~ s/l/$l/;
  return $word;
}
sub guf_root_clash {
  my ($tense, $guf, $p, $g, $l, $naxe_base) = @_;

  if (($tense==$past) && ($l eq "ה")) {
    $naxe_base =~ s/l/י/ if ($guf =~ /$ani|$ata|$anu|$atem|$aten/); 
    $naxe_base =~ s/l/ת/ if ($guf =~ /$hi/); 
    $naxe_base =~ s/l// if ($guf =~ /$hem/); 
  }
  if (($tense==$present) && ($l eq "ה")) {
    $naxe_base =~ s/l// if ($guf =~ /$atem|$aten/); 
  }
  if (($tense==$future) && ($l eq "ה")) {
    $naxe_base =~ s/l// if ($guf =~ /$at|$hem|$atem/); 
    $naxe_base =~ s/l/י/ if ($guf =~ /$aten/); 
  }
  if (($tense==$imperative) && ($l eq "ה")) {
    $naxe_base =~ s/l// if ($guf =~ /$at|$atem/); 
    $naxe_base =~ s/l/י/ if ($guf =~ /$aten/); 
  }
  if (($tense==$shempoal) && ($l eq "ה")) {
    $naxe_base =~ s/l// if $binyan=~/$hitpagel|$nifgal/ ;
    $naxe_base =~ s/l/י/;
  }
  if (($tense==$maqor) && ($l eq "ה")) {
    if ($binyan==$qal) {$naxe_base =~ s/l/ת/}
    else {$naxe_base =~ s/l/ות/} 
  }
  return $naxe_base;
}

sub binyan_root_clash {
  my ($tense, $binyan, $p, $g, $l, $base) = @_;

  #print "tense=$tense, binyan=$binyan, base $base, hitpael=$hitpagel\n";
  $base = sakel_hitpael($base, $p) if ($binyan==$hitpagel);
  $base =~ s/י// if (length($g)>1) && ($tense==$past);
  $base =~ s/י// if myinlist($binyan, $pigel, $pugal, $hitpagel)
                   && $tense==$present;
  #all
  $base =~ s/p// if (myinlist($binyan,$hifgil,$hufgal) && 
    (($p eq "י" && $g eq "צ") || $p eq "נ") &&
    !defined($opts{"שמור_נ"})) ;
  return $base;
}

sub binyan_guf_clash {
  my ($tense, $binyan, $guf, $base) = @_;
  
  if ($tense==$past) {
    if (($binyan==$hifgil) && ($guf =~ /$ani|$ata|$at|$anu|$atem|$aten/o))
    { # 1st & 2nd persons don't get yod in hif`il
      $base =~ s/י//;
    }
  }

  if ($tense==$future) {
    if (($binyan==$nifgal) && 
        ($guf =~ /$ani|$ata|$at|$anu|$atem|$aten/o))
    { # 1st & 2nd persons don't get yod in hif`il
      $base =~ s/י//;
    }
    if ($guf==$ani) {
      $base =~ s/י// if ($binyan==$nifgal); 
      $base = "א".$base;
    }
    if ($guf =~ /$at|$atem|$hem/o && $binyan==$qal)
    { # open sylable shortens vav
      $base =~ s/ו//;
    }
  }
  if ($tense==$imperative) {
    if (($binyan==$hifgil) && myinlist($guf, $ata, $aten)) {
      $base =~ s/י//;
    } # haf`el and not haf`il
    if ($binyan==$qal && $opts{"קל_אפעול"} &&
        myinlist($guf, $at, $atem)) {
      $base =~ s/ו//;} # shimri and not shmori
  } 
  return $base;
}

sub add_guf_affix {
  my ($tense, $guf, $word) = @_;

  if ($tense==$past) {
    $suff = "תי" if ($guf==$ani);
    $suff = "ת" if ($guf==$ata);
    $suff = "" if ($guf==$hu);
    $suff = "ה" if ($guf==$hi);
    if ($guf==$anu) { #if the root ends with nun, don't double it.
      if (substr($word,-1,1) eq "ן") { $suff = "ו";}
        else { $suff = "נו";}
    }
    $suff = "תם" if ($guf==$atem);
    $suff = "תן" if ($guf==$aten);
    $suff = "ו" if ($guf==$hem);
    $word = $word.$suff;
  }

  if ($tense==$present) {
    $suff = "" if ($guf==$ata);
    $suff = "ת" if ($guf==$at);
    $suff = "ה" if ($guf==$at) && ($binyan==$hifgil); 
    $suff = "" if ($guf==$at) && ($binyan=~/$pigel|$pugal|$hitpagel|$qal/ ) && ($l eq "ה"); 
    # this was BAD, passing $l silently
    # todo: this is ugly. must suppy $binyan as param.
    # tdod: many times, both tav and he are applicable.
    $word =~ s/l/י/ if ($guf==$at) && ($binyan==$nifgal); 
    $suff = "ים" if ($guf==$atem);
    $suff = "ות" if ($guf==$aten);
    $word = $word.$suff;
  }


  if ($tense==$future) {
    $word = "ת".$word if ($guf==$ata);
    $word = "ת".$word."י" if ($guf==$at);
    # if ($binyan eq "נפ") { outword $_[0]; } 
    # todo: in nif`al, both yod and double yod are acceptable.
    $word = "י".$word if ($guf==$hu);
    $word = "נ".$word if ($guf==$anu);
    $word = "ת".$word."ו" if ($guf==$atem);
    if ($guf =~ /$aten|$hen/o) {
      $word =~ s/י// if ($binyan==$hifgil);
      if ($l eq "ן") {$word = "ת".$word."ה";}
            else {$word = "ת".$word."נה";}
    }
    $word = "י".$word."ו" if ($guf==$hem);
  }

  if ($tense==$imperative) {
    $word = $word if ($guf==$ata);  # no change
    $word = $word."י" if ($guf==$at);
    $word = $word."ו" if ($guf==$atem);
    if ($guf==$aten) {
      if ($l eq "ן") {$word = $word."ה";}
            else {$word = $word."נה";}
    }
  }
  return $word;
}
#############################################################################


my $infile;
if($#ARGV < 0){
	$infile="wolig.dat";
} else {
	$infile=$ARGV[0];
}

$fh = new FileHandle $infile, "r"
  or croak "Couldn't open data file $infile for reading";
while(<$fh>){
  print if /^#\*/;       # print these comments.
  chomp;
  next if /^#/;          # comments start with '#'.
  ($word,$optstring)=split;
  die "Type of word '".$word."' was not specified." if !defined($optstring);
  undef %opts;
  foreach $opt (split /,/o, $optstring){
    $opts{$opt}=1;
  }
  if($opts{"ע"}){
    ############################# noun ######################################
    # note that the noun may have several plural forms (see, for example,
    # hege). The default form is "im".
    my $plural_none = $opts{"יחיד"} || substr($word,-3,3) eq "יות";
    my $plural_implicit = !($opts{"ות"} || $opts{"ים"} || $opts{"יות"}
			   || $opts{"אות"} || $opts{"יים"}) && !$plural_none;
    my $plural_iot = $opts{"יות"} ||
      ($plural_implicit && (substr($word,-2,2) eq "ות"));
    my $plural_xot = $opts{"אות"};
    my $plural_ot = $opts{"ות"} ||
      ($plural_implicit && !$plural_iot && (substr($word,-1,1) eq "ה" || substr($word,-1,1) eq "ת" ));
    my $plural_im = $opts{"ים"} || ($plural_implicit && !$plural_ot && !$plural_iot);
    my $plural_iim = $opts{"יים"};
    # related singular noun forms
    outword $word; # the singular noun itself
    my $smichut=$word;
    my $arye_yud="";
    if(!$opts{"סגול_ה"}){ # replace final ה by ת, unless סגול_ה option
      # Academia's relatively-new ktiv male rule, to make smichut קריה: קריית.
      if(substr($smichut,-2,2) eq "יה" && !(substr($smichut,-3,3) eq "ייה")){
    	$smichut=substr($smichut,0,-2)."ייה"; # note ה replaced by ת below.
      }
      if(substr($smichut,-1,1) eq "ה" && !$opts{"סגול_ה"}){
        substr($smichut,-1,1)="ת";
      }
    } else {
      # Academia's ktiv male rule, to make your lion ארייך, not אריך
      if(substr($smichut,-2,2) eq "יה"){
        $arye_yud="י";
      }
    }
    #my $smichut_orig=$smichut;
    if($opts{"מיוחד_אח"}){
      # special case:
      # אח, אב, חם include an extra yod in the smichut. Note that in the
      # first person singular possessive, we should drop that extra yod.
      # For a "im" plural, it turns out to be the same inflections as the
      # plural - but this is not the case with a "ot" plural.
      outword $smichut."י-"; # smichut
      outword $smichut."י"; # possessives (kinu'im)
      outword $smichut."ינו";
      outword $smichut."יך";
      outword $smichut."יכם";
      outword $smichut."יכן";
      outword $smichut."יו";
      outword $smichut."יה";
      outword $smichut."יהן";
      outword $smichut."יהם";
    } else {
      outword $smichut."-"; # smichut
      if($opts{"מיוחד_שן"}){
      	# academia's ktiv male rules indicate that the inflections of שן
	# (at least the plural is explicitly mentioned...) should get an
	# extra yud - to make it easy to distinguish from the number שניים.
	substr($smichut,0,-1)=substr($smichut,0,-1).'י';
	substr($word,0,-1)=substr($word,0,-1).'י';
      }
      if(substr($word,-2,2) eq "אי"){
      	# in words ending with patach and then the imot kria aleph yud,
	# such as תנאי and גבאי, all the inflections (beside the base word
	# and the smichut) are as if the yud wasn't there.
	# Note that words ending with אי but not patach, like אי and סנאי,
	# should not get this treatment, so there should be an option to turn
	# it off.
	substr($word,-1,1)="";
	substr($smichut,-1,1)="";
      }
      if($opts{"סגול_ה"}){
      	# the ה is dropped from the singular inflections, except one alternate
	# inflection like מורהו (the long form of מורו):
	$smichut=substr($smichut,0,-1);
        outword $smichut.$arye_yud."הו";
      }
      outword $smichut."י"; # possessives (kinu'im)
      outword $smichut.$arye_yud."נו";
      outword $smichut.$arye_yud."ך";
      outword $smichut.$arye_yud."כם";
      outword $smichut.$arye_yud."כן";
      outword $smichut."ו";
      outword $smichut.$arye_yud."ה";
      outword $smichut.$arye_yud."ן";
      outword $smichut.$arye_yud."ם";
    }
    # related plural noun forms
    # note: don't combine the $plural_.. ifs, nor use elsif, because some
    # nouns have more than one plural forms.
    if($plural_im){
      my $xword=$word;
      if(substr($xword,-1,1) eq "ה"){
	# remove final "he" (not "tav", unlike the "ot" pluralization below)
	# before adding the "im" pluralization, unless the שמור_ת option was
	# given.
	if(!$opts{"שמור_ת"}){
	  $xword=substr($xword,0,-1);
	}
      }
      if($opts{"מיוחד_יום"}){
        # when the מיוחד_יום flag is given, we remove the second letter from
	# the word in all the plural inflections
	$xword=substr($xword,0,1).substr($xword,2);
      }
      my $xword_orig=$xword;
      if($opts{"אבד_ו"}){
	# when the אבד_ו flag was given,we remove the first "em kri'a" from
	# the word in most of the inflections. (see [1, page 42]).
	$xword =~ s/ו//o;
      }
      if($opts{"מיוחד_שוק"}){
	# when the מיוחד_שוק flag was given, we change the vowel vav to a
	# consonant vav (i.e., double vav) in most of the inflections.
	# It's nice that we need to make this change for exactly the same
	# forms we needed to do it in the אבד_ו option case.
	$xword =~ s/ו/וו/o;
      }
      outword $xword."ים";
      $smichut=$xword;
      my $smichut_orig=$xword_orig;
      outword $smichut_orig."י-"; # smichut
      #According to the academia's ktiv male rules (see [3]), the yud in
      #the "י" plural possesive is doubled.
      #outword $smichut."י";
      outword $smichut."יי"; # possessives (kinu'im)
      outword $smichut."ינו";
      outword $smichut."יך";
      outword $smichut."ייך"; # special ktiv male for the feminine
      outword $smichut_orig."יכם";
      outword $smichut_orig."יכן";
      outword $smichut."יו";
      outword $smichut."יה";
      outword $smichut_orig."יהן";
      outword $smichut_orig."יהם";
    }
    if($plural_iim){
      # I currently decided that in Hebrew, unlike Arabic, only specific
      # nouns can get the iim (zugi) pluralization, and most nouns can't,
      # e.g., חתוליים isn't correct (for "two cats") despite a story called
      # מעשה בחתוליים. This is why this is an option, and not the default.
      my $xword=$word;
      if(substr($xword,-1,1) eq "ה"){
	# Change final he into tav before adding the "iim" pluralization.
	$xword=substr($xword,0,-1)."ת";
      }
      my $xword_orig=$xword;
      outword $xword."יים";
      $smichut=$xword;
      my $smichut_orig=$xword_orig;
      outword $smichut_orig."י-"; # smichut
      #According to the academia's ktiv male rules (see [3]), the yud in
      #the "י" plural possesive is doubled.
      #outword $smichut."י"; # possessives (kinu'im)
      outword $smichut."יי"; # possessives (kinu'im)
      outword $smichut."ינו";
      outword $smichut."יך";
      outword $smichut."ייך"; # special ktiv male for the feminine
      outword $smichut_orig."יכם";
      outword $smichut_orig."יכן";
      outword $smichut."יו";
      outword $smichut."יה";
      outword $smichut_orig."יהן";
      outword $smichut_orig."יהם";
    }
    if($plural_ot){
      my $xword=$word;
      if(substr($xword,-1,1) eq "ה" || substr($xword,-1,1) eq "ת"){
	# remove final "he" or "tav" before adding the "ot" pluralization,
	# unless the שמור_ת option was given.
	if(!$opts{"שמור_ת"}){
	  $xword=substr($xword,0,-1);
	}
      }
      if(substr($xword,-2,2) eq "וו" || substr($xword,-2,2) eq "יי" ){
	# KTIV MALE RULE (should be optional? I'm not sure I agree with them
	# because they make reading ambiguous in exactly the same was a vav
	# or yud was supposed to make not ambiguous).
	# We conveniently apply here two of the Academia's rules of "ktiv
	# male" (as described in [3]):
	# 1) a consonent vav should be doubled, but not when followed by
	#    another vav (so that we don't get 3 vavs in a row). Example מצווה.
	# 2) don't write yud before yud-vav signifying yu or yo. Example עירייה
	# Note that we do this after the ה rule above.
	$xword=substr($xword,0,-1);
      }
      my $xword_orig=$xword;
      if($opts{"אבד_ו"}){
	# when the אבד_ו flag was given,we remove the first "em kri'a" from
	# the word in most of the inflections. (see [1, page 42]).
	$xword =~ s/ו//o;
      }
      if($opts{"מיוחד_שוק"}){
	# when the מיוחד_שוק flag was given, we change the vowel vav to a
	# consonant vav (i.e., double vav) in most of the inflections.
	# It's nice that we need to make this change for exactly the same
	# forms we needed to do it in the אבד_ו option case.
	$xword =~ s/ו/וו/o;
	#$xword =~ s/י/יי/o;
      }
      outword $xword."ות";
      $smichut=$xword."ות";
      my $smichut_orig=$xword_orig."ות";
      outword $smichut_orig."-"; # smichut
      #According to the academia's ktiv male rules (see [3]), the yud in
      #the "י" plural possesive is doubled.
      #outword $smichut."י"; # possessives (kinu'im)
      outword $smichut."יי"; # possessives (kinu'im)
      outword $smichut."ינו";
      outword $smichut."יך";
      outword $smichut."ייך"; # special ktiv male for the feminine
      outword $smichut_orig."יכם";
      outword $smichut_orig."יכן";
      outword $smichut."יו";
      outword $smichut."יה";
      outword $smichut_orig."יהן";
      outword $smichut_orig."יהם";
    }
    if($plural_iot){
      my $xword=$word;
      if(substr($xword,-1,1) eq "ה" || substr($xword,-1,1) eq "ת"){
	# remove final "he" or "tav" before adding the "iot" pluralization,
	# unless the שמור_ת option was given.
	if(!$opts{"שמור_ת"}){
	  $xword=substr($xword,0,-1);
	}
	# remove the letter before that in the special case of the words
	# אחות, חמות - in that case the "iot" replaces not only the tav,
	# but also the vav before it.
	if($opts{"מיוחד_אחות"}){
	  $xword=substr($xword,0,-1);
	}
      }
      outword $xword."יות";
      $smichut=$xword."יות";
      outword $smichut."-"; # smichut
      #According to the academia's ktiv male rules (see [3]), the yud in
      #the "י" plural possesive is doubled.
      #outword $smichut."י"; # possessives (kinu'im)
      outword $smichut."יי"; # possessives (kinu'im)
      outword $smichut."ינו";
      outword $smichut."יך";
      outword $smichut."ייך"; # special ktiv male for the feminine
      outword $smichut."יכם";
      outword $smichut."יכן";
      outword $smichut."יו";
      outword $smichut."יה";
      outword $smichut."יהן";
      outword $smichut."יהם";
    }
    if($plural_xot){
      my $xword=$word;
      if(substr($xword,-1,1) eq "ה" || substr($xword,-1,1) eq "ת"){
	# remove final "he" or "tav" before adding the "xot" pluralization,
	# unless the שמור_ת option was given.
	if(!$opts{"שמור_ת"}){
	  $xword=substr($xword,0,-1);
	}
      }
      outword $xword."אות";
      $smichut=$xword."אות";
      outword $smichut."-"; # smichut
      #According to the academia's ktiv male rules (see [3]), the yud in
      #the "י" plural possesive is doubled.
      #outword $smichut."י"; # possessives (kinu'im)
      outword $smichut."יי"; # possessives (kinu'im)
      outword $smichut."ינו";
      outword $smichut."יך";
      outword $smichut."ייך"; # special ktiv male for the feminine
      outword $smichut."יכם";
      outword $smichut."יכן";
      outword $smichut."יו";
      outword $smichut."יה";
      outword $smichut."יהן";
      outword $smichut."יהם";
    }
  } elsif($opts{"ת"}){
    ############################# adjective ##################################
    my $xword=$word;
    if(substr($xword,-1,1) eq "ה"){
      # remove final "he" before adding the pluralization,
      # unless the שמור_ה option was given.
      if(!$opts{"שמור_ה"}){
	$xword=substr($xword,0,-1);
      }
    }
    outword $word; # masculin, singular
    outword $word."-"; # smichut (exactly the same as nifrad)
    # feminine, singular:
    if(substr($xword,-1,1) eq "י" || $opts{"נקבה_ת"}){
      outword $xword."ת";
      outword $xword."ת-"; # smichut (exactly the same as nifrad)
    } else {
      outword $xword."ה";
      outword $xword."ת-"; # smichut
    }
    if($opts{"ם"}){
      # special case for adjectives like רשאי. Unlike the noun case where we
      # turn this option automatically for words ending with אי, here such a
      # default would not be useful because a lot of nouns ending with ה or א
      # correspond to adjectives ending with אי that this rule doesn't fit.
      outword $xword."ם"; # masculin, plural
      outword $xword."-"; # smichut
    } else {
      outword $xword."ים"; # masculin, plural
      outword $xword."י-"; # smichut
    }
    outword $xword."ות"; # feminine, plural
    outword $xword."ות-"; # smichut (exactly the same as nifrad)
  } elsif($opts{"פ"}){
    ################################ verb ####################################
    my $p=substr($word,0,1), $g=substr($word,1,length($word)-2),
       $l=substr($word,-1,1);

    undef %base;
    $base{$past,$qal}="pgl" if ($opts{"קל_אפעל"}||$opts{"קל_אפעול"});
    $base{$past,$nifgal}="נpgl" if ($opts{"נפ"});
    $base{$past,$hifgil}="הpgיl" if ($opts{"הפ"});
    $base{$past,$hufgal}="הוpgl" if ($opts{"הו"});
    $base{$past,$pigel}="pיgl" if ($opts{"פי"});
    $base{$past,$pugal}="pוgl" if ($opts{"פו"});
    $base{$past,$hitpagel}="התpgl" if ($opts{"הת"});
    
    $base{$present,$qal}="pוgl" if ($opts{"קל_אפעל"}||$opts{"קל_אפעול"});
    $base{$present,$nifgal}="נpgl" if ($opts{"נפ"});
    $base{$present,$hifgil}="מpgיl" if ($opts{"הפ"});
    $base{$present,$hufgal}="מוpgl" if ($opts{"הו"});
    $base{$present,$pigel}="מpgl" if ($opts{"פי"});
    $base{$present,$pugal}="מpוgl" if ($opts{"פו"});
    $base{$present,$hitpagel}="מתpgl" if ($opts{"הת"});
    
    $base{$future,$qal}="pgl" if ($opts{"קל_אפעל"});
    $base{$future,$qal}="pgוl" if ($opts{"קל_אפעול"});
    $base{$future,$nifgal}="יpgl" if ($opts{"נפ"});
    $base{$future,$hifgil}="pgיl" if ($opts{"הפ"});
    $base{$future,$hufgal}="וpgl" if ($opts{"הו"});
    $base{$future,$pigel}="pgl" if ($opts{"פי"});
    $base{$future,$pugal}="pוgl" if ($opts{"פו"});
    $base{$future,$hitpagel}="תpgl" if ($opts{"הת"});
     
    $base{$imperative,$qal}="pgl" if ($opts{"קל_אפעל"});
    $base{$imperative,$qal}="pgוl" if ($opts{"קל_אפעול"});
    # shouldn't be with yod? - הישמר או השמר? 
    $base{$imperative,$nifgal}="היpgl" if ($opts{"נפ"});
    $base{$imperative,$hifgil}="הpgיl" if ($opts{"הפ"});
    $base{$imperative,$qal}="pgוl" if ($opts{"אפעול"});
    $base{$imperative,$pigel}="pgl" if ($opts{"פי"});
    $base{$imperative,$hitpagel}="התpgl" if ($opts{"הת"});
    
    $base{$shempoal,$qal}="pgיlה" if ($opts{"קל_אפעל"}||$opts{"קל_אפעול"});
    $base{$shempoal,$nifgal}="היpglות" if ($opts{"נפ"});
    $base{$shempoal,$hifgil}="הpglה" if ($opts{"הפ"});
    $base{$shempoal,$pigel}="pיgוl" if ($opts{"פי"});
    # todo: this does not always exist: "shiqur" 
    # quod-roots should not get yod:
    $base{$shempoal,$pigel}="pgוl" if ($opts{"פי"} && length($g)>1);
    $base{$shempoal,$hitpagel}="התpglות" if ($opts{"הת"});
 
    $base{$maqor,$qal}="לpgוl" if ($opts{"קל_אפעל"}||$opts{"קל_אפעול"});
    $base{$maqor,$qal}="לpgl" if ($opts{"לרכב"}); # a very rare exception
    $base{$maqor,$nifgal}="להיpgl" if ($opts{"נפ"});
    $base{$maqor,$hifgil}="להpgיl" if ($opts{"הפ"});
    $base{$maqor,$pigel}="לpgl" if ($opts{"פי"});
    $base{$maqor,$hitpagel}="להתpgl" if ($opts{"הת"});
    
    foreach $tense (@all_tense) {
      foreach $binyan (@all_binyan) {
        $base = $base{$tense,$binyan};
        next unless defined($base); #no such conjugation..
        $naxe_base = binyan_root_clash($tense, $binyan, $p, $g, $l, $base);
        foreach $guf (legal_guf($tense)) {
          $naxe = guf_root_clash($tense, $guf, $p, $g, $l, $naxe_base);
          $conj_base = binyan_guf_clash($tense, $binyan, $guf, $naxe);
#          $asgn_base = assign_root($p, $g, $l, $conj_base);
#          $affx_base = add_guf_affix($tense, $guf, $asgn_base);
#          outword $affx_base;
          $affx_base = add_guf_affix($tense, $guf, $conj_base);
          $asgn_base = assign_root($p, $g, $l, $affx_base);
          outword $asgn_base;
        }
      }
    }
  } else {
    die "word '".$word."' was not specified as noun, adjective or verb.";
  }
  outword "-------"
}
