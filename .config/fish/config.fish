set -g fish_greeting

if status is-interactive
	# starship init fish | source
end

alias ls 'lsd'

abbr l 'ls -l'
abbr la 'ls -a'
abbr lla 'ls -la'
abbr lt 'ls --tree'

# Handy change dir shortcuts
abbr .. 'cd ..'
abbr ... 'cd ../..'
abbr .3 'cd ../../..'
abbr .4 'cd ../../../..'
abbr .5 'cd ../../../../..'

# Always mkdir a path (this doesn't inhibit functionality to make a single dir)
abbr mkdir 'mkdir -p'
