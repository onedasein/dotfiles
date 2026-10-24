# fish 配置：交互式 shell 用 fish；脚本仍然交给 bash 执行
# （脚本首行写 #!/usr/bin/env bash，或用 `bash script.sh` 显式调用）
# 真实路径: ~/.config/fish/config.fish -> ~/.dotfiles/fish/config.fish
# 插件（fisher 管理）清单: ~/.dotfiles/fish/fish_plugins

status is-interactive; or return

set -g fish_greeting

# ── 环境变量（与 ~/.dotfiles/bash/bashrc 保持一致）──────────────────
set -gx DSH_HOME $HOME/dsh/home

# ── PATH ────────────────────────────────────────────────────────────
fish_add_path -m $HOME/.local/bin
fish_add_path -m $HOME/.npm-global/bin
fish_add_path -a /usr/local/go/bin
fish_add_path -a /usr/local/typst-x86_64-unknown-linux-musl

# ── 交互体验 ───────────────────────────────────────────────────────
# 语法高亮、Tab 补全、补全菜单都是 fish 内建的，不需要插件；
# 下面只调少数开关。
set -g fish_autosuggestion_enabled 1     # 灰色内联历史建议，→ 或 End 接受
set -g __done_min_cmd_duration 10000     # 命令跑满 10 秒才弹完成通知（done 插件）

# ── ls 颜色：沿用 dotfiles 里的 dircolors ────────────────────────────
if command -q dircolors; and test -r $HOME/.dircolors
    eval (dircolors -c $HOME/.dircolors | string replace -r '^setenv' 'set -gx' | string replace -r '; *$' '')
end

# ── zoxide：z 模糊跳目录、zi 交互选 ─────────────────────────────────
if command -q zoxide
    zoxide init fish --cmd z | source
end

# ── 提示符 ──────────────────────────────────────────────────────────
if command -q starship
    starship init fish | source
end

# ── 常用别名（与 bashrc 对齐）──────────────────────────────────────
alias ls 'ls --color=auto'
alias ll 'ls -alF'
alias la 'ls -A'
alias l 'ls -CF'
alias cl 'clear'
alias grep 'grep --color=auto'
alias fgrep 'fgrep --color=auto'
alias egrep 'egrep --color=auto'

# ── 缩写（abbr）：输入即展开，历史里留下完整命令 ──────────────────
abbr -a -- .. 'cd ..'
abbr -a -- ... 'cd ../..'
abbr -a -- .... 'cd ../../..'
abbr -a -- cls clear
abbr -a -- weather 'curl -s wttr.in/?format=3'

# ── 小工具 ─────────────────────────────────────────────────────────
function mkcd --description '建目录并进入'
    mkdir -p $argv[1]; and cd $argv[1]
end

# ── fzf 键位（fzf.fish 插件）───────────────────────────────────────
# 插件自带 Ctrl+R 历史 / Ctrl+Alt+F 目录文件 / Ctrl+Alt+L git log
# 这里把"选文件"改成更常见的 Ctrl+T（fish 原本是 transpose-chars，很少用）
if functions -q fzf_configure_bindings
    fzf_configure_bindings --directory=ctrl-t
end
