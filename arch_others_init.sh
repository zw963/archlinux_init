
# git
pacman -S git
# 支持 NTFS
pacman -S ntfs-3g
pacman -S rsync
pacman -S skype
# (类似于 mac 下的 albert)
pacman -S albert
pacman -S tree
pacman -S mlocate && updatedb
pacman -S emacs
pacman -S jdk8-openjdk

pacman -S cron
systemctl enable cronie

# net tools
pacman -S traceroute bind-tools

# 更新 pacman 以及社区源的本地数据库
pacman -Fyy

# mysql, 或者 mysql-clients (archlinuxcn)
pacman -S mariadb-clients

pacman -S nfs-utils
systemctl enable nfs-server
systemctl enable rpcbind

# 稍后, 可以通过 pacman -Fs 查找一个文件属于那个包. -Fl list package files

# pacman -S virtualbox virtualbox-host-modules virtualbox-guest-iso

# yaourt --m-arg "--skippgpcheck" -Sy --noconfirm command-not-found
