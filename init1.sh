#!/bin/bash

set -xe

# 运行的前提条件:
# 1. 网络已经配置好. (不配置好, 没办法使用 curl 从 github 下载这个文件.)
# 2. 已经分区(cfidsk)并格式化(mkfs.ext4 /dev/sda1), 并且成功的 mount 这个分区到 /mnt (mount /dev/sda1 /mnt)

# 确保设定键盘为 US 布局.
loadkeys us

# 确保系统时间是准确的, 一定确保同步, 否则会造成签名错误.
timedatectl set-ntp true && ntpdate pool.ntp.org

# 设定上海交大源为首选源, 速度更快
sed -i '1iServer = http://ftp.sjtu.edu.cn/archlinux/$repo/os/$arch' /etc/pacman.d/mirrorlist

# 使用 pacstrap 拷贝文件到 mount 的分区, 不加任何参数, 默认只安装 base.
# 安装 base, 但是替换 linux 为 linux-lts
# pacman -Sy
# pacman -Sg base | cut -d ' ' -f 2 | sed 's#^linux$#linux-lts#g' | pacstrap /mnt -

pacstrap /mnt base base-devel linux-headers cmake \
         iw wpa_supplicant dialog wireless_tools net-tools \
         networkmanager network-manager-applet

# 添加交大的 AUR 源
cat <<'HEREDOC' >> /mnt/etc/pacman.conf
[archlinuxcn]
SigLevel = Optional TrustAll
Server = https://mirrors.sjtug.sjtu.edu.cn/archlinux-cn/$arch
HEREDOC

# 升级时, 忽略内核
sed -i 's/#IgnorePkg.*=/IgnorePkg = linux linux-headers linux-lts linux-lts-headers/' /mnt/etc/pacman.conf
sed -i 's#\#\[multilib\]#[multilib]\nInclude = /etc/pacman.d/mirrorlist#' /mnt/etc/pacman.conf

# 生成 root 分区的 fstab 信息
genfstab -U /mnt >> /mnt/etc/fstab

# 切换到目标 root
arch-chroot /mnt /bin/bash

useradd -m zw963
echo 'zw963 ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

# 设定上海为当前时区, 并保存时间到主机, hwclock 会生成: /etc/adjtime
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && hwclock --systohc --utc

function add_config () {
    pattern="$1"
    cat "$2" |grep "^${pattern}" || echo "$pattern" >> "$2"
}

# 开启需要的 locale
add_config 'en_US.UTF-8 UTF-8' /etc/locale.gen
add_config 'zh_CN.UTF-8 UTF-8' /etc/locale.gen
add_config 'zh_TW.UTF-8 UTF-8' /etc/locale.gen
# 生成 locale 信息.
locale-gen

# 设定 LANG 环境变量 (FIXME: 这个不执行， 看看效果)
echo 'LANG=en_US.UTF-8' > /etc/locale.conf

# 设定 hostname
echo 'arch_linux' > /etc/hostname

# 编辑 /etc/hosts
echo '127.0.0.1 localhost' >> /etc/hosts
echo '::1 localhost' >> /etc/hosts
echo '127.0.0.1 arch_linux' >> /etc/hosts

function ins () {
    pacman -S --noconfirm "$@"
}

function yao () {
    sudo -u zw963 yaourt --m-arg "--skippgpcheck" -S --noconfirm "$@"
}

pacman -Sy

# 安装和配置 grub, 注意, 在更改了内核版本后, 也需要运行 grub-mkconfig
# 注意：grub2-mkconfig -o /boot/grub/grub.cfg 则是升级内核后，使用 grub 启动通用的办法。
# 注意目录名，例如：centos 是 /boot/grub2/grub.cfg

# 注意: 新版安装程序貌似不需要这个步骤了.
# ins grub
# grub-install /dev/sda
# grub-mkconfig -o /boot/grub/grub.cfg

# 网络相关工具
ins ntp
ins openssh
ins wget
ins traceroute
ins bind-tools
ins rsync

ins bash-completion

ins cron
systemctl enable cronie

ins nfs-utils
systemctl enable nfs-server
systemctl enable rpcbind

# # 最新的 Gnome3 不含 xorg 的, 使用的是 Wayland.
# ins xorg
# ins xorg-xinit
# ins xterm
# ins xf86-input-keyboard
# ins xf86-input-mouse
# ins xf86-input-synaptics
# # intel 集成显卡驱动
# ins xf86-video-intel libxss

# 声卡驱动
ins alsa-utils pavucontrol
# 将当前用户加入 audio 分组.
gpasswd -a zw963 audio

# 安装中文字体及英文字体
ins wqy-microhei wqy-zenhei ttf-dejavu

ins gnome gnome-extra
ins xorg-xprop
ins budgie-desktop
ins cinnamon

# 使用 GDM 作为登陆器.
systemctl enable gdm
systemctl enable bluetooth

# network manager.
systemctl enable NetworkManager

ins konsole
ins okular

ins firefox
ins flashplugin

ins emacs
ins git
ins tree
ins mlocate
ins ntfs-3g

# 类似于 mac 下的 alfred
ins albert

ins gparted

ins fcitx-im fcitx-sunpinyin fcitx-configtool

# wine 以及浏览器支持, .NET 支持
ins wine wine_gecko wine-mono

# 安装 yaourt 包管理软件及图形界面.
ins yaourt pamac-aur

sudo -u zw963 yaourt -Sy

# 安装多媒体相关的解码库及 H.264 解码支持
yao vlc gst-libav

# 安装 patched 版本的 wicd, 这个版本修复了 wicd-curses 总是崩溃的问题。
# 这个必须以新用户身份运行, 暂时注释
yao wicd-patched

yao vmware-workstation
# VMWARE 网络访问
systemctl enable vmware-networks.service
# VMWARE USB 共享
systemctl enable vmware-usbarbitrator.service
# VMWARE 目录共享
systemctl enable vmware-hostd.service

# 创建一些必须的空目录, (安装 vmware 客户端工具必须)
for x in {0..6}; do mkdir -p /etc/init.d/rc${x}.d; done

echo 'Run before boot:'

echo 'arch-chroot /mnt /bin/bash'
echo 'passwd'
echo 'passwd zw963'

echo 'Run after boot:'

echo 'alsamixer'
echo 'aplay /usr/share/sounds/alsa/Front_Center.wav'
echo '/usr/sbin/alsactl store'
