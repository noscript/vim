vim9script

source util/view_util.vim
source util/screendump.vim

def g:Test_rightmargin_basics()
  enew!
  set ff=unix

  set list lcs=extends:>
  set nowrap
  set columns=50

  setline(1,
    [
      'Vim is a greatly improved version of the good old UNIX editor Vi.  Many new',
      'features have been added: multi-level undo, syntax highlighting, command line',
      'history, on-line help, spell checking, filename completion, block operations,',
      'script language, etc.',
    ]
  )

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
  var lines =<< trim END
    vim9script

    setline(1,
      [
        'Vim is a greatly improved version of the good old UNIX editor Vi.  Many new',
        'features have been added: multi-level undo, syntax highlighting, command line',
        'history, on-line help, spell checking, filename completion, block operations,',
        'script language, etc.',
      ]
    )

    set list lcs=extends:>
    colorscheme koehler
    set nowrap rmar=5 wincolor=Error scrolloff=0

    botright vsplit

    set rmar=5 rightleft
    windo norm zt
  END

  writefile(lines, 'XTest_rightmargin', 'D')
  var buf = g:RunVimInTerminal('-S XTest_rightmargin', {rows: 20, cols: 70})

  g:VerifyScreenDump(buf, 'Test_rightmargin', {})

  # scrolling down:
  term_sendkeys(buf, ":windo norm Gzt\<CR>")
  g:VerifyScreenDump(buf, 'Test_rightmargin_scroll_bottom', {})

  # scrolling back to top:
  term_sendkeys(buf, ":windo norm gg\<CR>")
  g:VerifyScreenDump(buf, 'Test_rightmargin_scroll_top', {})

  # increasing width:
  term_sendkeys(buf, ":vertical resize +20\<CR>")
  g:VerifyScreenDump(buf, 'Test_rightmargin_width_increase', {})

  # decreasing width:
  term_sendkeys(buf, ":vertical resize -40\<CR>")
  g:VerifyScreenDump(buf, 'Test_rightmargin_width_decrease', {})
enddef
