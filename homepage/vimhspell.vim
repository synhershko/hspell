" Vim 6.x support for Hspell, the Hebrew speller
" Version:	    0.4
" Maintainer:	    Mooffie <mooffie@typo.co.il>
" Authors:          The script was originally written by
"	            Claudio Fleiner <claudio@fleiner.com>, and was later
"	            modified heavily by Mooffie to support Hspell: Hebrew,
"	            UTF-8, bilingualism, geresh/apostrophe, gershayim/quotes,
"                   spelling hints, fixed some fikshushim, etc.
" License:	    The GNU General Public License
" URL:		    http://www.ivrix.org.il/projects/spell-checker/

" GENERAL
" -------
"
" This script supports both UTF-8 and ISO-8859-8/CP1255 files. It lets you
" spell-check both Hebrew and English, and it supports features unique to
" Hspell, such as spelling-hints.
"
" Please let me (Mooffie) know if you have problems using this script.
"
" REQUIREMENTS
" ------------
"
" * Vim 6.x
" * Hspell 0.6 and up (haven't tested it with older versions)
" * For UTF-8 files: either iconv(1) or recode(1)
" * For bilingual spell-checking: some English spell-checker.
"   The default is ispell.
" * If you want to add words to your personal dictionary, you'll
"   have to use Hspell 0.7 and up (these commands have no effect in
"   previous versions).
"
" INSTALLATION
" ------------
"
" Put this file in the ~/.vim/plugin/ directory and Vim will load it
" automagically on startup. If this directory does not exist, create it.
" Alternatively, ':source' this file.
"
" KEY MAPPINGS
" ------------
"
" The default key mappings are:
"
"     \hh    Write file, spell-check file & highlight spelling mistakes
"     \hq    Turn off highlighting of spelling mistakes (and restore the
"            original highlighting)
"     \hn    Jump to next spelling error
"     \hp    Jump to previous spelling error
"     \hi    Insert word under cursor into directory
"     \hu    Insert word under cursor as lowercase into directory
"     \ha    Accept word for this session only
"     \h?    Check for alternative spellings for the word
"     \hl    Toggle bilingual mode (spell English words too, or Hebrew only)
"            The default is to spell-check Hebrew only.
"     \hd    Print some debug info
"
" There must be no delay between the three keys. That is, don't pause
" between '\' to 'h' to 'h'.
"
" Note that you don't have to do \hh to use most of the other commands.
" For example, you can do \h? without first doing \hh. However, you must
" first do \hh in order to use \hn and \hp.
"
" If you're a Meta guy, there are alternative mappings for you: go to the
" end of this script and change 'if 0' to 'if 1'. The alternative mappings
" are:
" 
"     \hh <- F6
"     \hq <- M-F6
"     \hn <- M-n
"     \hp <- M-p
"     \hi <- M-i
"     \hu <- M-u
"     \ha <- M-a
"     \h? <- M-/
"     \hl <- M-F7
"     \hd <- [none]
"
" (Press ESC instead of meta if <M-key> doesn't work for you (e.g. at the
" console).)
"
" These Meta mappings are not the default because they may already be used for
" something else.
"
" REVERSING HEBREW
" ----------------
"
" Vim does not support BiDi, so everything this script prints (spelling
" suggestions, spelling hints) is supposed to show up backward. Fortunately,
" this script reverses the hebrew it's about to print, so there's no such
" problem. However, the script assumes that if 'rightleft' is not activated
" and if you're not using GUI then you're using a BiDi terminal emulator
" (like mlterm) and it won't reverse the text. The function s:DoRevHeb()
" determines whether to reverse or not.
"
" SPELL-CHECKING UTF-8 FILES
" --------------------------
"
" Since hspell does not yet support UTF-8, the script uses the external
" utilities recode(1) or iconv(1). Make sure one of them is installed.
" Note, however, that if there are in the file characters that cannot be
" represented in CP1255 (like Russian, Arabic), iconv will fail (you'll be
" notified). That's why recode is preferred over iconv.
"  
" USEFUL VARIABLES
" ----------------
"
" When doing bilingual spell-check, g:espell_cmd holds the command of
" the English speller. If you're editing HTML/TeX/mail files, you can add
" the appropriate command-line options to turn on the appropriate filter.
" You can also add the '-d' options to specify a dictionary. It's best to
" specify it in your ~/.vimrc file, not here.
"
" g:utf8_to_cp1255 and g:cp1255_to_utf8 contain alternative commands to
" convert from UTF-8 to CP1255 and vice versa. They are useful if your
" recode(1) has a bug that fails the conversion sometimes (When this happens
" you'll get a message saying 'Your recode(1) utility has a nasty bug'), or
" when iconv(1) doesn't suit you, e.g. when you're using characters that are
" not represented in CP1255 (When this happens you'll get a message saying
" 'Sorry, your iconv(1) utility can't convert this file'). Please set these
" variables in ~/.vimrc, not here.
"
" KNOWN LIMITATIONS / BUGS
" ------------------------
"
" You can't spell-check words that contain real gershayim and real geresh
" (in contrast to quotes and apostrophe). This is a limitation in hspell,
" not in this script. Misspelled words containing gershayim and geresh
" won't be highlighted.
" 
" If you want to figure out why this script does not behave as you expect,
" typing '\hd' or ':syntax' might help you.
"
" TIPS
" ----
"
" If you wish to change the appearance of highlighted spelling mistakes, put
" the following in your ~/.vimrc:
"
"   highlight SpellErrors ctermfg=Red guifg=Red cterm=underline gui=underline
"
" (But we should use it with ':autocmd'. Which event should we use?)

