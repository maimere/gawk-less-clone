# One more less, now using GNU AWK

This is a very simple clone of GNU `less`, written in GNU AWK programming language.

Besides `gawk` 4.0+, this program relies on `tput` and `clear` from ncurses and `stty` from coreutils. 

## What it does

- Read a file calling it as an argument: `./less-clone.gawk <filename>`
- If no argument is given, the program will ask for the filename.
- `j`/`k`/up and down arrows to scrol one line up or down.
- `b`/`f` to scroll one page up or down.
- `q` to quit.

## Yet to be done

- [x] Properly change the status line.
- [ ] Command option (:) is still useless. Not fully implemented. Maybe remove it for good.
- [x] Handle invalid filename
- [ ] Simplify change of terminal properties with stty and tput. It is too hard coded now.
- [ ] Handle long lines. Now they are capped by the number of columns of the terminal.
- [ ] On function get_input: substitute if-elses for the `switch` statement.

