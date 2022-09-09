# dotfiles

My personal dotfiles.  
These files are extremly opinionated and I would not recommend installing them.
Instead this repo is meant for my personal use and maybe some inspiration to others.
But who am I to tell you what to do, right?

## Installation instructions
NOTE: these instructions only work when you have my private key, which I hope you don't :)  
Again this isn't recommended, but if you want to apply my configs, you'll have to delete all
encrypted files.

1. Install [chezmoi](https://www.chezmoi.io/install/)
2. Init repo: `chezmoi init https://github.com/jcronenberg/dotfiles.git`
3. First only apply chezmoi config as this is needed to set up gpg `chezmoi apply .config/chezmoi/chezmoi.toml`
4. Check changes it would make: `chezmoi diff`
5. Apply changes: `chezmoi apply`

## Extra install steps

### To use oh-my-tmux

```ln -s ~/.tmux/.tmux.conf ~/.tmux.conf```

### To use fzf

(Recommended to install fzf beforehand to update it via package manager)  
```~/.fzf/install```
