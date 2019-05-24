
pacman -S node npm yarn
# mysql, 或者 mysql-clients (archlinuxcn)
pacman -S mariadb-clients
# pg not split to server and client.
pacman -S postgresql

# 稍后, 可以通过 pacman -Fs 查找一个文件属于那个包. -Fl list package files

# yaourt --m-arg "--skippgpcheck" -Sy --noconfirm command-not-found
