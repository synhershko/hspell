/* Copyright (C) 2003 Nadav Har'El and Dan Kenigsberg */

#include <stdio.h>
#include <sys/types.h>
#include <stdlib.h>
#include <assert.h>
#include <unistd.h>
#include <string.h>

#include "hash.h"
#include "hspell.h"
#ifdef USE_LINGINFO
#include "linginfo.h"
#endif

/* load_personal_dict tries to load ~/.hspell_words and ./hspell_words.
   Currently, they are read into a hash table, where each word in the
   file gets a non-zero value.
   Empty lines starting with # are ignored. Lines containing non-Hebrew
   characters aren't ignored, but they won't be tried as questioned words
   anyway.
*/
static void
load_personal_dict(hspell_hash *personaldict)
{
	int i;
	hspell_hash_init(personaldict);
	for(i=0; i<=1; i++){
		char buf[512];
		FILE *fp;
		if(i==0){
			char *home = getenv("HOME");
			if(!home) continue;
			snprintf(buf, sizeof(buf),
				 "%s/.hspell_words", home);
		} else
			snprintf(buf, sizeof(buf), "./hspell_words");
		fp=fopen(buf, "r");
		if(!fp) continue;
		while(fgets(buf, sizeof(buf), fp)){
			int l=strlen(buf);
			if(buf[l-1]=='\n')
				buf[l-1]='\0';
			if(buf[0]!='#' && buf[0]!='\0')
				hspell_hash_incr_int(personaldict, buf);
		}
		fclose(fp);
	}
}

/* load_spelling_hints reads the spelling hints file (for the -n option).
   This is done in a somewhat ad-hoc manner. In particular, the repeat
   of the DICTIONARY_BASE here, also present in libhspell.c, is unfortunate.
*/

#ifndef DICTIONARY_BASE
#define DICTIONARY_BASE "./hebrew.wgz"
#endif
char *flathints;
int flathints_size;
void load_spelling_hints(hspell_hash *spellinghints) {
	FILE *fp;
	char s[1000];
	int len=0;
	int thishint=0;

	hspell_hash_init(spellinghints);

	flathints_size = 8192; /* initialize size (will grow as necessary) */
	flathints = (char *)malloc(flathints_size);
	/*flathints[0]=0;*/

	snprintf(s,sizeof(s),"gzip -dc '%s.hints'",DICTIONARY_BASE);
	fp = popen(s, "r");
	if(!fp) {
		fprintf(stderr,"Failed to open %s\n",s);
		return;
	}
	while(fgets(s, sizeof(s), fp)){
		int l=strlen(s);
		if(s[0]=='+') { /* this is a textual description line */
			if(!thishint){
				thishint=len;
			}
			/* reallocate the array, if no room */
			while(len+l >= flathints_size){
				flathints_size *= 2;
				flathints= (char *)
					realloc(flathints,flathints_size);
			}
			/* replace the '+' character by a space (this was
			   the way hints were printed in version 0.5, and
			   wee keep it for backward compatibility */
			s[0]=' ';
			/*strncpy(flathints+len, s, flathints_size-len);*/
			strcpy(flathints+len, s);
			len += l;
		} else if(s[0]=='\n'){ /* no more words for this hint */
			thishint = 0;
			len++;
		} else { /* another word for this hint */
			s[l-1]=0;
			hspell_hash_set_int(spellinghints, s, thishint);
		}
       }
       pclose(fp);
}


/* used for sorting later: */
static int 
compare_key(const void *a, const void *b){
	register hspell_hash_keyvalue *aa = (hspell_hash_keyvalue *)a;
	register hspell_hash_keyvalue *bb = (hspell_hash_keyvalue *)b;
	return strcmp(aa->key, bb->key);
}
static int 
compare_value_reverse(const void *a, const void *b){
	register hspell_hash_keyvalue *aa = (hspell_hash_keyvalue *)a;
	register hspell_hash_keyvalue *bb = (hspell_hash_keyvalue *)b;
	if(aa->value < bb->value)
		return 1;
	else if(aa->value > bb->value)
		return -1;
	else return 0;
}

static FILE *
next_file(int *argcp, char ***argvp)
{
	FILE *ret=0;
	if(*argcp<=0)
		return 0;
	while(*argcp && !ret){
		ret=fopen((*argvp)[0],"r");
		if(!ret)
			perror((*argvp)[0]);
		(*argvp)++;
		(*argcp)--;
	}
	return ret;
}


