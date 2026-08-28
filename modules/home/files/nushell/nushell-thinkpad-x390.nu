$env.config.show_banner = false
$env.config.table.mode = "rounded"
$env.config.history.file_format = "sqlite"
$env.PATH = ($env.PATH | prepend $"($env.HOME)/.npm-global/bin")

alias em = emacsclient -c -n
alias em-kill = emacsclient -e '(kill-emacs)'

alias g    = git
alias gs   = git status
alias gss  = git status --short
alias ga   = git add
alias gaa  = git add --all
alias gc   = git commit
alias gcm  = git commit -m
alias gco  = git checkout
alias gsw  = git switch
alias gb   = git branch
alias gba  = git branch --all
alias gl   = git log --oneline --graph --decorate
alias gd   = git diff
alias gds  = git diff --staged
alias gp   = git push
alias gpl  = git pull
alias gf   = git fetch --all
alias gst  = git stash
alias gstp = git stash pop
alias tn = tmux new -A -s

def gcq [msg: string] {
    git add --all
    git commit -m $msg
}

$env.STARSHIP_CONFIG = ($env.HOME | path join ".config" "starship.toml")
if (which starship | length) > 0 {
  $env.PROMPT_COMMAND = {|| starship prompt }
}
