set -g fish_greeting

if status is-interactive
    starship init fish | source
    #
    # #  Initialization of global variables
    set -q LS_AFTER_CD || set -gx LS_AFTER_CD true
    set -q LS_AFTER_CD_COMMAND || set -gx LS_AFTER_CD_COMMAND "ls -GF"

    # ls automatically when changing directories
    function on_directory_change --on-variable PWD
        if not string match -q "*;*" $LS_AFTER_CD_COMMAND
            eval $LS_AFTER_CD_COMMAND
        else
            echo "Error: LS_AFTER_CD_COMMAND contains invalid characters."
        end
    end
end

fish_add_path ~/.local/share/bin

alias ls lsd

abbr l 'ls -l'
abbr la 'ls -a'
abbr lla 'ls -la'
abbr lt 'ls --tree'

abbr cq 'cat 1.in | python3 solve.py'

alias whitespace "sed 's/ /·/g;s/\t/￫/g;s/\r/§/g;s/\$/¶/g'"

# Handy change dir shortcuts
abbr .. 'cd ..'
abbr ... 'cd ../..'
abbr .3 'cd ../../..'
abbr .4 'cd ../../../..'
abbr .5 'cd ../../../../..'

set -gx JAVA_HOME /usr/lib/jvm/$(archlinux-java get)

# Always mkdir a path (this doesn't inhibit functionality to make a single dir)
abbr mkdir 'mkdir -p'

function ccd -a dir
    if set -q dir; and test -n dir; and [ "$dir" != "" ]
        set directory "$dir"
    else
        set directory "."
    end

    cd $(fd --type d . "$directory" | fzf --preview 'lsd -1gAF --color=always {}')
end

fzf --fish | source