let g:multilingual_spellcheck = 0

let g:hspella_cmd     = "LC_ALL=C hspell -a"
let g:multispella_cmd = "LC_ALL=C multispell -a"
let g:hspell_cmd      = "LC_ALL=C hspell"
if !exists("g:espell_cmd")
let g:espell_cmd      = "ispell -l"
endif

let g:spell_syn_options = ""

"-----------------------------------------------------------------

if &compatible
    finish
endif

" Use reverse video if terminal doesn't have colors
if &t_Co <= 2 && !has("gui_running")
    highlight SpellErrors term=reverse
endif

" The following was copied from Mathieu Clabaut's vimspell.vim
if &shell =~ 'csh'
  echomsg "warning: vimhspell doesn't work with csh shells (:help 'shell')"
  echomsg "shell changed to /bin/sh"
  setlocal shell=/bin/sh
endif

function! HsplToggleMultilingualSpell()
    let g:multilingual_spellcheck = !g:multilingual_spellcheck
    echo "Speller: " . (g:multilingual_spellcheck ? "Hebrew + English"
						 \: "Hebrew only")
endfunction

function! s:GetIspellACmd()
    return g:multilingual_spellcheck ? g:multispella_cmd : g:hspella_cmd 
endfunction

" Is vim data UTF-8 encoded?
function! s:IsVimUtf8()
    return &encoding == "utf-8"
endfunction

" Is the file (associated with the buffer) UTF-8 encoded?
function! s:IsFileUtf8()
    return &fileencoding == "utf-8"
		\ || (&fileencoding == "" && s:IsVimUtf8())
endfunction

" debug
function! HsplPrintEncodings()
    echo "File is ".(s:IsFileUtf8()?"":"not ")."UTF-8; ".
	\"Vim is ".(s:IsVimUtf8()?"":"not ")."UTF-8"
    echo "File encoding:     [".&fileencoding."]"
    echo "Vim encoding:      [".&encoding."]"
    echo "Terminal encoding: [".&termencoding."]"
    echo "Word under cursor: [".HsplGetCurWord()."]"
    echo "Converters:        ".s:CvtFileToSplrCmd()." and ".s:CvtFromSplrCmd()
