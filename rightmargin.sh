#!/bin/bash -e

cd $(dirname $0)
#./src/vim -g -f  \
./src/vim -g -f --clean \
  +'set lines=60 columns=180 nocp go=ac | colorscheme koehler' \
  +'vertical split | vertical split' \
  +'windo set list lcs=extends:>,precedes:< nowrap rmar=20 wincolor=Error | norm Gzz' \
  +'set rl' \
  +'wincmd h | set wincolor=' \
  +'vim9 timer_start(100, (_) => execute("wincmd ="))' \
  +'map <S-ScrollWheelDown> <ScrollWheelRight>' \
  +'map <S-ScrollWheelUp> <ScrollWheelLeft>' \
  +'map <F6> <ScriptCmd>set wrap!<CR>' \
README.md
