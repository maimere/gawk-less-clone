# One more less, now using GNU AWK

This is a very simple clone of GNU `less`, written in GNU AWK programming language.

Besides `gawk` 4.0+, this program relies on `tput` and `clear` from ncurses and `stty` from coreutils. 

## What does it do

- Read a file calling it as an argument: `./less-clone.gawk <filename>`
- If no argument is given, the program will ask for the filename.
- Use `j`/`k`/up and down arrows to browse through the file.
- `q` to quit.

## Yet to be done

- Properly handle change of status line.
- Command option (:) is still useless. Not fully implemented.
- Handle invalid filename
- Simplify change of terminal properties with stty and tput. It is too hard coded now.

