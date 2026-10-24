#!/bin/sh
# Alacritty 的登录 shell 入口：与 ~/.dotfiles/wezterm/wezterm.lua 的 default_prog 一致
# 有 /usr/bin/fish 就用 fish -l（登录 shell，会读 config.fish），否则回退 bash -l，
# 这样 fish 被卸载/更新失败时终端仍然能打开。
if [ -x /usr/bin/fish ]; then
    exec /usr/bin/fish -l "$@"
fi
exec /usr/bin/bash -l "$@"
