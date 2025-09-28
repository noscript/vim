" Tests for 'rightmargin'

scriptencoding utf-8

source util/view_util.vim
source util/screendump.vim

let s:lines = [
  \'Vim is a greatly improved version of the good old UNIX editor Vi.  Many new',
  \'features have been added: multi-level undo, syntax highlighting, command line',
  \'history, on-line help, spell checking, filename completion, block operations,',
  \'script language, etc.',
\]

let s:double_cell_lines = [
  \'Ｖｉｍ ｉｓ ａ ｇｒｅａｔｌｙ ｉｍｐｒｏｖｅｄ ｖｅｒｓｉｏｎ ｏｆ ｔｈｅ',
  \'ｇｏｏｄ ｏｌｄ ＵＮＩＸ ｅｄｉｔｏｒ Ｖｉ．  Ｍａｎｙ ｎｅｗ',
  \'ｆｅａｔｕｒｅｓ ｈａｖｅ ｂｅｅｎ ａｄｄｅｄ： ｍｕｌｔｉ－ｌｅｖｅｌ',
  \'ｕｎｄｏ， ｓｙｎｔａｘ ｈｉｇｈｌｉｇｈｔｉｎｇ， ｃｏｍｍａｎｄ ｌｉｎｅ',
  \'ｈｉｓｔｏｒｙ， ｏｎ－ｌｉｎｅ ｈｅｌｐ， ｓｐｅｌｌ ｃｈｅｃｋｉｎｇ，',
  \'ｆｉｌｅｎａｍｅ ｃｏｍｐｌｅｔｉｏｎ， ｂｌｏｃｋ ｏｐｅｒａｔｉｏｎｓ，',
  \'ｓｃｒｉｐｔ ｌａｎｇｕａｇｅ， ｅｔｃ．',
\]

function MouseClick(lnum, col)
  call test_setmouse(a:lnum, a:col)
  call feedkeys("\<LeftMouse>\<Ignore>", "xt")
endfunction

" tests how rightmargin affects window content:
function Test_rightmargin_basics()
  enew!
  set ff=unix

  let visible_width = 50
  execute visible_width 'vsplit'

  call setline(1, s:lines)

  set list listchars=extends:> nowrap

  " no rightmargin, no wrap:
  let expected_lines = [
    \'Vim is a greatly improved version of the good old>',
    \'features have been added: multi-level undo, synta>',
    \'history, on-line help, spell checking, filename c>',
    \'script language, etc.                             ',
    \'~                                                 ',
    \'~                                                 ',
    \'~                                                 ',
    \'~                                                 ',
  \]
  let actual_lines = ScreenLines([1, expected_lines->len()], visible_width)
  call assert_equal(expected_lines, actual_lines)

  " set rightmargin and increase window width by same amount:
  vertical resize +5
  set rightmargin=5
  let actual_lines = ScreenLines([1, expected_lines->len()], visible_width)
  call assert_equal(expected_lines, actual_lines)

  " resize back, unset rightmargin and enable wrap:
  execute "vertical resize" visible_width
  set rightmargin=0 wrap
  let expected_lines = [
    \'Vim is a greatly improved version of the good old ',
    \'UNIX editor Vi.  Many new                         ',
    \'features have been added: multi-level undo, syntax',
    \' highlighting, command line                       ',
    \'history, on-line help, spell checking, filename co',
    \'mpletion, block operations,                       ',
    \'script language, etc.                             ',
    \'~                                                 ',
  \]
  let actual_lines = ScreenLines([1, expected_lines->len()], visible_width)
  call assert_equal(expected_lines, actual_lines)

  " set rightmargin and increase window width by same amount:
  vertical resize +5
  set rightmargin=5
  let actual_lines = ScreenLines([1, expected_lines->len()], visible_width)
  call assert_equal(expected_lines, actual_lines)

  if has('rightleft')
    " resize back, unset rightmargin, disable wrap, set rightleft:
    execute "vertical resize" visible_width
    set rightmargin=0 rightleft nowrap
    let expected_lines = [
      \'>dlo doog eht fo noisrev devorpmi yltaerg a si miV',
      \'>atnys ,odnu level-itlum :dedda neeb evah serutaef',
      \'>c emanelif ,gnikcehc lleps ,pleh enil-no ,yrotsih',
      \'                             .cte ,egaugnal tpircs',
      \'                                                 ~',
      \'                                                 ~',
      \'                                                 ~',
      \'                                                 ~',
    \]
    let actual_lines = ScreenLines([1, expected_lines->len()], visible_width)
    call assert_equal(expected_lines, actual_lines)

    " set rightmargin and increase window width by same amount:
    vertical resize +5
    set rightmargin=5
    let actual_lines = ScreenLines([1, expected_lines->len()], visible_width + 5)->map({_, v -> v[5 :]})
    call assert_equal(expected_lines, actual_lines)

    " resize back, unset rightmargin, enable wrap:
    execute "vertical resize" visible_width
    set rightmargin=0 wrap
    let expected_lines = [
      \' dlo doog eht fo noisrev devorpmi yltaerg a si miV',
      \'                         wen ynaM  .iV rotide XINU',
      \'xatnys ,odnu level-itlum :dedda neeb evah serutaef',
      \'                       enil dnammoc ,gnithgilhgih ',
      \'oc emanelif ,gnikcehc lleps ,pleh enil-no ,yrotsih',
      \'                       ,snoitarepo kcolb ,noitelpm',
      \'                             .cte ,egaugnal tpircs',
      \'                                                 ~',
    \]
    let actual_lines = ScreenLines([1, expected_lines->len()], visible_width)
    call assert_equal(expected_lines, actual_lines)

    " set rightmargin and increase window width by same amount:
    vertical resize +5
    set rightmargin=5
    let actual_lines = ScreenLines([1, expected_lines->len()], visible_width + 5)->map({_, v -> v[5 :]})
    call assert_equal(expected_lines, actual_lines)
  endif

  only!
  enew!
  set ff& list& listchars& wrap& rightmargin& rightleft&
