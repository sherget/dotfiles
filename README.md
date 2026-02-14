# Ma'Dotfiles

Trying to keep it minimal and clean, this repository will get pulled in dynamically in my ansible setup and then install all necessary dotfiles so I am ready to work.

### Optional
- In case of running Arch and using lightdm: Don't forget to symlink the display-setup script:
```bash 
sudo ln -s /home/$(whoami)/dotfiles/lightdm/display-setup /etc/lightdm/display-setup
```

### Phpactor
Go to your <working directory> then run phpactor config:init
