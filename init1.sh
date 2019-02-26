set -x

# 运行的前提条件:
# 1. 网络已经配置好. (不配置好, 没办法使用 curl 从 github 下载这个文件.)
# 2. 已经分区(cfidsk)并格式化(mkfs.ext4 /dev/sda1), 并且成功的 mount 这个分区到 /mnt (mount /dev/sda1 /mnt)

# 确保系统时间是准确的, 一定确保同步, 否则会造成签名错误.
timedatectl set-ntp true && ntpdate pool.ntp.org

# 设定上海交大源为首选源, 速度更快
sed -i '1iServer = http://ftp.sjtu.edu.cn/archlinux/$repo/os/$arch' /etc/pacman.d/mirrorlist

# 拷贝文件到 mount 的分区, 如果不加任何参数, 默认只安装 base
pacstrap /mnt base base-devel cmake
# pacstrap /mnt linux-lts linux-lts-headers

# 无线网络相关联的包
pacstrap /mnt iw wpa_supplicant dialog wireless_tools
# network manager.
pacstrap /mnt networkmanager network-manager-applet

# 网络相关工具
pacstrap /mnt net-tools ntp openssh

# 添加交大的 AUR 源
cat <<'HEREDOC' >> /mnt/etc/pacman.conf
[archlinuxcn]
SigLevel = Optional TrustAll
Server = https://mirrors.sjtug.sjtu.edu.cn/archlinux-cn/$arch
HEREDOC

# 生成 root 分区的 fstab 信息
genfstab -U /mnt >> /mnt/etc/fstab

# 切换到目标 root
arch-chroot /mnt /bin/bash

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
echo 'LANG=en_US.UTF-8' > /etc/locale.conf

# 设定 hostname
echo 'arch_linux' > /etc/hostname

# 编辑 /etc/hosts
echo '127.0.0.1 localhost' >> /etc/hosts
echo '::1 localhost' >> /etc/hosts
echo '127.0.0.1 arch_linux' >> /etc/hosts

useradd -m zw963
echo 'zw963 ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

# 安装和配置 grub, 注意, 在更改了内核版本后, 也需要运行 grub-mkconfig
# 注意：grub2-mkconfig -o /boot/grub/grub.cfg 则是升级内核后，使用 grub 启动通用的办法。
# 注意目录名，例如：centos 是 /boot/grub2/grub.cfg
pacman -Sy grub && grub-install /dev/sda && grub-mkconfig -o /boot/grub/grub.cfg
pacman -Sy yaourt bash-completion

# 安装 patched 版本的 wicd, 这个版本修复了 wicd-curses 总是崩溃的问题。
yaourt -S wicd-patched

# 创建一些必须的空目录, (安装 vmware 客户端工具必须)
for x in {0..6}; do mkdir -p /etc/init.d/rc${x}.d; done

echo 'Remember to set password to root and zw963'
echo 'passwd'
echo 'passwd zw963'