endfunction

" tests double-cell characters:
function Test_rightmargin_double_cell()
  enew!
  set ff=unix
  set mouse=a

  let visible_width = 50
  execute visible_width 'vsplit'

  call setline(1, s:double_cell_lines)

  set list listchars=extends:> wrap

  " no rightmargin:
  let expected_lines = [
    \'Ｖｉｍ ｉｓ ａ ｇｒｅａｔｌｙ ｉｍｐｒｏｖｅｄ ｖ>',
    \'ｅｒｓｉｏｎ ｏｆ ｔｈｅ                          ',
    \'ｇｏｏｄ ｏｌｄ ＵＮＩＸ ｅｄｉｔｏｒ Ｖｉ．  Ｍａ',
    \'ｎｙ ｎｅｗ                                       ',
    \'ｆｅａｔｕｒｅｓ ｈａｖｅ ｂｅｅｎ ａｄｄｅｄ： ｍ',
    \'ｕｌｔｉ－ｌｅｖｅｌ                              ',
    \'ｕｎｄｏ， ｓｙｎｔａｘ ｈｉｇｈｌｉｇｈｔｉｎｇ，',
    \' ｃｏｍｍａｎｄ ｌｉｎｅ                          '
  \]
  let actual_lines = ScreenLines([1, expected_lines->len()], visible_width)
  call assert_equal(expected_lines, actual_lines)

  " double-cell character that doesn't fit at the end of a wrapped line is put to next line,
  " clicking such character also causes the cursor to jump to next line
  call MouseClick(1, visible_width)
  let expected_winpos = [2, 1]
  let actual_winpos = [winline(), wincol()]
  call assert_equal(expected_winpos, actual_winpos)

  " set rightmargin and increase window width by same amount:
  vertical resize +5
  set rightmargin=5
  let actual_lines = ScreenLines([1, expected_lines->len()], visible_width)
  call assert_equal(expected_lines, actual_lines)

  call MouseClick(1, visible_width)
  let actual_winpos = [winline(), wincol()]
  call assert_equal(expected_winpos, actual_winpos)

  " similar as above but with breakindent,
  " double-cell characters can cause cursor placement problems
  set breakindent breakindentopt=min:20 expandtab
  execute "norm! gg5i\<Tab>"

  call MouseClick(6, 17)
  let expected_winpos = [6, 17]
  let actual_winpos = [winline(), wincol()]
  call assert_equal(expected_winpos, actual_winpos)

  only!
  enew!
  set ff& list& listchars& wrap& rightmargin& rightleft& breakindent& breakindentopt& expandtab mouse&