endfunction

function! s:CheckEncoding()
    if &encoding == "latin1" || &termencoding == "latin1"
	echo "Warning: either 'encoding' or 'termencoding' is set to 'latin1'."
	echo "It means your editor is not configured properly for Hebrew."
	echo " "
    endif
endfunction

" Does the system have the recode utility?
" We prefer recode over iconv because it can ignore conversion errors.
function! s:HasRecode()
    if !exists("s:has_recode")
	let s:has_recode = (system("recode --version") =~? "copyright")
    endif
    return s:has_recode
endfunction

" Hspell does not yet support UTF-8, so we use external utilities to do the
" conversion. CvtToSplrCmd() returns a filter that converts the date
" to hspell's encoding while CvtFromSplrCmd() vice versa. Note that we're
" using CP1255 instead of ISO-8859-8 to give hspell a chance to deal with
" niqqud and various punctuations.

function! s:CvtFileToSplrCmd()
    if s:IsFileUtf8()
	if exists("g:utf8_to_cp1255")
	    return g:utf8_to_cp1255
	elseif s:HasRecode()
	    return "recode -f UTF-8..CP1255/"
	else
	    return "iconv -f UTF-8 -t CP1255"
	endif
    else
	return "cat"
    endif
endfunction

function! s:CvtVimToSplrCmd()
    if s:IsVimUtf8()
	if exists("g:utf8_to_cp1255")
	    return g:utf8_to_cp1255
	elseif s:HasRecode()
	    return "recode -f UTF-8..CP1255/"
	else
	    return "iconv -f UTF-8 -t CP1255"
	endif
    else
	return "cat"
    endif
endfunction

function! s:CvtFromSplrCmd()
    if s:IsVimUtf8()
	if exists("g:cp1255_to_utf8")
	    return g:cp1255_to_utf8
	elseif s:HasRecode()
	    return "recode CP1255/..UTF-8"
	else
	    return "iconv -f CP1255 -t UTF-8"
	endif
    else
	return "cat"
    endif
endfunction

" Are we to reverse the hebrew suggestions (and spelling hints)?
" When the user uses a BiDi terminal, like mlterm, he doesn't want us to
" reverse the hebrew. If he's using such a terminal, he is not using
" ':set rightleft'.
function! s:DoRevHeb()
    return &rightleft || has("gui_running")
endfunction

" Special characters to pay attention to:
" ---------------------------------------
" 0x84	0x201E	#DOUBLE LOW-9 QUOTATION MARK
" 0x93	0x201C	#LEFT DOUBLE QUOTATION MARK
" 0x82	0x201A	#SINGLE LOW-9 QUOTATION MARK
" 0x91	0x2018	#LEFT SINGLE QUOTATION MARK
" 0x92	0x2019	#RIGHT SINGLE QUOTATION MARK
" 0x94	0x201D	#RIGHT DOUBLE QUOTATION MARK
" 0x96	0x2013	#EN DASH
" 0x97	0x2014	#EM DASH
" 0xCE	0x05BE	#HEBREW PUNCTUATION MAQAF
" 0xD7	0x05F3	#HEBREW PUNCTUATION GERESH
" 0xD8	0x05F4	#HEBREW PUNCTUATION GERSHAYIM

" Hspell doesn't yet support geresh & gershayim. When it encounters gershayim,
" it thinks these are two separate words. CharsFixupCmd() returns the command
" that converts geresh & gershayim to their ASCII counterparts. In effect,
" we're ignoring such words, because Vim will not highlight them (since the
" text contains gershayim, not ACII quotes).
function! s:CharsFixupCmd()
    return "tr '\\327\\330' '\\047\\042'"
endfunction

