#!/bin/bash

useradd -m zw963
echo 'zw963 ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && hwclock --systohc

function add_config () {
    pattern="$1"
    cat "$2" |grep "^${pattern}" || echo "$pattern" >> "$2"
}

# 开启需要的 locale
add_config 'en_US.UTF-8 UTF-8' /etc/locale.gen
add_config 'zh_CN.UTF-8 UTF-8' /etc/locale.gen
add_config 'zh_TW.UTF-8 UTF-8' /etc/locale.gen

locale-gen

echo 'LANG=en_US.UTF-8' > /etc/locale.conf

echo 'zbook' > /etc/hostname

echo '127.0.0.1 localhost' >> /etc/hosts
echo '127.0.0.1 zbook' >> /etc/hosts

function pacman () {
    command pacman --noconfirm "$@"
}

function yay () {
    command yay --noconfirm "$@";
}

sed -i '1iServer = https://mirrors.bfsu.edu.cn/archlinux/$repo/os/$arch' /etc/pacman.d/mirrorlist
cat <<'HEREDOC' >> /etc/pacman.conf
[archlinuxcn]
# SigLevel = Optional TrustAll
Server = https://mirrors.bfsu.edu.cn/archlinuxcn/$arch
HEREDOC

pacman -Sy
pacman -Fy

pacman -S archlinuxcn-keyring

pacman -S rsync wget net-tools man netcat cronie mlocate iwd dhcpcd ntp ntfs-3g bind exfat-utils
systemctl enable ntpdate
systemctl enable cronie
systemctl enable iwd
systemctl enable dhcpcd

pacman -S alsa-utils
# 将当前用户加入 audio 分组.
sudo gpasswd -a zw963 audio

pacman -S gnome gnome-tweaks dconf-editor networkmanager network-manager-applet konsole firefox google-chrome gparted copyq flameshot
systemctl enable NetworkManager
systemctl enable gdm # use GDM as display manager
# systemctl enable bluetooth

# pacman -S fcitx-im fcitx-sunpinyin fcitx-configtool
# pacman -S fcitx5-chinese-addons fcitx5-pinyin-zhwiki

pacman -S emacs ttf-dejavu xorg-mkfontscale jansson