endfunction

" tests breakindent and breakindentopt min:
function Test_rightmargin_breakindent_min()
  enew!
  set ff=unix
  set mouse=a

  let visible_width = 50
  execute visible_width 'vsplit'

  call setline(1, s:lines)

  set wrap breakindent breakindentopt=min:25 rightmargin=5
  execute "norm! 5i\<Tab>"

  let expected_lines = [
    \'                                        Vim i     ',
    \'                    s a greatly improved vers     ',
    \'                    ion of the good old UNIX      ',
    \'                    editor Vi.  Many new          ',
    \'features have been added: multi-level undo, s     ',
    \'yntax highlighting, command line                  ',
    \'history, on-line help, spell checking, filena     ',
    \'me completion, block operations,                  ',
    \'script language, etc.                             ',
    \'~                                                 ',
    \'~                                                 ',
  \]
  let actual_lines = ScreenLines([1, expected_lines->len()], visible_width)
  call assert_equal(expected_lines, actual_lines)

  call MouseClick(3, 22)
  let expected_winpos = [3, 22]
  let actual_winpos = [winline(), wincol()]
  call assert_equal(expected_winpos, actual_winpos)

  only!
  enew!
  set wrap& rightmargin& ff& breakindent& breakindentopt& mouse&
endfunction

" tests gq, :center and :right commands:
function Test_rightmargin_format_and_align()
  enew!
  set ff=unix

  let visible_width = 50
  execute visible_width 'vsplit'

  call setline(1, s:lines)

  set rightmargin=10 expandtab

  " wrapmargin plus rightmargin exceed window width, wrapmargin will be ignored:
  set wrapmargin=45
  norm! ggVGgq
  let expected_lines = [
    \'Vim is a greatly improved version of              ',
    \'the good old UNIX editor Vi.  Many new            ',
    \'features have been added: multi-level             ',
    \'undo, syntax highlighting, command line           ',
    \'history, on-line help, spell checking,            ',
    \'filename completion, block operations,            ',
    \'script language, etc.                             '
  \]
  let actual_lines = ScreenLines([1, expected_lines->len()], visible_width)
  call assert_equal(expected_lines, actual_lines)

  " format to window width minus 'wrapmargin' minus 'rightmargin':
  set wrapmargin=10
  norm! ggVGgq
  let expected_lines = [
    \'Vim is a greatly improved                         ',
    \'version of the good old UNIX                      ',
    \'editor Vi.  Many new features                     ',
    \'have been added: multi-level                      ',
    \'undo, syntax highlighting,                        ',
    \'command line history, on-line                     ',
    \'help, spell checking, filename                    ',
    \'completion, block operations,                     ',
    \'script language, etc.                             '
  \]
  let actual_lines = ScreenLines([1, expected_lines->len()], visible_width)
  call assert_equal(expected_lines, actual_lines)

  set wrapmargin=1

  " align center:
  :%center
  let expected_lines = [
    \'       Vim is a greatly improved                  ',
    \'     version of the good old UNIX                 ',
    \'     editor Vi.  Many new features                ',
    \'     have been added: multi-level                 ',
    \'      undo, syntax highlighting,                  ',
    \'     command line history, on-line                ',
    \'    help, spell checking, filename                ',
    \'     completion, block operations,                ',
    \'         script language, etc.                    '
  \]
  let actual_lines = ScreenLines([1, expected_lines->len()], visible_width)
  call assert_equal(expected_lines, actual_lines)

  " align right:
  :%right
  let expected_lines = [
    \'              Vim is a greatly improved           ',
    \'           version of the good old UNIX           ',
    \'          editor Vi.  Many new features           ',
    \'           have been added: multi-level           ',
    \'             undo, syntax highlighting,           ',
    \'          command line history, on-line           ',
    \'         help, spell checking, filename           ',
    \'          completion, block operations,           ',
    \'                  script language, etc.           '
  \]
  let actual_lines = ScreenLines([1, expected_lines->len()], visible_width)
  call assert_equal(expected_lines, actual_lines)

  only!
  enew!
  set ff& rightmargin& wrapmargin& expandtab&
