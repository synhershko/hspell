# notice: you must --define either 'fat 0' or 'fat 1' in order to build this rpm
# second notice: in order to force the rpm not to require perl (although it
# contains Mooffie's multispell), you should build it with:

%define __find_requires /tmp/noperl-find-requires
%define _use_internal_dependency_generator 0

# where /tmp/noperl-find-requires does /usr/lib/rpm/find-requires|grep -v perl
# Thanks to Tzafrir Cohen for this hack

%if %{fat}
  %define fname hspell-fat
  %define conf --enable-fatverb --enable-linginfo
%else
  %define fname hspell
  %define conf ''
%endif

Summary: a hebrew spell checker
Name: %fname
Version: 0.9
Release: 1
Vendor:	Ivrix
Packager: Dan Kenigsberg <danken@cs.technion.ac.il>
URL: http://ivrix.org.il/projects/spell-checker/
Source: hspell-%{version}.tar.gz
License: GPL
Group: Applications/Text
BuildRoot: %{_tmppath}/%{name}-root
Obsoletes: hspell-fat hspell

%description
hspell is a Hebrew SPELLer . It currently provides a mostly spell-like 
interface (gives the list of wrong words in the input text), but can also 
suggest corrections (-c)

The "fat" version of this RPM provides a true (yet incomplete) morphological
analizer (-l), that prints all known meanings of a Hebrew string.

Note: it is a fully working Hebrew spellchecker, not a toy release. On typical
documents it should recognize the majority of correct words. However, users
of this release must take into account that it still will not recognize *all*
the correct words; The dictionary is still admittedly not complete, and this
situation will continue to improved in the next releases. On the other hand, 
barring bugs hspell should not recognize incorrect words - extreme attention
has been given to the correctness and consistency of the dictionary.

%description -l he
hspell הוא מאיית עברי, המספק (בינתיים) מנשק דמוי-spell - פולט רשימה של המילים
השגויות המופיעות בקלט. זו גרסה פועלת, אולם היא איננה שלמה עדיין - מילים תקניות
רבות אינן מוכרות והן מדווחות כשגיאות. הקפדנו מאוד על-מנת שמילים שהיא *כן* מכירה
יאויתו שכונה על-פי כללי האקדמיה העברית לכתיב חסר ניקוד )"כתיב מלא"(.

הגרסה ה"שמנה" של RPM זה, מספקת (-l) מנתח מורפולוגי אמתי (אם-כי לא שלם) אשר
מדפיס את כל המשמעויות האפשריות של מחרוזת אותיות עברית.

%prep
%setup -q -n hspell-%{version}

%build
./configure --prefix=%_prefix --mandir=%_mandir %conf
make CFLAGS="$RPM_OPT_FLAGS"

%install
rm -rf %buildroot
make prefix=%buildroot%_prefix MAN1=%buildroot%_mandir/man1  \
	MAN3=%buildroot%_mandir/man3 install

##for debuging the spec file - skip dictionary creation:
#mkdir -p %buildroot%{_prefix}/{bin,share/man/man1,share/man/man3,share/hspell,lib,include}
#touch %buildroot%{_prefix}/{bin/hspell,bin/hspell-i,bin/multispell,lib/libhspell.a,include/hspell.h,share/hspell/hebrew.wgz,share/hspell/hebrew.wgz.desc,share/hspell/hebrew.wgz.prefixes,share/hspell/hebrew.wgz.sizes,share/hspell/hebrew.wgz.stems,share/man/man1/hspell.1,share/man/man3/hspell.3}

# We don't need developers' stuff in the distribution RPM
#rm %buildroot%_prefix/{include/*.h,lib/libhspell.a} \
#	%buildroot%_mandir/man3/hspell.3

echo -e "#\!/bin/sh\n/usr/lib/rpm/find-requires|grep -v perl" \
	 >/tmp/noperl-find-requires
chmod a+x /tmp/noperl-find-requires

%clean
rm -rf %buildroot

%files
%defattr(-,root,root)
%doc LICENSE README WHATSNEW
%{_bindir}/hspell
%{_bindir}/hspell-i
%{_bindir}/multispell
%{_mandir}/man1/hspell.1*
%{_datadir}/hspell/*

#########################################################

%package devel

Summary: Library and include files for hspell, thehebrew spell checker
Group: Applications/Text

%description devel
Library and include files for applications that want to use hspell.

%files devel
%_includedir/*.h
%_libdir/libhspell.a
%_mandir/man3/hspell.3*

%changelog
* Fri Jun  4 2004 Dan Kenigsberg <danken@cs.technion.ac.il> 0.8-1
- Some cleanups, and a devel package
* Fri Dec 20 2003 Dan Kenigsberg <danken@cs.technion.ac.il> 0.7-1
- Changes for version 0.7
* Tue Jul 29 2003 Dan Kenigsberg <danken@cs.technion.ac.il> 0.6-1
- Tiny changes for the C frontend
* Fri May  2 2003 Dan Kenigsberg <danken@cs.technion.ac.il> 0.5-1
- create the "fat" variant
* Mon Feb 17 2003 Dan Kenigsberg <danken@cs.technion.ac.il> 0.3-2
- The release includes only the compressed database.
- Added signature, and some other minor changes.
* Sun Jan  5 2003 Tzafrir Cohen <tzafrir@technion.ac.il> 0.2-1
- Initial build.

