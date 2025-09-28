" Tests for 'rightmargin'

source util/view_util.vim
source util/screendump.vim

let s:lines = [
  \'Vim is a greatly improved version of the good old UNIX editor Vi.  Many new',
  \'features have been added: multi-level undo, syntax highlighting, command line',
  \'history, on-line help, spell checking, filename completion, block operations,',
  \'script language, etc.',
\]

" tests how rightmargin affects window visible content:
function! Test_rightmargin_basics()
  enew!
  set ff=unix

  let win_width = 50
  execute win_width 'vsplit'

  call setline(1, s:lines)

  set list listchars=extends:> nowrap

  " no rightmargin, no wrap:
  let expected = [
    \'Vim is a greatly improved version of the good old>',
    \'features have been added: multi-level undo, synta>',
    \'history, on-line help, spell checking, filename c>',
    \'script language, etc.                             ',
    \'~                                                 ',
    \'~                                                 ',
    \'~                                                 ',
    \'~                                                 ',
  \]
  let actual = ScreenLines([1, expected->len()], win_width)
  call assert_equal(expected, actual)

  " set rightmargin:
  set rightmargin=5
  let expected = [
    \'Vim is a greatly improved version of the goo>     ',
    \'features have been added: multi-level undo, >     ',
    \'history, on-line help, spell checking, filen>     ',
    \'script language, etc.                             ',
    \'~                                                 ',
    \'~                                                 ',
    \'~                                                 ',
    \'~                                                 ',
  \]
  let actual = ScreenLines([1, expected->len()], win_width)
  call assert_equal(expected, actual)

  " unset rightmargin and enable wrap:
  set rightmargin=0 wrap
  let expected = [
    \'Vim is a greatly improved version of the good old ',
    \'UNIX editor Vi.  Many new                         ',
    \'features have been added: multi-level undo, syntax',
    \' highlighting, command line                       ',
    \'history, on-line help, spell checking, filename co',
    \'mpletion, block operations,                       ',
    \'script language, etc.                             ',
    \'~                                                 ',
  \]
  let actual = ScreenLines([1, expected->len()], win_width)
  call assert_equal(expected, actual)

  " set rightmargin, wrap is on:
  set rightmargin=5
  let expected = [
    \'Vim is a greatly improved version of the good     ',
    \' old UNIX editor Vi.  Many new                    ',
    \'features have been added: multi-level undo, s     ',
    \'yntax highlighting, command line                  ',
    \'history, on-line help, spell checking, filena     ',
    \'me completion, block operations,                  ',
    \'script language, etc.                             ',
    \'~                                                 ',
  \]
  let actual = ScreenLines([1, expected->len()], win_width)
  call assert_equal(expected, actual)

  if has('rightleft')
    " unset rightmargin, disable wrap, set rightleft:
    set rightmargin=0 rightleft nowrap
    let expected = [
      \'>dlo doog eht fo noisrev devorpmi yltaerg a si miV',
      \'>atnys ,odnu level-itlum :dedda neeb evah serutaef',
      \'>c emanelif ,gnikcehc lleps ,pleh enil-no ,yrotsih',
      \'                             .cte ,egaugnal tpircs',
      \'                                                 ~',
      \'                                                 ~',
      \'                                                 ~',
      \'                                                 ~',
    \]
    let actual = ScreenLines([1, expected->len()], win_width)
    call assert_equal(expected, actual)

    " set rightmargin, wrap is off:
    set rightmargin=5
    let expected = [
      \'     >oog eht fo noisrev devorpmi yltaerg a si miV',
      \'     > ,odnu level-itlum :dedda neeb evah serutaef',
      \'     >nelif ,gnikcehc lleps ,pleh enil-no ,yrotsih',
      \'                             .cte ,egaugnal tpircs',
      \'                                                 ~',
      \'                                                 ~',
      \'                                                 ~',
      \'                                                 ~',
    \]
    let actual = ScreenLines([1, expected->len()], win_width)
    call assert_equal(expected, actual)

    " unset rightmargin, enable wrap:
    set rightmargin=0 wrap
    let expected = [
      \' dlo doog eht fo noisrev devorpmi yltaerg a si miV',
      \'                         wen ynaM  .iV rotide XINU',
      \'xatnys ,odnu level-itlum :dedda neeb evah serutaef',
      \'                       enil dnammoc ,gnithgilhgih ',
      \'oc emanelif ,gnikcehc lleps ,pleh enil-no ,yrotsih',
      \'                       ,snoitarepo kcolb ,noitelpm',
      \'                             .cte ,egaugnal tpircs',
      \'                                                 ~',
    \]
    let actual = ScreenLines([1, expected->len()], win_width)
    call assert_equal(expected, actual)

    " set rightmargin, wrap is on:
    set rightmargin=5
    let expected = [
      \'     doog eht fo noisrev devorpmi yltaerg a si miV',
      \'                    wen ynaM  .iV rotide XINU dlo ',
      \'     s ,odnu level-itlum :dedda neeb evah serutaef',
      \'                  enil dnammoc ,gnithgilhgih xatny',
      \'     anelif ,gnikcehc lleps ,pleh enil-no ,yrotsih',
      \'                  ,snoitarepo kcolb ,noitelpmoc em',
      \'                             .cte ,egaugnal tpircs',
      \'                                                 ~',
    \]
    let actual = ScreenLines([1, expected->len()], win_width)
    call assert_equal(expected, actual)
  endif

  only!
  enew!
  set list& listchars& wrap& rightmargin& rightleft& ff& columns&
