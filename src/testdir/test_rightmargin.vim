vim9script

# Tests for 'rightmargin'

source util/view_util.vim
source util/screendump.vim

var s_lines = [
  'Vim is a greatly improved version of the good old UNIX editor Vi.  Many new',
  'features have been added: multi-level undo, syntax highlighting, command line',
  'history, on-line help, spell checking, filename completion, block operations,',
  'script language, etc.',
]

def g:Test_rightmargin_basics()
  CheckOption rightmargin

  enew!
  set ff=unix

  set list lcs=extends:> nowrap
  set columns=50

  setline(1, s_lines)

  {
    var expected = [
      'Vim is a greatly improved version of the good old>',
      'features have been added: multi-level undo, synta>',
      'history, on-line help, spell checking, filename c>',
      'script language, etc.                             ',
      '~                                                 ',
      '~                                                 ',
      '~                                                 ',
      '~                                                 ',
    ]
    var actual = g:ScreenLines([1, 8], &columns)
    assert_equal(expected, actual)
  }

  set rmar=5
  {
    var expected = [
      'Vim is a greatly improved version of the goo>     ',
      'features have been added: multi-level undo, >     ',
      'history, on-line help, spell checking, filen>     ',
      'script language, etc.                             ',
      '~                                                 ',
      '~                                                 ',
      '~                                                 ',
      '~                                                 ',
    ]
    var actual = g:ScreenLines([1, 8], &columns)
    assert_equal(expected, actual)
  }

  set rmar& nowrap&
  {
    var expected = [
      'Vim is a greatly improved version of the good old ',
      'UNIX editor Vi.  Many new                         ',
      'features have been added: multi-level undo, syntax',
      ' highlighting, command line                       ',
      'history, on-line help, spell checking, filename co',
      'mpletion, block operations,                       ',
      'script language, etc.                             ',
      '~                                                 ',
    ]
    var actual = g:ScreenLines([1, 8], &columns)
    assert_equal(expected, actual)
  }

  set rmar=5
  {
    var expected = [
      'Vim is a greatly improved version of the good     ',
      ' old UNIX editor Vi.  Many new                    ',
      'features have been added: multi-level undo, s     ',
      'yntax highlighting, command line                  ',
      'history, on-line help, spell checking, filena     ',
      'me completion, block operations,                  ',
      'script language, etc.                             ',
      '~                                                 ',
    ]
    var actual = g:ScreenLines([1, 8], &columns)
    assert_equal(expected, actual)
  }

  if !has('rightleft')
    enew!
    set list& lcs& wrap& rmar& columns& rightleft& ff&
    return
  endif

  set nowrap rmar& rightleft
  {
    var expected = [
      '>dlo doog eht fo noisrev devorpmi yltaerg a si miV',
      '>atnys ,odnu level-itlum :dedda neeb evah serutaef',
      '>c emanelif ,gnikcehc lleps ,pleh enil-no ,yrotsih',
      '                             .cte ,egaugnal tpircs',
      '                                                 ~',
      '                                                 ~',
      '                                                 ~',
      '                                                 ~',
    ]
    var actual = g:ScreenLines([1, 8], &columns)
    assert_equal(expected, actual)
  }

  set rmar=5
  {
    var expected = [
      '     >oog eht fo noisrev devorpmi yltaerg a si miV',
      '     > ,odnu level-itlum :dedda neeb evah serutaef',
      '     >nelif ,gnikcehc lleps ,pleh enil-no ,yrotsih',
      '                             .cte ,egaugnal tpircs',
      '                                                 ~',
      '                                                 ~',
      '                                                 ~',
      '                                                 ~',
    ]
    var actual = g:ScreenLines([1, 8], &columns)
    assert_equal(expected, actual)
  }

  set rmar& nowrap&
  {
    var expected = [
      ' dlo doog eht fo noisrev devorpmi yltaerg a si miV',
      '                         wen ynaM  .iV rotide XINU',
      'xatnys ,odnu level-itlum :dedda neeb evah serutaef',
      '                       enil dnammoc ,gnithgilhgih ',
      'oc emanelif ,gnikcehc lleps ,pleh enil-no ,yrotsih',
      '                       ,snoitarepo kcolb ,noitelpm',
      '                             .cte ,egaugnal tpircs',
      '                                                 ~',
    ]
    var actual = g:ScreenLines([1, 8], &columns)
    assert_equal(expected, actual)
  }

  set rmar=5
  {
    var expected = [
      '     doog eht fo noisrev devorpmi yltaerg a si miV',
      '                    wen ynaM  .iV rotide XINU dlo ',
      '     s ,odnu level-itlum :dedda neeb evah serutaef',
      '                  enil dnammoc ,gnithgilhgih xatny',
      '     anelif ,gnikcehc lleps ,pleh enil-no ,yrotsih',
      '                  ,snoitarepo kcolb ,noitelpmoc em',
      '                             .cte ,egaugnal tpircs',
      '                                                 ~',
    ]
    var actual = g:ScreenLines([1, 8], &columns)
    assert_equal(expected, actual)
  }

  enew!
  set list& lcs& wrap& rmar& columns& rightleft& ff&