endfunction

" tests motions: g^ / g0 / gm / g$ / zH / zL / ze / zl / zh
function Test_rightmargin_motions()
  enew!
  set ff=unix

  let visible_width = 50
  execute visible_width 'vsplit'

  call setline(1, s:lines)

  set rightmargin=10 scrolloff=0

  " START: testing g$ / gm / zH / zL / ze / zl / zh
  "-----------------------
  " first test with wrap and smoothscroll disabled:
  set nosmoothscroll nowrap

  " reset to initial state:
  norm! 0gg

  " go to middle visible character:
  norm! gm
  let expected_col = 21
  let actual_col = col('.')
  call assert_equal(expected_col, actual_col)
  call assert_equal(expected_col, (visible_width - &rightmargin) / 2 + 1)

  " go to last visible character:
  norm! g$
  let expected_col = 40
  let actual_col = col('.')
  call assert_equal(expected_col, actual_col)
  call assert_equal(expected_col, visible_width - &rightmargin)

  " reset to initial state:
  norm! 0gg

  " scroll right half-page:
  norm! zL
  let expected_leftcol = 20
  let actual_leftcol = getwininfo(win_getid())[0].leftcol
  call assert_equal(expected_leftcol, actual_leftcol)
  call assert_equal(expected_leftcol, (visible_width - &rightmargin) / 2)
  let expected_col = expected_leftcol + 1 " 21
  let actual_col = col('.')
  call assert_equal(expected_col, actual_col)

  " scroll right another half-page:
  norm! zL
  let expected_leftcol = 40
  let actual_leftcol = getwininfo(win_getid())[0].leftcol
  call assert_equal(expected_leftcol, actual_leftcol)
  call assert_equal(expected_leftcol, visible_width - &rightmargin)
  let expected_col = 41
  let actual_col = col('.')
  call assert_equal(expected_col, actual_col)
  call assert_equal(expected_col, expected_leftcol + 1)

  " scroll left half-page:
  norm! zH
  let expected_leftcol = 20
  let actual_leftcol = getwininfo(win_getid())[0].leftcol
  call assert_equal(expected_leftcol, actual_leftcol)
  call assert_equal(expected_leftcol, (visible_width - &rightmargin) / 2)
  let expected_col = expected_col " did not change, 41
  let actual_col = col('.')
  call assert_equal(expected_col, actual_col)

  " scroll left another half-page:
  norm! zH
  let expected_leftcol = 0
  let actual_leftcol = getwininfo(win_getid())[0].leftcol
  call assert_equal(expected_leftcol, actual_leftcol)
  let expected_col = 40
  let actual_col = col('.')
  call assert_equal(expected_col, actual_col)
  call assert_equal(expected_col, visible_width - &rightmargin)

  " reset to initial state:
  norm! 0gg

  " jump to last character:
  norm! $
  " scroll to position the cursor at the end of the screen:
  norm! ze
  let expected_leftcol = 35
  let actual_leftcol = getwininfo(win_getid())[0].leftcol
  call assert_equal(expected_leftcol, actual_leftcol)
  call assert_equal(expected_leftcol, s:lines[0]->strdisplaywidth() - visible_width + &rightmargin)

  " reset to initial state:
  norm! 0gg

  " scroll to the most right:
  norm! 99zl
  let expected_leftcol = 74
  let actual_leftcol = getwininfo(win_getid())[0].leftcol
  call assert_equal(expected_leftcol, actual_leftcol)
  call assert_equal(expected_leftcol, s:lines[0]->strdisplaywidth() - 1)
  let expected_col = 75
  let actual_col = col('.')
  call assert_equal(expected_col, actual_col)
  call assert_equal(expected_col, s:lines[0]->strdisplaywidth())

  " scroll to the most left:
  norm! 99zh
  let expected_leftcol = 0
  let actual_leftcol = getwininfo(win_getid())[0].leftcol
  call assert_equal(expected_leftcol, actual_leftcol)
  let expected_col = 40
  let actual_col = col('.')
  call assert_equal(expected_col, actual_col)
  call assert_equal(expected_col, visible_width - &rightmargin)

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
  let expected_col = 61
  let actual_col = col('.')
  call assert_equal(expected_col, actual_col)

  " go to last visible character:
  norm! g$
  let expected_col = 77
  let actual_col = col('.')
  call assert_equal(expected_col, actual_col)

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
  let expected_col = 21
  let actual_col = col('.')
  call assert_equal(expected_col, actual_col)

  " go to last visible character:
  norm! g$
  let expected_col = 40
  let actual_col = col('.')
  call assert_equal(expected_col, actual_col)
  " END: testing g$ / gm / zH / zL / ze / zl / zh
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
  let expected_col = 5
  let actual_col = col('.')
  call assert_equal(expected_col, actual_col)

  " go to first visible character:
  norm! g0
  let expected_col = 4
  let actual_col = col('.')
  call assert_equal(expected_col, actual_col)

  " repeat with wrap enabled:
  set wrap

  " jump one screen line down (expected to have first character blank):
  norm! gj

  " go to first non-blank visible character:
  norm! g^
  let expected_col = 42
  let actual_col = col('.')
  call assert_equal(expected_col, actual_col)

  " go to first visible character:
  norm! g0
  let expected_col = 41
  let actual_col = col('.')
  call assert_equal(expected_col, actual_col)

  " repeat with smoothscroll enabled:
  set wrap smoothscroll

  " scroll down 3 lines (expected to have first character blank):
  execute "norm! 3\<C-e>"

  " go to first non-blank visible character:
  norm! g^
  let expected_col = 45
  let actual_col = col('.')
  call assert_equal(expected_col, actual_col)

  " go to first visible character:
  norm! g0
  let expected_col = 44
  let actual_col = col('.')
  call assert_equal(expected_col, actual_col)
  " END: testing g^ and g0
  "-----------------------

  only!
  enew!
  set ff& rightmargin& wrapmargin& wrap& smoothscroll& scrolloff&