#define VERSION_IDENTIFICATION ("@(#) International Ispell Version 3.1.20 " \
			       "(but really Hspell/C %d.%d%s)\n")

#define ishebrew(c) ((c)>=(int)(unsigned char)'א' && (c)<=(int)(unsigned char)'ת')

int notify_split(const char *w, const char *baseword, int preflen, int prefspec)
{
	char *desc,*stem;
	if(preflen>0){
		printf("צירוף חוקי: %.*s+%s\n",
		       preflen, w, baseword);
	} else if (!preflen){
		printf("מילה חוקית: %s\n",w);
	}
#ifdef USE_LINGINFO
	if (linginfo_lookup(baseword,&desc,&stem)) {
		int j;
		for (j=0; ;j++) {
			char buf[80];
			if (!linginfo_desc2text(buf, desc, j)) break;
			if (linginfo_desc2ps(desc, j) & prefspec) {
				printf("\t%s(%s)",linginfo_stem2text(stem,j),buf);
				if (hspell_debug) printf("\t%d",linginfo_desc2ps(desc, j));
				printf("\n");
			}
		}
	}
#endif
	return 1;
}
	
int
main(int argc, char *argv[])
{
	struct dict_radix *dict;
#define MAXWORD 30
	char word[MAXWORD+1], *w;
	int wordlen=0, offset=0, wordstart;
	int c;
	int res;
	FILE *slavefp;
	int terse_mode=0;
	hspell_hash wrongwords;
	int preflen; /* used by -l */
	hspell_hash personaldict;
	hspell_hash spellinghints;

	/* command line options */
	char *progname=argv[0];
	int interpipe=0; /* pipe interface (ispell -a like) */
	int slave=0;  /* there's a slave ispell process (-i option) */
	int opt_s=0; /* -s option */
	int opt_c=0; /* -c option */
	int opt_l=0; /* -l option */
	int opt_v=0; /* -v option (show version and quit) */
	int opt_H=0; /* -H option (allow he ha-she'ela) */
	int opt_n=0; /* -n option (provide spelling hints) */

	/* TODO: when -a is not given, allow filename parameters, like
	   the "spell" command does. */
	FILE *in=stdin;

	/* Parse command-line options */
	while((c=getopt(argc, argv, "clnsviad:BmVhT:CSPp:w:W:H"))!=EOF){
		switch(c){
		case 'a':
			interpipe=1;
			break;
		case 'i':
			slave=1;
			break;
		/* The following options do something on ispell or aspell,
		   and some confused programs call hspell with them. We just
		   ignore them silently, hoping that all's going to be well...
		*/
		case 'd': case 'B': case 'm': case 'T': case 'C': case 'S':
		case 'P': case 'p': case 'w': case 'W':
			/*fprintf(stderr, "Warning: ispell options -d, -B and "
			  "-m are ignored by hspell.\n");*/
			break;
		case 's':
			opt_s=1;
			break;
		case 'c':
			opt_c=1;
			break;
		case 'l':
			opt_l=1;
			break;
		case 'H':
			/* Allow "he ha-she'ela" */
			opt_H=1;
			break;
		case 'n':
			opt_n=1;
			break;
		case 'v':
			opt_v++;
			break;
		case 'V':
			printf("Hspell %d.%d%s\nWritten by Nadav Har'El and "
			       "Dan Kenigsberg\n", HSPELL_VERSION_MAJOR,
			       HSPELL_VERSION_MINOR, HSPELL_VERSION_EXTRA);
			return 0;
		case 'h': case '?':
			fprintf(stderr,"hspell - Hebrew spellchecker\n"
				"Usage: %s [-acinslV] [file ...]\n\n"
				"See hspell(1) manual for a description of "
				"hspell and its options.\n", progname);
			return 1;
		}
	}
	argc -= optind;
	argv += optind;

	/* The -v option causes ispell to print its current version
	   identification on the standard output and exit. If the switch is
	   doubled, ispell will also print the options that it was compiled
	   with.
	*/
	if(opt_v){
		printf(VERSION_IDENTIFICATION, HSPELL_VERSION_MAJOR,
		       HSPELL_VERSION_MINOR, HSPELL_VERSION_EXTRA);
		return 0;
	}

	/* If the program name ends with "-i", we enable the -i option.
	   This ugly hack is useful when a certain application can be given
	   a different spell-checker, but not extra options to pass to it */
	if(strlen(progname)>=2 && progname[strlen(progname)-2] == '-' &&
	   progname[strlen(progname)-1] == 'i'){
		slave=interpipe=1;
	}
	
	if(interpipe){
		/* for ispell -a like behavior, we want to flush every line: */
		setlinebuf(stdout);
	} else {
		/* No "-a" option: UNIX spell-like mode: */

		/* Set up hash-table for remembering the wrong words seen */
		hspell_hash_init(&wrongwords);

		/* If we have any more arguments, treat them as files to
		   spellcheck. Otherwise, just use stdin as set above.
		*/
		if(argc){
			in=next_file(&argc, &argv);
			if(!in)
				return 1; /* nothing to do, really... */
		}
	}

	if(hspell_init(&dict, (opt_H ? HSPELL_OPT_HE_SHEELA : 0) |
			      (opt_l ? HSPELL_OPT_LINGUISTICS : 0))<0){
		fprintf(stderr,"Sorry, could not read dictionary. Hspell "
			"was probably installed improperly.\n");
		return 1;
	}
	load_personal_dict(&personaldict);

	if(opt_n)
		load_spelling_hints(&spellinghints);

	if(interpipe){
		if(slave){
			/* We open a pipe to an "ispell -a" process, letting
			   it output directly to the user. We also let it
			   output its own version string instead of ours. Is
			   this wise? I don't know. Does anyone care?
			   Note that we also don't make any attempts to catch
			   broken pipes.
			*/
			slavefp=popen("ispell -a", "w");
			if(!slavefp){
				fprintf(stderr, "Warning: Cannot create slave "
				    "ispell process. Disabling -i option.\n");
				slave=0;
			} else {
				setlinebuf(slavefp);
			}
		}
		if(!slave)
			printf(VERSION_IDENTIFICATION, HSPELL_VERSION_MAJOR,
			       HSPELL_VERSION_MINOR, HSPELL_VERSION_EXTRA);
	}

	for(;;){
		c=getc(in);
		if(c==EOF) {
			/* in UNIX spell mode (!interpipe) we should read
			   all the files given in the command line...
			   Otherwise, an EOF is the end of this loop.
			*/
			if(!interpipe && argc>0){
				in=next_file(&argc, &argv);
				if(!in)
					break;
			} else
				break;
		}
		if(ishebrew(c) || c=='\'' || c=='"'){
			/* swallow up another letter into the word (if the word
			 * is too long, lose the last letters) */
			if(wordlen<MAXWORD)
				word[wordlen++]=c;
		} else if(wordlen){
			/* found word seperator, after a non-empty word */
			word[wordlen]='\0';
			wordstart=offset-wordlen;
			/* TODO: convert two single quotes ('') into one
			 * double quote ("). For TeX junkies. */

			/* remove quotes from end or beginning of the word
			 * (we do leave, however, single quotes in the middle
			 * of the word - used to signify "j" sound in Hebrew,
			 * for example, and double quotes used to signify
			 * acronyms. A single quote at the end of the word is
			 * used to signify an abbreviate - or can be an actual
			 * quote (there is no difference in ASCII...), so we
			 * must check both possibilities. */
			w=word;
			if(*w=='"' || *w=='\''){
				w++; wordlen--; wordstart++;
			}
			if(w[wordlen-1]=='"'){
				w[wordlen-1]='\0'; wordlen--;
			}
			res=hspell_check_word(dict,w,&preflen);
			if(res!=1 && (res=hspell_is_canonic_gimatria(w))){
				if(hspell_debug)
					fprintf(stderr,"found canonic gimatria\n");
				if(opt_l){
					printf("גימטריה: %s=%d\n",w,res);
					preflen = -1; /* yes, I know it is bad programming, but I need to tell later printf not to print anything, and I hate to add a flag just for that. */
				}
				res=1;
			}
			if(res!=1 && w[wordlen-1]=='\''){
				/* try again, without the quote */
				w[wordlen-1]='\0'; wordlen--;
				res=hspell_check_word(dict,w,&preflen);
			}
			/* as last resort, try the user's personal word list */
			if(res!=1)
				res=hspell_hash_exists(&personaldict, w);

			if(res){
				if(hspell_debug)
					fprintf(stderr,"correct: %s\n",w);
				if(interpipe && !terse_mode)
					if(wordlen)
						printf("*\n");
				if(opt_l){
					hspell_enum_splits(dict,w,notify_split);
				}
			} else if(interpipe){
				/* Mispelling in -a mode: show suggested
				   corrections */
				struct corlist cl;
				int i;
				if(hspell_debug)
					fprintf(stderr,"misspelling: %s\n",w);
				corlist_init(&cl);
				hspell_trycorrect(dict, w, &cl);
				if(corlist_n(&cl))
					printf("& %s %d %d: ", w,
					       corlist_n(&cl), wordstart);
				else
					printf("# %s %d", w, wordstart);
				for(i=0;i<corlist_n(&cl);i++){
					printf("%s%s",
					       i ? ", " : "",
					       corlist_str(&cl,i));
				}
				printf("\n");
				corlist_free(&cl);
				if(opt_n){
					int index;
					if(hspell_hash_get_int(&spellinghints,
							       w, &index))
						printf("%s", flathints+index);
				}
			} else {
				/* Mispelling in "spell" mode: remember this
				   mispelling for later */

				if(hspell_debug)
					fprintf(stderr,"mispelling: %s\n",w);
				hspell_hash_incr_int(&wrongwords, w);
			}
			/* we're done with this word: */
			wordlen=0;
		} else if(interpipe && 
			  offset==0 && (c=='#' || c=='!' || c=='~' || c=='@' ||
					c=='%' || c=='-' || c=='+' || c=='&' ||
					c=='*')){
			if(c=='!')
				terse_mode=1;
			else if(c=='%')
				terse_mode=0;
			/* In the future we should do something about the
			   other ispell commands (see the ispell manual
			   for their description).
			   For now, ignore this line, or send it to a slave
			   ispell. Does this make sense? Probably not... */
			if(slave){
				putc(c,slavefp);
				while((c=getc(in))!=EOF && c!='\n')
					putc(c,slavefp);
				if(c!=EOF) putc(c,slavefp);
			} else {
				while((c=getc(in))!=EOF && c!='\n')
					;
			}
			/* offset=0 remains but we don't want to output
			   a newline */
			continue;
		}
		if(c=='\n'){
			offset=0;
			if(interpipe && !slave)  /*slave already outputs a newline...*/
			printf("\n");
		} else {
			offset++;
		}
		/* pass the character also to the slave, replacing Hebrew
		   characters by spaces */
		if(interpipe && slave)
			putc(ishebrew(c) ? ' ' : c, slavefp);
	}
	/* TODO: check the last word in case of no newline at end of file? */

	/* in spell-like mode (!interpipe) - list the wrong words */
	if(!interpipe){
		hspell_hash_keyvalue *wrongwords_array;
		int wrongwords_number;
		wrongwords_array = hspell_hash_build_keyvalue_array(
			&wrongwords, &wrongwords_number);

		if(wrongwords_number){
			int i;
			if(opt_c)
				printf("שגיאות כתיב שנמצאו, ותיקוניהן "
				       "המומלצים:\n\n");
			else
				printf("שגיאות כתיב שנמצאו:\n\n");

			/* sort word list by key or value (depending on -s
			   option) */
			qsort(wrongwords_array, wrongwords_number,
			      sizeof(hspell_hash_keyvalue),
			      opt_s ? compare_value_reverse : compare_key);

			for(i=0; i<wrongwords_number; i++){
				if(opt_c){
					struct corlist cl;
					int j;
					printf("%d %s -> ",
					       wrongwords_array[i].value,
					       wrongwords_array[i].key);
					corlist_init(&cl);
					hspell_trycorrect(dict,
					       wrongwords_array[i].key, &cl);
					for(j=0;j<corlist_n(&cl);j++){
						printf("%s%s",
						       j ? ", " : "",
						       corlist_str(&cl,j));
					}
					corlist_free(&cl);
					printf("\n");
				} else if(opt_s){
					printf("%d %s\n",
					       wrongwords_array[i].value,
					       wrongwords_array[i].key);
				} else {
					printf("%s\n",wrongwords_array[i].key);
				}
				if(opt_n){
					int index;
					if(hspell_hash_get_int(&spellinghints,
					     wrongwords_array[i].key, &index))
						printf("%s", flathints+index);
				}
			}
		}
#if 0
		hspell_hash_free_keyvalue_array(&wrongwords, wrongwords_number,
						wrongwords_array);
#endif
	}
	
	return 0;
}
