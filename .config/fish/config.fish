if status is-interactive
    # Commands to run in interactive sessions can go here
end

fish_add_path ~/.cargo/bin
fish_add_path ~/.local/bin 

# pnpm
set -gx PNPM_HOME "/home/jj/.local/share/pnpm"
if not string match -q -- $PNPM_HOME $PATH
  set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end

function cls
    clear
    printf "\e[H\e[3J"
end

thefuck --alias | source
