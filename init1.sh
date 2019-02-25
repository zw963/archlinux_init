set -x

# 确保系统时间是准确的, 一定确保同步, 否则会造成签名错误.
timedatectl set-ntp true && ntpdate pool.ntp.org

# 设定上海交大源为首选源, 速度更快
sed -i '1iServer = http://ftp.sjtu.edu.cn/archlinux/$repo/os/$arch' /etc/pacman.d/mirrorlist

# 添加交大的 AUR 源
cat <<'HEREDOC' >> /mnt/etc/pacman.conf
[archlinuxcn]
SigLevel = Optional TrustAll
Server = https://mirrors.sjtug.sjtu.edu.cn/archlinux-cn/$arch
HEREDOC

# 生成当前分区的 fstab 信息
genfstab -U /mnt >> /mnt/etc/fstab
