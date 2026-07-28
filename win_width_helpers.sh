#!/bin/bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$REPO_ROOT"

VIMH="src/vim.h"

if grep -qF "static inline int win_content_width" "$VIMH"; then
  exit 0
fi

gawk '
BEGIN{ inserted=0 }
{
  print $0
  if (!inserted && $0 ~ /#include "globals.h"/) {
    print ""
    print "int win_col_off(win_T *wp);"
    print "int curwin_col_off(void);"
    print "int win_col_off2(win_T *wp);"
    print "int curwin_col_off(void);"
    print ""
    print "static inline int win_content_width(win_T *wp)"
    print "{"
    print "    return wp->w_width;"
    print "}"
    print ""
    print "static inline int curwin_content_width(void)"
    print "{"
    print "    return curwin->w_width;"
    print "}"
    print ""
    print "static inline int win_text_width(win_T *wp)"
    print "{"
    print "    return win_content_width(wp) - win_col_off(wp);"
    print "}"
    print ""
    print "static inline int curwin_text_width(void)"
    print "{"
    print "    return curwin_content_width() - curwin_col_off();"
    print "}"
    print ""
    print "static inline int win_text_width2(win_T *wp)"
    print "{"
    print "    return win_text_width(wp) + win_col_off2(wp);"
    print "}"
    inserted=1
  }
}
' "$VIMH" > "$VIMH.new"
mv "$VIMH.new" "$VIMH"

sed -E -i 's@^#define[[:space:]]+W_ENDCOL\([^)]*\).*@#define W_ENDCOL(wp)\t((wp)->w_wincol + win_content_width(wp))@' "$VIMH"

FILES=$(find src -type f \( -name '*.c' -o -name '*.h' -o -name '*.cc' -o -name '*.cpp' \) ! -name vim.h ! -name structs.h)

for f in $FILES; do
  echo "$f"
  gawk '
  {
    s = $0
    # guard:
    gsub(/->w_width[[:space:]]*\+\+/, "<<WW++>>", s)
    gsub(/->w_width[[:space:]]*--/, "<<WW-->>", s)
    gsub(/->w_width[[:space:]]*\+=/, "<<WW+=>>", s)
    gsub(/->w_width[[:space:]]*-=/, "<<WW-=>>", s)
    gsub(/->w_width[[:space:]]*=/, "<<WW=>>", s)
    gsub(/curwin->w_width[[:space:]]*\+\+/, "<<CWW++>>", s)
    gsub(/curwin->w_width[[:space:]]*--/, "<<CWW-->>", s)
    gsub(/curwin->w_width[[:space:]]*\+=/, "<<CWW+=>>", s)
    gsub(/curwin->w_width[[:space:]]*-=/, "<<CWW-=>>", s)
    gsub(/curwin->w_width[[:space:]]*=/, "<<CWW=>>", s)

    # special-case:
    s = gensub(/get_win\(([^)]*)\)->w_width/, "win_content_width(get_win(\\1))", "g", s)

    # fn(args)->w_width:
    s = gensub(/([A-Za-z_][A-Za-z0-9_]*\([^)]*\))->w_width/, "win_content_width(\\1)", "g", s)

    # (expr)->w_width:
    s = gensub(/\(([^()]*)\)->w_width/, "win_content_width(\\1)", "g", s)

    # foo->bar->w_width:
    s = gensub(/([A-Za-z_][A-Za-z0-9_]*(->[A-Za-z_][A-Za-z0-9_]*)*)->w_width/, "win_content_width(\\1)", "g", s)

    # special case:
    s = gensub(/curwin->w_width/, "curwin_content_width()", "g", s)

    # unguard:
    gsub(/<<WW\+\+>>/, "->w_width++", s)
    gsub(/<<WW-->>/, "->w_width--", s)
    gsub(/<<WW\+=>>/, "->w_width +=", s)
    gsub(/<<WW-=>>/, "->w_width -=", s)
    gsub(/<<WW=>>/, "->w_width =", s)
    gsub(/<<CWW\+\+>>/, "curwin->w_width++", s)
    gsub(/<<CWW-->>/, "curwin->w_width--", s)
    gsub(/<<CWW\+=>>/, "curwin->w_width +=", s)
    gsub(/<<CWW-=>>/, "curwin->w_width -=", s)
    gsub(/<<CWW=>>/, "curwin->w_width =", s)

    print s
  }
  ' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
done

echo
echo "remaining occurrences:"
grep -Rn -e "->w_width" src | sed -n '1,200p' || true

echo "done"
