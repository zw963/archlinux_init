
# 如果是 vmware, 下面的包安装显卡驱动

# 安装显卡驱动, 不同的平台使用不同的包

# ATI 显卡
# pacman -S xf86-video-ati

# Nvidia
# pacman -S xf86-video-nouveau

# vmware
# pacman -S xf86-video-vmware

pacman -S obs-studio xdg-desktop-portal xdg-desktop-portal-gnome
# 使用 obs 在 Wayland 下实现简单的录屏：
# 1. 安装必需的包
# 2. 复制 /usr/share/applications/com.obsproject.Studio.desktop 到 ~/.local/share/applications/
#    然后将 Exec=obs 替换为 env QT_QPA_PLATFORM=wayland obs
# 3. 运行 obs, 然后选择要录屏的屏幕，此时应该可以看到屏幕预览了。
# 4. 在来源面板里面选择 PipeWire, 如果看不到，检查以上步骤。
# 5. 如果提示 NVENC 错误，选择 文件 -> 设置 -> 输出 -> 编码器 -> 软件(x264)
#    如果你有 vaapi，也可以去高级选项里用上
# 6. 如果不需要声音，在混音器面板关闭它
# 7. 点击 “开始录制” 开始录屏，“停止录制” 停止录屏

# 注意，如果使用 GNOME, 事实上查询快捷键的 screenshots 分组里，
# 可以看到，已经内置这个功能了，Ctrl+Alt+Shift+r
