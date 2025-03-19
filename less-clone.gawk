#!/usr/bin/gawk -f
#
# Copyright (C) 2025 Pedro Maimere
#
# This program is licensed under the Do What The Fuck You Want To Public License (WTFPL), Version 2.
# You just DO WHAT THE FUCK YOU WANT TO.
# See the LICENSE file or http://www.wtfpl.net/ for more details.


BEGIN {
    # Initialize terminal settings
    "tput lines" | getline height
    "tput cols" | getline width
    content_lines = height - 2  # Reserve 2 lines for status and command
    
    stty_config("save")
    
    raw_and_hide()

    # Check if a file was provided via command line
    if (ARGC < 2) {
        # Start the status line and command line if no argument given
        system("clear")
        cooked_and_show()
        set_status("Enter filename (or 'q' to quit):")
        if ( getline filename < "/dev/tty" <= 0 ) {
            system("clear")
            set_status("Unexpected EOF or error. Exiting now.")
            system("read -n1")
            stty_config("restore")
            exit 1
        }
        gsub("\033","",filename) # Removes Escape if any special key is pressed on prompt
        if (filename == "q") {
            system("clear")
            stty_config("restore")
            exit 0
        }
        ARGV[1] = filename
        ARGC = 2
    }
    
    # Validate file existence ==== To be substituted by function validate_filename()
    while (system("test -f " ARGV[1]) != 0) {
        system("clear")
        cooked_and_show()
        set_status("Error: File '" ARGV[1] "' does not exist. Enter filename (or 'q' to quit):")
        if ( getline filename < "/dev/tty" <= 0 ) {
            system("clear")
            set_status("Unexpected EOF or error. Press any key to exit.")
            system("read -n1")
            stty_config("restore")
            exit 1
        }
        gsub("\033","",filename) # Removes Escape if any special key is pressed on prompt
        if (filename == "q") {
            system("clear")
            stty_config("restore")
            exit 0
        }
        ARGV[1] = filename
    }
    
    raw_and_hide()

}

BEGINFILE {
    # New file reset routine
    start_line = 1
    total_lines = 0
    start_col = 1
    max_col = 0
}

{
    # Store each line in an array
    total_lines++
    lines[total_lines] = $0
    if (length($0) > max_col) max_col = length($0)
}

ENDFILE {
    # File has been fully read; start the interactive loop
    while (1) {
        display_content()
        get_input()
    }
}

END {
    # Restore terminal settings on exit
    stty_config("restore")
    system("clear")
}

function stty_config(action) {
    # Saves and restores original stty settings
    if (action == "save") system("stty -g") > ENVIRON["HOME"]"/tmp/sttyconfig"
    else if (action == "restore") {
        system("stty "ENVIRON["HOME"]"/tmp/sttyconfig")
        system("tput cnorm")
    }
}

function raw_and_hide() {
    # Set terminal to raw mode and hide cursor
    system("stty raw -echo")
    system("tput civis")
}

function cooked_and_show() {
    # Set terminal to cooked mode and show cursor
    system("stty cooked echo")
    system("tput cnorm")
}

function set_status(status_message) {
    system("tput cup " (height - 2) " 0")
    printf "\033[7m%s\033[0m\r\n", substr(status_message, 1, width)
    printf "> "
}

function validate_filename(file) {
    # SOON
}

function display_content() {
    # Clear screen
    system("clear")
        
    # Display content
    for (i = start_line; i < start_line + content_lines && i <= total_lines; i++) {
        printf "%-*s\r\n", width, substr(lines[i], start_col, width)
    }

    # Display status line
    set_status("Line " start_line "/" total_lines ". Column " start_col "/" max_col ". (Use h/j/k/l or ←/↓/↑/→ to scroll, b/f to scroll a page, q to quit)")
}

function get_input() {
    # Read a single character without Enter
    cmd = "dd bs=1 count=1 < /dev/tty 2>/dev/null"
    cmd | getline key
    close(cmd)

    if (key == "\033") {  # Down or potential arrow key
        cmd = "dd bs=1 count=2 < /dev/tty 2>/dev/null" # Grab 2 more bytes from the tty
        cmd | getline extra
        close(cmd)
        if (extra == "[B") key = "j"  # Down arrow
        else if (extra == "[A") key = "k"  # Up arrow
        else if (extra == "[C") key = "l" # Right arrow
        else if (extra == "[D") key = "h" # Left arrow
    }
    switch (key) {
        case "q":
            system("stty cooked echo")
            system("tput cnorm")
            system("clear")
            exit 0
        case "j":
            if (start_line + content_lines <= total_lines) start_line++
            break
        case "k":
            if (start_line > 1) start_line--
            break
        case "l":
            max_screen_col = 0
            for(i = start_line; i <= start_line + height - 2; i++) {
                if (length(lines[i]) > max_screen_col) max_screen_col = length(lines[i])
            }
            if (start_col < max_screen_col) start_col += 1 # Won't scroll right past the largest line on screen
            break
        case "h":
            if (start_col > 1) start_col -= 1  # Scroll left, but not below 1
            break
        case "f":  # Page down
            if (start_line + content_lines <= total_lines) {
                start_line += content_lines
                if (start_line + content_lines > total_lines) {
                    start_line = total_lines - content_lines + 1
                }
            }
            break
        case "b":  # Page up
            if (start_line > 1) {
                start_line -= content_lines
                if (start_line < 1) start_line = 1
            }
            break
    }
}