" HsplGetCurWord() returns the word on which the cursor stands. We can't just
" use "expand('<cword>') because we treat specially quotes/gershayim and
" apostrophe/geresh.
function! HsplGetCurWord()
    let iskeyword_saved = &iskeyword
    set iskeyword&
    " Add quotes/gershayim (ascii 34) and apostrophe/geresh (ascii 39)
    " to what constitutes a word.
    set iskeyword+=34,39
    if !s:IsVimUtf8()
	" Here we deal with various CP1255 characters (it's a superset
	" of ISO-8859-8).

	" include niqqud
	set iskeyword+=192-205,207,209,210
	" exclude hebrew maqaf, en, em dash
	set iskeyword+=^206,^150,^151
	" exclude various quotes
	set iskeyword+=^130,^132,^145,^146,^147,^148
	" include geresh, gershayim
	set iskeyword+=215,216
    endif
    let word = expand("<cword>")
    let word = substitute(word, "^[\"']*\\|\"*$", '', 'g')
    let &iskeyword = iskeyword_saved
    return word
endfunction

" Under various circumstances we need to quote gershayim.
function! s:ShellQ(s)
    return substitute(a:s, '"', '\\"', 'g')
endfunction

function! s:SaveCursor()
    let s:curs_col = col(".")
    let s:curs_line = line(".")
endfunction

function! s:RestoreCursor()
    call cursor(s:curs_line, s:curs_col)
endfunction

" Replace the word on which the cursor stands
function! HsplReplace(repw)
    let word = HsplGetCurWord()
    if stridx(word, '"') == -1 && stridx(word, "'") == -1
	exe "normal gewcw".a:repw."\<esc>"
    else
	" Argh! if the word contains quotes, it's not so simple... 

	" move back a little
	exe "normal bbb"
	" move to beginning of word, then record cursor position
	exe "normal /".word."\<cr>"
	call s:SaveCursor()
	" replace the word and restore cursor position
	exe "s/".word."/".a:repw
	call s:RestoreCursor()
    endif
    call HsplRemoveMappings()
endfunction

" Replace all the instances of the word on which the cursor stands
function! HsplReplaceAll(repw)
    call s:SaveCursor()
    exe ':%s/\<'.HsplGetCurWord().'\>/'.a:repw.'/g'
    call s:RestoreCursor()
    call HsplRemoveMappings()
endfunction
    
" Query the speller and print a menu with spelling suggestions (and optional
" spelling-hints and/or explanation).
function! HsplProposeAlternatives()
    let s:word         = HsplGetCurWord()
    let b:hint         = ""
    let b:explanation  = ""
    let b:word_correct = 0

    call s:CheckEncoding()

    let cmd = '(echo %; echo "'.s:ShellQ(s:word).'" ) |'.
    \s:CvtVimToSplrCmd().'|'.s:GetIspellACmd().'|'.
    \'sed -e "s/^[?&] \(.*\) .* .*: /R \1 /" -e "/^R /s/,//g" |'.
    \'LC_ALL=C awk '."'".
    \'BEGIN { do_rev = '.(s:DoRevHeb()?1:0).'; }'.
    \'function rev(s, pad) {'.
    \'  srev = "";'.
    \'  for (si = length(s); si >= 1; --si) {'.
    \'    ch = substr(s, si, 1);'.
    \'    srev = srev ((ch == "(") ? ")" : (ch == ")") ? "(" : ch)'.
    \'  }'.
    \'  pad -= length(s);'.
    \'  while (pad-- > 0) srev = " " srev;'.
    \'  return srev;'.
    \'}'.
    \'function condrev(s, pad)'.
    \'{'.
    \'  return (do_rev && s ~ /[\340-\372]/) ? rev(s, pad) : s'.
    \'}'.
    \'function qq(s) { gsub(/"/, "\\\"", s); return s }'.
    \''.
    \'/^R / {'.
    \' printf "echo \"Checking \\\"%s\\\" Type 0 for no change, r to replace,'.
    \' *<num> to replace all, or\" |",'.
    \'   qq(condrev($2,0));'.
    \' for (i = 3; i <= NF && i <= 11; i++) '.
    \'   printf "map %d :call HsplReplace(\"%s\")<cr> |'.
    \'          map *%d :call HsplReplaceAll(\"%s\")<cr> | echo \"%d: %s\" | ",'.
    \'     i-2, qq($(i)), i-2, qq($(i)), i-2, qq(condrev($(i),9));'.
    \'}'.
    \'/^[H ]/ {'.
    \' printf "let b:hint=b:hint.\"%s\".\"\\n\" | ", qq(condrev(substr($0,2),77))'.
    \'}'.
    \'/^+/ {'.
    \' printf "let b:explanation = \"%s\" | ", qq(substr($0,3))'.
    \'}'.
    \'/^[*-]/ {'.
    \' printf "let b:word_correct = 1 | "'.
    \'}'.
    \''."'|".s:CvtFromSplrCmd()

    let alter = system(cmd)
    if alter != ""
	exe alter
	if b:word_correct
	    echo "Word is correct"
	endif
        if b:explanation != ""
	    echo s:word "is correct because of" b:explanation
	endif
        if b:hint != ""
	    echo "----------------------------------------------"
	    let  b:hint = substitute(b:hint, "\n$", "", "")
	    echo b:hint
        endif
	map 0 <cr>:call HsplRemoveMappings()<cr>
	map r 0gewcw
    else
	echo "No suggestions for this word, sorry."
    endif
