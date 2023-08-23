# Install YAY

```
cd /tmp && git clone https://aur.archlinux.org/yay.git
cd yay && makepkg -si --noconfirm
cd ..
rm -rf yay
```

# Configuring pacman

### Enable multilib (32bit) repos

`sudo sed -i "s #\[multilib\] \[multilib\] ; /\[multilib\]/{n;s #Include Include }" /etc/pacman.conf`

### Make pacman prettier and adding color

`sudo sed -i "/#Color/a ILoveCandy" /etc/pacman.conf`
`sudo sed -i "s/#Color/Color/g" /etc/pacman.conf`

### Enable parallel downloads

`sudo sed -i "s/#ParallelDownloads = 5/ParallelDownloads = 10/g" /etc/pacman.conf`

### Enable verbose package lists

`sudo sed -i "s/#VerbosePkgLists/VerbosePkgLists/g" /etc/pacman.conf`

## Update makepkg to utilize more cores

`sudo sed -i 's/#MAKEFLAGS="-j2"/MAKEFLAGS="-j8"/g' /etc/makepkg.conf`

`sudo sed -i 's/COMPRESSXZ=(xz -c -z -)/COMPRESSXZ=(xz -c -T 8 -z -)/g' /etc/makepkg.conf`

## Create update-pkglist hook

`sudo touch /usr/share/libalpm/hooks/pkglist.hook`

```
sudo tee /usr/share/libalpm/hooks/pkglist.hook > /dev/null << EOF
[Trigger]
Operation = Install
Operation = Remove
Type = Package
Target = *

[Action]
When = PostTransaction
Exec = /bin/sh -c '/usr/bin/pacman -Qqe > /home/kaizen/dotfiles/pkglist.txt'
EOF
```

## Install pacman cache cleaner

`sudo pacman -Syu --noconfirm pacman-contrib`

`sudo mkdir /etc/pacman.d/hooks`

`sudo touch /etc/pacman.d/hooks/clean_cache.hook`

```
sudo tee /etc/pacman.d/hooks/clean_cache.hook > /dev/null << EOF
[Trigger]
Operation = Upgrade
Operation = Install
Operation = Remove
Type = Package
Target = *
[Action]
Description = Cleaning pacman cache...
When = PostTransaction
Exec = /usr/bin/paccache -r
EOF
```

## Enable fstrim.timer

`sudo systemctl enable fstrim.timer --now`

# AMD stuffs

```
# /etc/X11/xorg.conf.d/20-amdgpu.conf

Section "OutputClass"
     Identifier "AMD"
     MatchDriver "amdgpu"
     Driver "amdgpu"
     Option "EnablePageFlip" "off"
     Option "TearFree" "false"
EndSection

Section "Device"
     Identifier "AMD"
     Driver "amdgpu"
     Option "VariableRefresh" "true"
EndSection
```