enddef

def g:Test_rightmargin_splits_and_colors()
  CheckOption rightmargin
  CheckScreendump
  CheckRunVimInTerminal

  var script_lines =<< trim eval END
    vim9script
    setline(1, {s_lines})

    set list lcs=extends:>
    colorscheme koehler
    set nowrap rmar=5 wincolor=Error scrolloff=0

    botright vsplit

    set rmar=5 rightleft
    windo norm zt
  END

  writefile(script_lines, 'XTest_rightmargin_splits_and_colors', 'D')
  var buf = g:RunVimInTerminal('-S XTest_rightmargin_splits_and_colors', {rows: 20, cols: 70})

  g:VerifyScreenDump(buf, 'Test_rightmargin_splits_and_colors_1', {})

  # scrolling down:
  term_sendkeys(buf, ":windo norm Gzt\<CR>")
  g:VerifyScreenDump(buf, 'Test_rightmargin_splits_and_colors_2', {})

  # scrolling back to top:
  term_sendkeys(buf, ":windo norm gg\<CR>")
  g:VerifyScreenDump(buf, 'Test_rightmargin_splits_and_colors_3', {})

  # increasing width:
  term_sendkeys(buf, ":vertical resize +20\<CR>")
  g:VerifyScreenDump(buf, 'Test_rightmargin_splits_and_colors_4', {})

  # decreasing width:
  term_sendkeys(buf, ":vertical resize -40\<CR>")
  g:VerifyScreenDump(buf, 'Test_rightmargin_splits_and_colors_5', {})

  # clean up
  g:StopVimInTerminal(buf)
enddef

def g:Test_rightmargin_popup_beval()
  CheckOption rightmargin
  CheckFeature balloon_eval_term
  CheckScreendump
  CheckRunVimInTerminal

  var script_lines =<< trim eval END
    vim9script
    setline(1, {s_lines})

    def g:MyBalloonExpr(): string
      return "line " .. v:beval_lnum .. " column " .. v:beval_col .. ":\n" .. v:beval_text
    enddef

    def g:Trigger(lnum: number, col: number)
      test_setmouse(lnum, col)
      feedkeys("\<MouseMove>\<Ignore>", "xt")
    enddef

    set balloonevalterm balloonexpr=g:MyBalloonExpr() balloondelay=100 updatetime=300
    set list lcs=extends:> nowrap
  END
  writefile(script_lines, 'XTest_rightmargin_beval', 'D')

  var buf = g:RunVimInTerminal('-S XTest_rightmargin_beval', {rows: 20, cols: 50})

  # balloon at first visible column:
  term_sendkeys(buf, ":call g:Trigger(3, 1)\<CR>")
  sleep 150m
  g:VerifyScreenDump(buf, 'Test_rightmargin_beval_1', {})

  # balloon at last visible column:
  term_sendkeys(buf, ":call g:Trigger(3, 49)\<CR>")
  sleep 150m
  g:VerifyScreenDump(buf, 'Test_rightmargin_beval_2', {})

  term_sendkeys(buf, ":set rmar=5\<CR>")

  # balloon at first visible column:
  term_sendkeys(buf, ":call g:Trigger(3, 1)\<CR>")
  sleep 150m
  g:VerifyScreenDump(buf, 'Test_rightmargin_beval_3', {})

  # no balloon in rightmargin area:
  term_sendkeys(buf, ":call g:Trigger(3, 49)\<CR>")
  sleep 150m
  g:VerifyScreenDump(buf, 'Test_rightmargin_beval_4', {})

  # clean up
  g:StopVimInTerminal(buf)
enddef