endfunction

" tests motions: gj / gk
function Test_rightmargin_gj_gk()
  enew!
  set ff=unix

  call setline(1, s:lines)

  30vsplit

  set wrap rightmargin=5 smoothscroll scrolloff=0 noshowmode noshowcmd

  execute "norm! 2\<C-e>"
  norm! 3G8|

  let expected_line = 3
  let actual_line = line('.')
  call assert_equal(expected_line, actual_line)

  let expected_col = 8
  let actual_col = col('.')
  call assert_equal(expected_col, actual_col)
  let actual_line = line('.')
  call assert_equal(expected_line, actual_line)

  " jump screen lines down:
  norm! gj
  let expected_col = 33
  let actual_col = col('.')
  call assert_equal(expected_col, actual_col)
  let actual_line = line('.')
  call assert_equal(expected_line, actual_line)

  norm! gj
  let expected_col = 58
  let actual_col = col('.')
  call assert_equal(expected_col, actual_col)
  let actual_line = line('.')
  call assert_equal(expected_line, actual_line)

  norm! gj
  let expected_col = 77
  let actual_col = col('.')
  call assert_equal(expected_col, actual_col)
  let actual_line = line('.')
  call assert_equal(expected_line, actual_line)

  " jump screen lines up:
  norm! gk
  let expected_col = 58
  let actual_col = col('.')
  call assert_equal(expected_col, actual_col)
  let actual_line = line('.')
  call assert_equal(expected_line, actual_line)

  norm! gk
  let expected_col = 33
  let actual_col = col('.')
  call assert_equal(expected_col, actual_col)
  let actual_line = line('.')
  call assert_equal(expected_line, actual_line)

  norm! gk
  let expected_col = 8
  let actual_col = col('.')
  call assert_equal(expected_col, actual_col)
  let actual_line = line('.')
  call assert_equal(expected_line, actual_line)

  set ff& rightmargin& smoothscroll& wrap& scrolloff&
endfunction

