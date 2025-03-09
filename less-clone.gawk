#!/usr/bin/gawk -f
#
# Copyright (C) 2025 Pedro Maimere
#
# This program is licensed under the Do What The Fuck You Want To Public License (WTFPL), Version 2.
# You just DO WHAT THE FUCK YOU WANT TO.
# See the LICENSE file or http://www.wtfpl.net/ for more details.
#
#

### Simple less clone written in GNU AWK.
#
# Call it as ./less-clone.gawk or ./less-clone.gawk <filename>
#
#      Command                What it does
#   j/k/arrow keys      Move up and down the file.
#         q                       Quit


# TODO
# - Properly handle change of status line.
# - Command option (:) is still useless. Not fully implemented.
# - Handle invalid filename
# - Simplify change of terminal properties with stty and tput. It is too hard coded now.


BEGIN {
    # Setting errors to nonfatal, to allow handling with fatal errors
    #PROCINFO["NONFATAL"] = 1
    #ERRNO = 0
    
    # Initialize terminal settings
    "tput lines" | getline height
    "tput cols" | getline width
    content_lines = height - 2  # Reserve 2 lines for status and command
    
    # Check if a file was provided via command line
    if (ARGC < 2) {
        # Start the status line and command line if no argument given
        system("clear")

        set_status("Enter filename (or 'q' to quit):")
        getline filename < "/dev/tty"
        if (filename == "q") {
            system("tput cnorm")
            system("clear")
            exit 0
        }
        ARGV[1] = filename
        ARGC = 2
    }
    
    # Validate file existence
    while (system("test -f " ARGV[1]) != 0) {
        system("stty cooked echo")
        system("tput cnorm")
        system("clear")
        set_status("Error: File '" ARGV[1] "' does not exist. Enter filename (or 'q' to quit):")
        getline filename < "/dev/tty"
        gsub("\033","",filename) # Removes Escape if any special key is pressed on prompt
        if (filename == "q") {
            system("tput cnorm")
            system("clear")
            exit 0
        }
        ARGV[1] = filename
    }

    # Set terminal to raw mode and hide cursor
    system("stty raw -echo")
    system("tput civis")

    # Initialize variables
    start_line = 1
    total_lines = 0
}

BEGINFILE {
    # Start loading the file into an array
    start_line = 1
    total_lines = 0
}

{
    # Store each line in an array
    total_lines++
    lines[total_lines] = $0
}

ENDFILE {
    # File has been fully read; start the interactive loop
    while (1) {
        display_content()
        get_input()
    }
}

function set_status(status_message) {
    system("tput cup " (height - 2) " 0")
    printf "\033[7m%s\033[0m\r\n", substr(status_message, 1, width)
    printf "> "
}

function display_content() {
    # Clear screen
    system("clear")

    # Display content
    for (i = start_line; i < start_line + content_lines && i <= total_lines; i++) {
        printf "%s\r\n", substr(lines[i], 1, width)
    }

    # Display status line
    set_status("Line " start_line "/" total_lines " (Use j/k or ↑/↓ to move, q to quit)")
}

function get_input() {
    # Read a single character without Enter
    cmd = "dd bs=1 count=1 < /dev/tty 2>/dev/null"
    cmd | getline key
    close(cmd)

    if (key == "\033") {  # Down or potential arrow key
        cmd = "dd bs=1 count=2 < /dev/tty 2>/dev/null"
        cmd | getline extra
        close(cmd)
        if (extra == "[B") key = "j"  # Down arrow
        else if (extra == "[A") key = "k"  # Up arrow
    }
    if (key == "q") {# - 
        system("stty cooked echo")
        system("tput cnorm")
        system("clear")
        exit 0
    }
    else if (key == "j" && start_line + content_lines <= total_lines) {
        start_line++
    }
    else if (key == "k" && start_line > 1) {
        start_line--
    }
    else if (key == "f") {  # Page down
        if (start_line + content_lines <= total_lines) {
            start_line += content_lines
            if (start_line + content_lines > total_lines) {
                start_line = total_lines - content_lines + 1
            }
        }
    }
    else if (key == "b") {  # Page up
        if (start_line > 1) {
            start_line -= content_lines
            if (start_line < 1) start_line = 1
        }
    }
    else if (key == ":") {  # Command mode
        system("tput cup " (height - 1) " 2")
        printf "                "  # Clear previous command
        system("tput cup " (height - 1) " 2")
        system("stty cooked echo")  # Temporarily enable line input
        getline cmd < "/dev/tty"
        system("stty raw -echo")    # Back to raw mode
        if (cmd == "q") {
            system("stty cooked echo")
            system("tput cnorm")
            system("clear")
            exit 0
        }
        status = "Unknown command: " cmd
    }
}

END {
    # Restore terminal settings on exit
    system("stty cooked echo")
    system("tput cnorm")
    system("clear")
}
