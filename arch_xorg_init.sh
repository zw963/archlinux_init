# 第一步,首先启动 wifi

# 安装显卡驱动, 不同的平台使用不同的包

# 默认蓝牙服务是没有开启的, 启动蓝牙服务.
systemctl enable bluetooth
systemctl start bluetooth

# 使用 GDM 作为登陆器.
systemctl enable gdm.service
# 使用 cinnamon 作为桌面.
pacman -S cinnamon nemo-fileroller
# 安装中文字体, 和英文字体.
pacman -S wqy-microhei wqy-zenhei ttf-dejavu
# 一个基本的图形编辑器
pcman -S leafpad
# Konsole
pacman -S konsole

# browser
pacman -S firefox flashplugin

# 开启 vmware 目录共享

# 安装开源版本的 vm tools
pacman -S open-vm-tools
systemctl start vmtoolsd
systemctl enable vmtoolsd

# 1. 运行 vmware-hgfsclient 可以看到共享目录
# mount 目录:
vmhgfs-fuse -o allow_other -o auto_unmount .host:/share /mnt
# 或
echo '.host:/share /mnt fuse.vmhgfs-fuse defaults 0 0' >> /etc/fstab

# 安装 yaoout 的图形界面.
yaourt -S pamac-aur

yaourt -S deepin-screenshot

# 思维导图软件.
yaourt -S xmind-zen

# 安装多媒体相关的解码库: (安装 vlc 即可.)
yaourt -S vlc

# 这个是和声卡有关的, 还不知道干嘛用.
# It also offers easy network streaming across local devices using Avahi if enabled.
systemctl enable avahi-daemon
systemctl start avahi-daemon

pacman -S gparted

pacman -S fcitx-im fcitx-sunpinyin fcitx-configtool

# wine 以及浏览器支持, .NET 支持
pacman -S wine wine_gecko wine-mono

# dota 只能用 primus 包里面的 primusrun 来启动才正常.
pacman -S steam primus

pacman -S okular

# gif, 裁图必须.
pacman -S imagemagick

# office
yaourt -S wps-office ttf-wps-fonts

pacman -S linux-headers

yaourt --m-arg "--skippgpcheck" -Sy --noconfirm vmware-workstation
# VMWARE 网络访问
systemctl enable vmware-networks.service
systemctl start vmware-networks.service
# VMWARE USB 共享
systemctl enable vmware-usbarbitrator.service
systemctl start vmware-usbarbitrator.service
# VMWARE 目录共享
systemctl enable vmware-hostd.service
systemctl start vmware-hostd.service

yaourt --m-arg "--skippgpcheck" -Sy --noconfirm deepin.com.qq.office
yaourt --m-arg "--skippgpcheck" -Sy --noconfirm deepin-wechat
yaourt --m-arg "--skippgpcheck" -Sy --noconfirm deepin.com.thunderspeed

# pacman -S geany
# #pacman -S lilyterm
# pacman -S dnsutils nmap
# pacman -S smplayer
# pacman -S archlinuxfr/downgrade
# pacman -S kchmviewer gpicview
# pacman -S redshift enca
# pacman -S qgit meld
# pacman -S archlinuxcn/ccal
