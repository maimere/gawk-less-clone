# One more less, now using GNU AWK

This is a very simple clone of GNU `less`, written in GNU AWK programming language.

### Dependencies

- GNU AWK 4.0+
- ncurses
- coreutils

## What it does

- Read a file calling it as an argument: `./less-clone.gawk <filename>`
- If no argument is given, the program will ask for the filename.
- `h`/`j`/`k`/`l` and arrow keys to scroll on every direction.
- `b`/`f` to scroll one page up or down.
- `q` to quit.

## Yet to be done

- [x] Properly change the status line.
- [ ] Command option (:) is still useless. Not fully implemented. Maybe remove it for good.
- [x] Handle invalid filename
- [ ] Simplify change of terminal properties with stty and tput. It is too hard coded now.
- [x] Handle long lines. Now they are capped by the number of columns of the terminal.
- [ ] On function get_input: substitute if-elses for the `switch` statement.

