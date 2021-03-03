# dotfiles

My personal dotfiles

## Install instructions

1. Install [chezmoi](https://github.com/twpayne/chezmoi/blob/master/docs/INSTALL.md)
2. Init repo: `chezmoi init https://github.com/jcronenberg/dotfiles.git`
3. Check changes it would make: `chezmoi diff`
4. Apply changes: `chezmoi apply`
5. To use the awesome configuration clone lain and awesome-freedesktop into .config/awesome
   ```
   cd .config/awesome
   git clone https://github.com/lcpz/awesome-freedesktop.git freedesktop
   git clone https://github.com/lcpz/lain.git
   ```

## Repos to use with these dotfiles

Some of these dotfiles depend on other repos to work properly  
[oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh)  
[oh-my-tmux](https://github.com/gpakosz/.tmux)  
[spacemacs](https://github.com/syl20bnr/spacemacs)