endfunction

" tests :center and :right formatting commands:
function! Test_rightmargin_format()
  enew!
  set ff=unix

  50vsplit

  call setline(1, s:lines)

  set rightmargin=5 wrapmargin=1

  " format to width:
  norm! ggVGgq
  let expected = [
    \'Vim is a greatly improved version of the',
    \'good old UNIX editor Vi.  Many new features',
    \'have been added: multi-level undo, syntax',
    \'highlighting, command line history, on-line',
    \'help, spell checking, filename completion,',
    \'block operations, script language, etc.'
  \]
  let actual = getline(1, '$')
  call assert_equal(expected, actual)

  " format center:
  :%center
  let expected = [
    \'  Vim is a greatly improved version of the',
    \'good old UNIX editor Vi.  Many new features',
    \' have been added: multi-level undo, syntax',
    \'highlighting, command line history, on-line',
    \' help, spell checking, filename completion,',
    \'  block operations, script language, etc.'
  \]
  let actual = getline(1, '$')
  call assert_equal(expected, actual)

  " format right:
  :%right
  let expected = [
    \'    Vim is a greatly improved version of the',
    \' good old UNIX editor Vi.  Many new features',
    \'   have been added: multi-level undo, syntax',
    \' highlighting, command line history, on-line',
    \'  help, spell checking, filename completion,',
    \'     block operations, script language, etc.'
  \]
  let actual = getline(1, '$')
  call assert_equal(expected, actual)

  only!
  enew!
  set rightmargin& wrapmargin&
endfunction

" tests motions affecter by rightmargin: g^ / g0 / gm / g$ / zH / zL / ze
function! Test_rightmargin_motions()
  enew!
  set ff=unix

  50vsplit

  call setline(1, s:lines)

  set rightmargin=10 scrolloff=0

  " SART: testing g$ / gm / zH / zL / ze
  "-----------------------
  " first test with wrap and smoothscroll disabled:
  set nosmoothscroll nowrap

  " reset to initial state:
  norm! 0gg

  " go to middle visible character, wrap is off:
  norm! gm
  let expected = 21
  let actual = col('.')
  call assert_equal(expected, actual)

  " go to last visible character, wrap is off:
  norm! g$
  let expected = 40
  let actual = col('.')
  call assert_equal(expected, actual)

  " reset to initial state:
  norm! 0gg

  " scroll left half-page:
  norm! zL
  let expected = 20
  let actual = getwininfo(win_getid())[0].leftcol
  call assert_equal(expected, actual)

  " reset to initial state:
  norm! 0gg

  " scroll twice left half-page and once right half-page:
  norm! 2zL
  norm! zH
  let expected = 20
  let actual = getwininfo(win_getid())[0].leftcol
  call assert_equal(expected, actual)

  " reset to initial state:
  norm! 0gg

  " jump to last character:
  norm! $
  " scroll to position the cursor at the end of the screen:
  norm! ze
  let expected = 35
  let actual = getwininfo(win_getid())[0].leftcol
  call assert_equal(expected, actual)

  " repeat with wrap enabled:
  set wrap

  " reset to initial state:
  norm! 0gg

  " scroll down:
  execute "norm! \<C-e>"
  " jump one screen line down:
  norm! gj

  " go to middle visible character:
  norm! gm
  let expected = 61
  let actual = col('.')
  call assert_equal(expected, actual)

  " go to last visible character:
  norm! g$
  let expected = 77
  let actual = col('.')
  call assert_equal(expected, actual)

  " repeat with smoothscroll enabled:
  set smoothscroll

  " reset to initial state:
  norm! 0gg

  " scroll down:
  execute "norm! \<C-e>"
  " jump one screen line down:
  norm! gj

  " go to middle visible character:
  norm! gm
  let expected = 21
  let actual = col('.')
  call assert_equal(expected, actual)

  " go to last visible character:
  norm! g$
  let expected = 40
  let actual = col('.')
  call assert_equal(expected, actual)
  " END: testing g$ / gm / zH / zL / ze
  "-----------------------

  " START: testing g^ and g0
  "-----------------------
  " first test with smoothscroll disabled:
  set nowrap nosmoothscroll

  " reset to initial state:
  norm! 0gg

  " scroll left to set the first visible and non-blank characters to be
  " different and also not equal to 1:
  norm! 3zl

  " go to first non-blank visible character:
  norm! g^
  let expected = 5
  let actual = col('.')
  call assert_equal(expected, actual)

  " go to first visible character:
  norm! g0
  let expected = 4
  let actual = col('.')
  call assert_equal(expected, actual)

  " repeat with wrap enabled:
  set wrap

  " jump one screen line down (expected to have first character blank):
  norm! gj

  " go to first non-blank visible character:
  norm! g^
  let expected = 42
  let actual = col('.')
  call assert_equal(expected, actual)

  " go to first visible character:
  norm! g0
  let expected = 41
  let actual = col('.')
  call assert_equal(expected, actual)

  " repeat with smoothscroll enabled:
  set wrap smoothscroll

  " scroll down 3 lines (expected to have first character blank):
  execute "norm! 3\<C-e>"

  " go to first non-blank visible character:
  norm! g^
  let expected = 45
  let actual = col('.')
  call assert_equal(expected, actual)

  " go to first visible character:
  norm! g0
  let expected = 44
  let actual = col('.')
  call assert_equal(expected, actual)
  " END: testing g^ and g0
  "-----------------------

  only!
  enew!
  set rightmargin& wrapmargin& wrap& smoothscroll& scrolloff&
