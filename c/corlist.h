#ifndef INCLUDED_CORLIST_H
#define INCLUDED_CORLIST_H

/* this silly implementation has fixed sizes! A no-no in good programming,
 * but enough for what we need it for...
 */
#define N_CORLIST_WORDS 50
#define N_CORLIST_LEN 30    /* max len per word */
struct corlist {
	char correction[N_CORLIST_WORDS][N_CORLIST_LEN];
	int n;
};
int
corlist_add(struct corlist *cl, const char *s);
int corlist_init(struct corlist *cl);
int corlist_free(struct corlist *cl);


#define corlist_n(cl) ((cl)->n)
#define corlist_str(cl,i) ((cl)->correction[(i)])

#endif /* INCLUDED_CORLIST_H */
