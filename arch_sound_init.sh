
# 安装 高级Linux声音架构（Advanced Linux Sound Architecture，简称ALSA）
# 它替换了原有的开放声音系统(OSS)
# 如果不工作, 安装 alsa-oss
pacman -S alsa-utils pavucontrol alsa-oss
# 运行 alsamixer,  M 取消静音, 调整音量为合适大小.
alsamixer
# 测试声音, 会创建 /etc/asound.state 保存设置.
aplay /usr/share/sounds/alsa/Front_Center.wav
#  保存声音设置
/usr/sbin/alsactl store