endfunction

" test that scrolling and resizing windows properly redraws blank areas, statuslines and window splits:
function! Test_rightmargin_scroll_and_resize()
  CheckScreendump
  CheckRunVimInTerminal

  let script_lines =<< trim eval END
    call setline(1, {s:lines})

    set list listchars=extends:>
    colorscheme koehler
    set nowrap rightmargin=5 wincolor=Error scrolloff=0

    botright vsplit

    set rightmargin=5 rightleft
    windo norm zt
  END

  call writefile(script_lines, 'XTest_rightmargin_scroll_and_resize', 'D')
  let buf = RunVimInTerminal('-S XTest_rightmargin_scroll_and_resize', {'rows': 20, 'cols': 70})

  call VerifyScreenDump(buf, 'Test_rightmargin_scroll_and_resize_1', {})

  " scrolling down:
  call term_sendkeys(buf, ":windo norm Gzt\<CR>")
  call VerifyScreenDump(buf, 'Test_rightmargin_scroll_and_resize_2', {})

  " scrolling back to top:
  call term_sendkeys(buf, ":windo norm gg\<CR>")
  call VerifyScreenDump(buf, 'Test_rightmargin_scroll_and_resize_3', {})

  " increasing width:
  call term_sendkeys(buf, ":vertical resize +20\<CR>")
  call VerifyScreenDump(buf, 'Test_rightmargin_scroll_and_resize_4', {})

  " decreasing width:
  call term_sendkeys(buf, ":vertical resize -40\<CR>")
  call VerifyScreenDump(buf, 'Test_rightmargin_scroll_and_resize_5', {})

  " clean up
  call StopVimInTerminal(buf)
endfunction

" tests balloon feature:
function! Test_rightmargin_popup_beval()
  CheckFeature balloon_eval_term
  CheckScreendump
  CheckRunVimInTerminal

  let script_lines =<< trim eval END
    call setline(1, {s:lines})

    function MyBalloonExpr()
      return "line " .. v:beval_lnum .. " column " .. v:beval_col .. ":\n" .. v:beval_text
    endfunction

    function Trigger(lnum, col)
      call test_setmouse(a:lnum, a:col)
      call feedkeys("\<MouseMove>\<Ignore>", "xt")
    endfunction

    set balloonevalterm balloonexpr=MyBalloonExpr() balloondelay=100 updatetime=300
    set list listchars=extends:> nowrap
  END
  call writefile(script_lines, 'XTest_rightmargin_beval', 'D')

  let buf = RunVimInTerminal('-S XTest_rightmargin_beval', {'rows': 20, 'cols': 50})

  " balloon at first visible column:
  call term_sendkeys(buf, ":call Trigger(3, 1)\<CR>")
  sleep 150m
  call VerifyScreenDump(buf, 'Test_rightmargin_beval_1', {})

  " balloon at last visible column:
  call term_sendkeys(buf, ":call Trigger(3, 49)\<CR>")
  sleep 150m
  call VerifyScreenDump(buf, 'Test_rightmargin_beval_2', {})

  call term_sendkeys(buf, ":set rightmargin=5\<CR>")

  " balloon at first visible column:
  call term_sendkeys(buf, ":call Trigger(3, 1)\<CR>")
  sleep 150m
  call VerifyScreenDump(buf, 'Test_rightmargin_beval_3', {})

  " no balloon in rightmargin area:
  call term_sendkeys(buf, ":call Trigger(3, 49)\<CR>")
  sleep 150m
  call VerifyScreenDump(buf, 'Test_rightmargin_beval_4', {})

  " clean up
  call StopVimInTerminal(buf)
endfunction