endfunction

function! HsplRemoveMappings()
    let counter = 0
    while counter < 10
	exe "map ".counter." x"
	exe "map *".counter." x"
	exe "unmap ".counter
	exe "unmap *".counter
	let counter = counter + 1
    endwhile
    unmap r
endfunction

function! HsplRemoveHighlight()
    syn match SpellErrors "xxxxx"
    syn match SpellCorrected "xxxxx"
    syn clear SpellErrors
    syn clear SpellCorrected
    " Restore the syntax highlighting that was on before
    " we applied ours.
    if &filetype != ""
	set syntax=ON
    endif
endfunction

" Adds a word to the personal dictionary. Since this script handles english
" spelling too, we allow two variants of insertion.
function! HsplAddToDict(word, ic)
    call system('(echo "'.(a:ic?'&':'*').s:ShellQ(a:word).'"; echo "#" ) |'
		\.s:CvtVimToSplrCmd()."|".s:GetIspellACmd())
    if a:ic
	syn case ignore
    else
	syn case match
    endif
    exe 'syn match SpellCorrected "\<'.s:ShellQ(a:word).
		\'\>" transparent contains=NONE '.g:spell_syn_options
endfunction

" Ignores a word for this session. Currently, it just un-highlighs the word.
function! HsplIgnoreWord(word)
  syn case match
  exe 'syn match SpellCorrected "\<'.s:ShellQ(a:word).
		\'\>" transparent contains=NONE '.g:spell_syn_options
endfunction

function! HsplSearchError(next)
    if exists("b:hspellerrors")
	call search(b:hspellerrors, a:next?'':'b')
    endif
endfunction