" test that scrolling and resizing windows properly redraws blank areas, statuslines and window splits:
function Test_rightmargin_scroll_and_resize()
  CheckScreendump
  CheckRunVimInTerminal

  let script_lines =<< trim eval END
    set list listchars=extends:>
    colorscheme koehler
    set nowrap rightmargin=5 wincolor=Error scrolloff=0

    botright vsplit
    call setline(1, {s:lines})

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

" test 'wrap' and 'smoothscroll' enabled:
function Test_rightmargin_wrap()
  CheckScreendump
  CheckRunVimInTerminal

  let script_lines =<< trim eval END
    function MouseDrag(lnum_start, col_start, lnum_end, col_end)
      call test_setmouse(a:lnum_start, a:col_start)
      call feedkeys("\<LeftMouse>\<Ignore>", "xt")

      call test_setmouse(a:lnum_end, a:col_end)
      call feedkeys("\<LeftDrag>\<Ignore>", "xt")

      call feedkeys("\<LeftRelease>\<Ignore>", "xt")
    endfunction

    call setline(1, {s:lines})
    30vsplit
    set wrap rightmargin=5 smoothscroll scrolloff=0 noshowmode noshowcmd
    execute "norm! 3\<C-e>"

    call MouseDrag(5, 8, 7, 11)
    echo 'visual range: ' .. line('v') .. ':' .. col('v') .. ' - ' .. line('.') .. ':' .. col('.')
  END

  call writefile(script_lines, 'XTest_rightmargin_wrap_and_visual', 'D')
  let buf = RunVimInTerminal('-S XTest_rightmargin_wrap_and_visual', {'rows': 20, 'cols': 70})
  call VerifyScreenDump(buf, 'Test_rightmargin_wrap_1', {})

  " stop visual:
  call term_sendkeys(buf, "\<Esc>")

  " set cursorline:
  call term_sendkeys(buf, ":set cursorline\<CR>")
  call VerifyScreenDump(buf, 'Test_rightmargin_wrap_2', {})

  " set cursorlineopt=screenline:
  call term_sendkeys(buf, ":set cursorlineopt=screenline\<CR>")
  call VerifyScreenDump(buf, 'Test_rightmargin_wrap_3', {})

  " clean up
  call StopVimInTerminal(buf)
endfunction

" test cursor skipping text property with wrapped virtual text
" and jumping to next line:
function Test_rightmargin_textprop_wrapped_virtual_text()
  enew!
  set ff=unix

  call setline(1, s:lines)
  30vsplit
  set wrap rightmargin=15 smoothscroll scrolloff=0 noshowmode noshowcmd

  call prop_type_add('virtual_text_prop', #{highlight: "ErrorMsg"})
  call prop_add(2, 0, #{
    \type: 'virtual_text_prop',
    \text: 'some long virtual text that should wrap',
    \text_align: 'after',
    \text_padding_left: 10
  \})

  norm 11gj
  let expected_winpos = [13, 1]
  let actual_winpos = [winline(), wincol()]
  call assert_equal(expected_winpos, actual_winpos)

  set ff& wrap& rightmargin& smoothscroll& scrolloff& showmode& showcmd&
endfunction

" tests balloon feature:
function Test_rightmargin_popup_beval()
  CheckFeature balloon_eval_term
  CheckScreendump
  CheckRunVimInTerminal

  let script_lines =<< trim eval END
    function MyBalloonExpr()
      return "line " .. v:beval_lnum .. " column " .. v:beval_col .. ":\n" .. v:beval_text
    endfunction

    function MouseMove(lnum, col)
      call test_setmouse(a:lnum, a:col)
      call feedkeys("\<MouseMove>\<Ignore>", "xt")
    endfunction

    set balloonevalterm balloonexpr=MyBalloonExpr() balloondelay=100 updatetime=300 mouse=a
    set list listchars=extends:> nowrap

    call setline(1, {s:lines})
  END
  call writefile(script_lines, 'XTest_rightmargin_beval', 'D')

  let buf = RunVimInTerminal('-S XTest_rightmargin_beval', {'rows': 20, 'cols': 50})

  " balloon at first visible column:
  call term_sendkeys(buf, ":call MouseMove(3, 1)\<CR>")
  sleep 150m
  call VerifyScreenDump(buf, 'Test_rightmargin_beval_1', {})

  " balloon at last visible column:
  call term_sendkeys(buf, ":call MouseMove(3, 49)\<CR>")
  sleep 150m
  call VerifyScreenDump(buf, 'Test_rightmargin_beval_2', {})

  call term_sendkeys(buf, ":set rightmargin=5\<CR>")

  " balloon at first visible column:
  call term_sendkeys(buf, ":call MouseMove(3, 1)\<CR>")
  sleep 150m
  call VerifyScreenDump(buf, 'Test_rightmargin_beval_3', {})

  " no balloon in rightmargin area:
  call term_sendkeys(buf, ":call MouseMove(3, 49)\<CR>")
  sleep 150m
  call VerifyScreenDump(buf, 'Test_rightmargin_beval_4', {})

  " clean up
  call StopVimInTerminal(buf)
