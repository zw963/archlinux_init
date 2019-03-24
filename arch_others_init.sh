
pacman -S skype


# 更新 pacman 以及社区源的本地数据库
pacman -Fyy

# mysql, 或者 mysql-clients (archlinuxcn)
pacman -S mariadb-clients

# 稍后, 可以通过 pacman -Fs 查找一个文件属于那个包. -Fl list package files

# pacman -S virtualbox virtualbox-host-modules virtualbox-guest-iso

# yaourt --m-arg "--skippgpcheck" -Sy --noconfirm command-not-found