" HsplCheck() spell-check the buffer. It first saves the file, then it
" calls the speller(s) and highligh the misspelled words.
function! HsplCheck()

    let buf_filename = expand("%")

    if buf_filename == ""
	echo "Speller: You must first give this file a name by saving it."
	return
    endif

    if &modified
	if &readonly
	    echo "Speller: I need to save this file first, but it's read-only; "
			\."use \"w!\""
	    return
        endif
	" Save the file
	w
    endif

    syn clear
    syn case match
    syn match SpellErrors "xxxxx"
    syn clear SpellErrors
    let b:hspellerrors = '\<\(nonexisitingwordinthisdocument'

    let round = 1
    while round <= 2
	if round == 1
	    " Pass 1: hebrew spellchecking
	    let cvrt = s:CvtFileToSplrCmd()
	    let splr = g:hspell_cmd
	else
	    " Pass 2: english spellchecking
	    let cvrt = "tr -d '\\200-\\377'"
	    let splr = g:espell_cmd
	endif
	if round == 1 || (round == 2 && g:multilingual_spellcheck)
	    let cmd = cvrt. " < ".buf_filename."|".s:CharsFixupCmd()."|".splr."|".
		\'sed -e "s/\"/\\\\\"/g" '."-e '".
		\'s/\(.*\)/syntax match SpellErrors "\\<\1\\>" '.g:spell_syn_options.
		\'| let b:hspellerrors=b:hspellerrors."\\\\|\1"/'."' |".
		\s:CvtFromSplrCmd()
	    let mappings = system(cmd)
	    if mappings =~? "internal recoding bug"
		echo "Your recode(1) utility has a nasty bug; switching to iconv(1)"
		let s:has_recode = 0
		call HsplCheck()
		return
	    endif
	    if mappings =~? "illegal input" || mappings =~? "cannot convert"
		echo "Sorry, your iconv(1) utility can't convert this file. Probably because"
		echo "it contains characters that cannot be represented in CP1255."
		return
	    endif
	    exe mappings
	endif
	let round = round + 1
    endwhile

    let b:hspellerrors = b:hspellerrors.'\)\>'

    syn cluster Spell contains=SpellErrors,SpellCorrected
    hi link SpellErrors Error
endfunction

noremap <Plug>HsplCheck                   :call HsplCheck()<cr>
noremap <Plug>HsplProposeAlternatives     :call HsplProposeAlternatives()<cr>
noremap <Plug>HsplRemoveHighlight         :call HsplRemoveHighlight()<cr>
noremap <Plug>HsplToggleMultilingualSpell :call HsplToggleMultilingualSpell()<cr>
noremap <Plug>HsplSearchNextError         :call HsplSearchError(1)<cr>
noremap <Plug>HsplSearchPrevError         :call HsplSearchError(0)<cr>
noremap <Plug>HsplAddToDictI              :call HsplAddToDict(HsplGetCurWord(),1)<cr>
noremap <Plug>HsplAddToDictU              :call HsplAddToDict(HsplGetCurWord(),0)<cr>
noremap <Plug>HsplIgnoreWord              :call HsplIgnoreWord(HsplGetCurWord())<cr>
noremap <Plug>HsplDebug                   :call HsplPrintEncodings()<cr>

map <Leader>hh <Plug>HsplCheck
map <Leader>hq <Plug>HsplRemoveHighlight
map <Leader>h? <Plug>HsplProposeAlternatives
map <Leader>hn <Plug>HsplSearchNextError
map <Leader>hp <Plug>HsplSearchPrevError
map <Leader>hi <Plug>HsplAddToDictI
map <Leader>hu <Plug>HsplAddToDictU
map <Leader>ha <Plug>HsplIgnoreWord
map <Leader>hl <Plug>HsplToggleMultilingualSpell
map <Leader>hd <Plug>HsplDebug

" The following are alternative mappings. Off by default.
if 0
map <F6>       <Plug>HsplCheck
map <m-F6>     <Plug>HsplRemoveHighlight
map <esc><F6>  <Plug>HsplRemoveHighlight
map <m-/>      <Plug>HsplProposeAlternatives
map <esc>/     <Plug>HsplProposeAlternatives
map <m-n>      <Plug>HsplSearchNextError
map <esc>n     <Plug>HsplSearchNextError
map <m-p>      <Plug>HsplSearchPrevError
map <esc>p     <Plug>HsplSearchPrevError
map <m-i>      <Plug>HsplAddToDictI
map <esc>i     <Plug>HsplAddToDictI
map <m-u>      <Plug>HsplAddToDictU
map <esc>u     <Plug>HsplAddToDictU
map <m-a>      <Plug>HsplIgnoreWord
map <esc>a     <Plug>HsplIgnoreWord
map <esc><F7>  <Plug>HsplToggleMultilingualSpell
endif