endfunction

" tests foldtext and fillchars with rightmargin and rightleft:
function Test_rightmargin_foldtext_and_fillchars()
  CheckFeature rightleft
  CheckScreendump
  CheckRunVimInTerminal

  let script_lines =<< trim eval END
    let g:lines           = {s:lines[0 : 3]}            ->map({{_, v -> strcharpart(v, 0, 30)}})
    let g:multibute_lines = {s:double_cell_lines[0 : 3]}->map({{_, v -> strcharpart(v, 0, 20)}})

    call setline(1, g:lines)
    1,3fold

    setlocal rightmargin=5 nowrap
    set noshowmode noshowcmd
  END
  call writefile(script_lines, 'XTest_rightmargin_foldtext_and_fillchars', 'D')
  let buf = RunVimInTerminal('-S XTest_rightmargin_foldtext_and_fillchars', {'rows': 10, 'cols': 70})

  call VerifyScreenDump(buf, 'Test_rightmargin_foldtext_and_fillchars_1', {})

  " enable rightleft:
  call term_sendkeys(buf, ":set rightleft\<CR>")
  call VerifyScreenDump(buf, 'Test_rightmargin_foldtext_and_fillchars_2', {})

  call term_sendkeys(buf, ":set norightleft\<CR>")
  call term_sendkeys(buf, ":call setline(1, g:multibute_lines)\<CR>")
  call VerifyScreenDump(buf, 'Test_rightmargin_foldtext_and_fillchars_3', {})

  " enable rightleft:
  call term_sendkeys(buf, ":set rightleft\<CR>")
  call VerifyScreenDump(buf, 'Test_rightmargin_foldtext_and_fillchars_4', {})

  " clean up
  call StopVimInTerminal(buf)
endfunction

" tests diff feature:
function Test_rightmargin_diff()
  CheckScreendump
  CheckRunVimInTerminal

  let script_lines =<< trim eval END
    vnew

    let win1_lines = {s:lines}->copy()
    call remove(win1_lines, 2)
    call setbufline(winbufnr(1), 1, win1_lines)

    let win2_lines = {s:lines}->copy() + ['']
    let win2_lines[2] = 'foo bar'
    call setbufline(winbufnr(2), 1, win2_lines)

    windo setlocal list listchars=extends:> nowrap diffopt+=context:0
    windo diffthis
    wincmd =
  END
  call writefile(script_lines, 'XTest_rightmargin_diff', 'D')

  let buf = RunVimInTerminal('-S XTest_rightmargin_diff', {'rows': 20, 'cols': 70})

  " no rightmargin:
  call VerifyScreenDump(buf, 'Test_rightmargin_diff_1', {})

  " set rightmargin:
  call term_sendkeys(buf, ":windo set rightmargin=5\<CR>")
  call VerifyScreenDump(buf, 'Test_rightmargin_diff_2', {})

  " no rightmargin, enable rightleft:
  call term_sendkeys(buf, ":windo set rightmargin=0 rightleft\<CR>")
  call VerifyScreenDump(buf, 'Test_rightmargin_diff_3', {})

  " set rightmargin, rightleft enabled:
  call term_sendkeys(buf, ":windo set rightmargin=5\<CR>")
  call VerifyScreenDump(buf, 'Test_rightmargin_diff_4', {})

  " clean up
  call StopVimInTerminal(buf)
endfunction

" vim: shiftwidth=2 sts=2 expandtab
