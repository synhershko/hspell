/* Copyright 2004 Nadav Har'El and Dan Kenigsberg */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "prefixes.c"
#include "hspell.h"

/* this little program creates aspell affix information for Hebrew according to
 * the hebrew.wgz*. This version creates a single rule for each of hspell's
 * "word specifier". Each rule expands to all the prefixes that provide that
 * specifier (excluding the null prefix, which is currently implied.)  */

int main(void) {
  int i, specifier;
  char seen_specifiers[100], rulechar;
  int already_seen=0, seen, count;
  FILE *prefixfp, *wordsfp, *hefp;
  int prefixes_size;
  char *prefix_is_word;

  hefp = fopen("he_affix.dat", "w");
  fprintf(hefp, "# This file was generated automatically from data prepared\n"
                "# by the Hspell project (http://ivrix.org.il/projects/spell-"
                "checker).\n# Hspell version %d.%d%s was used.\n"
                "# The conversion was carried out in %s\n",
          HSPELL_VERSION_MAJOR,HSPELL_VERSION_MINOR,HSPELL_VERSION_EXTRA,
          __DATE__); 
  fprintf(hefp, "# Copyright 2004, Nadav Har'El and Dan Kenigsberg\n"); 
  fprintf(hefp, "# This dictionary (this file and the corresponding word list)\n"
                "# is licensed under the GNU General Public License (GPL)\n"); 

  prefixfp = popen("gzip -dc hebrew.wgz.prefixes", "r");
  while ((specifier=fgetc(prefixfp))!= EOF) {
    for(i=0, seen=0; (i<already_seen) && !seen; i++) {
      if (seen_specifiers[i] == specifier) seen = 1; }
    if (seen) continue;
    seen_specifiers[already_seen++] = specifier;

    /* count the number of matching prefixes */
    for (i=1, count=0; prefixes_noH[i]!=0; i++) {
      if (masks_noH[i] & specifier) {
        if (!strcmp("ו",prefixes_noH[i])) count += 2;
        else count += 4;
      }
    }
    rulechar = already_seen+'A'-1;
    fprintf(hefp, "PFX %c N %d\n",rulechar,count);

    /* print one rule for each leagal prefix, and remember to double initial waw
       if a prefix is prepended. */

    /* the empty string is 0 in aspell. currently, it is implied, and cannot be
       removed. In one condition it causes what can be called a bug - hspell
       accpets the maqor natuy such as בהמשיכם only with a prefix. aspell
       accepts also המשיכם. Note that this could be considered a feature, since
       it is a perfectly legal, though out-dated form. */
    /* fprintf(hefp, "PFX %c   0 0 .\n",already_seen+'A'-1); */
    for (i=1; prefixes_noH[i]!=0; i++) {
      if (masks_noH[i] & specifier) {
        if (!strcmp("ו",prefixes_noH[i])) {
          fprintf(hefp, "PFX %c   0 %s .\n",rulechar,prefixes_noH[i]);
          fprintf(hefp, "PFX %c   0 %s\" .\n",rulechar,prefixes_noH[i]);
        }
        else {
          fprintf(hefp, "PFX %c   0 %s [^ו]\n",rulechar,prefixes_noH[i]);
          fprintf(hefp, "PFX %c   0 %s וו\n",rulechar,prefixes_noH[i]);
          fprintf(hefp, "PFX %c   0 %s\" .\n",rulechar,prefixes_noH[i]);
          fprintf(hefp, "PFX %c   0 %sו ו[^ו]\n",rulechar,prefixes_noH[i]);
        }
      }
    }
    prefixes_size = i;
    fprintf(hefp, "\n");
  }
  pclose(prefixfp);
  fclose(hefp);

  prefix_is_word = (char *)calloc(sizeof(char),prefixes_size);
 
  /* and now, translate hebrew.wgz+hebrew.wgz.prefix into aspell-style word
   * list. */

  prefixfp = popen("gzip -dc hebrew.wgz.prefixes", "r");
  wordsfp = popen("gzip -dc hebrew.wgz|./wunzip", "r");

  while ((specifier=fgetc(prefixfp))!= EOF) {
    char word[100];
    int len, j;
    /* find the specifier place (which infers which aspell rule apply to its
     * word) */
    for(i=0; (i<already_seen) && (seen_specifiers[i]!=specifier) ; i++);
    fgets(word, sizeof(word)-3,wordsfp);

    /* write down whether this word is also a legal prefix (and therefore should
       not be written again later)  */
    for (j=1; prefixes_noH[j]!=0; j++) {
      if (!strcmp(word,prefixes_noH[j])) {
        prefix_is_word[j] = 1;
        break;
      }
    }

    len=strlen(word);
    word[len-1]='/';
    word[len]=i+'A';
    word[len+1]='\n';
    word[len+2]=0;
    printf("%s",word);
  }
  pclose(prefixfp);
  pclose(wordsfp);

  /* accept "dangling" prefixes, that many times precede numbers and latin */
  /* but make sure not to repeat words that already appear in the dictionary.
   * This may cause unwanted warning. */
  /* BUG: in my weeding of prefixes that already appeared, I assume that the
     blank prefix is always allowed. When this cedes to be the case, we would
     to do something more complicated */
  for (i=1; prefixes_noH[i]!=0; i++) {
    if (!prefix_is_word[i])
      printf("%s\n", prefixes_noH[i]);
  }
  free(prefix_is_word);
  return 0;
}

