# Completion
setopt auto_menu # show completion menu on succesive tab press
unsetopt menu_complete # do not autoselect the first completion entry
setopt complete_in_word # enable completion from within a word/phrase
setopt always_to_end # completing from the middle of a word moves the cursor to its end
unsetopt flowcontrol # disable start/stop characters in the shell's editor

# Correction
unsetopt correct_all

# Directories
setopt auto_cd # change directory without `cd` but just with the dir name
setopt auto_pushd # `cd` pushes the old directory onto the directory stack
setopt pushd_ignore_dups # don't push duplicates of the same directory onto the directory stack
setopt pushdminus # switch +/- when specifying a number in the directory stack

# History
setopt extended_history # save timestamp of command and duration
setopt hist_expire_dups_first # when trimming, discard oldest duplicates first
setopt hist_ignore_dups # discard duplicate commands
setopt hist_ignore_space # discard commands starting with a space
setopt hist_reduce_blanks # remove blanks for commands
setopt hist_verify # don't execute just expand history
setopt inc_append_history # instantly write to to history file
setopt share_history # share command history data across multiple sessions
setopt interactive_comments # save comments to history
#setopt hist_find_no_dups # don't show duplicate results in history search

# Prompt
setopt prompt_subst # param expansion in prompt

# Misc
setopt extended_glob # extended globbing
setopt multios # perform implicit tees or cats when multiple redirections are attempted
setopt long_list_jobs # list jobs in the long format by default