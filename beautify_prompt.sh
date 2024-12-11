#!/bin/bash

# 定义 ANSI 颜色代码，去掉 black 颜色
COLORS=(
    "\033[0;31m" # RED
    "\033[0;32m" # GREEN
    "\033[0;33m" # YELLOW
    "\033[0;34m" # BLUE
    "\033[0;35m" # MAGENTA
    "\033[0;36m" # CYAN
    "\033[0;37m" # WHITE
    "\033[1;31m" # BRIGHT_RED
    "\033[1;32m" # BRIGHT_GREEN
    "\033[1;33m" # BRIGHT_YELLOW
    "\033[1;34m" # BRIGHT_BLUE
    "\033[1;35m" # BRIGHT_MAGENTA
    "\033[1;36m" # BRIGHT_CYAN
    "\033[1;37m" # BRIGHT_WHITE
)
RESET="\033[0m"

# 自动判断使用的是 bash 还是 zsh
if [[ $SHELL == *"bash"* ]]; then
    CONFIG_FILE="$HOME/.bashrc"
elif [[ $SHELL == *"zsh"* ]]; then
    CONFIG_FILE="$HOME/.zshrc"
else
    echo "不支持的 shell 类型，请手动设置提示符。"
    exit 1
fi

# 显示 32 种选项
echo -e "请选择您喜欢的命令行提示符样式:"
for i in {1..32}; do
    FG_COLOR=${COLORS[$((i % 12))]} # 前景色，去掉 black
    BG_COLOR=${COLORS[$(((i + 6) % 12))]} # 背景色，去掉 black
    echo -e "$i. ${FG_COLOR}\u@${BG_COLOR}\h:${FG_COLOR}\w${RESET}#"
done
echo -e "33. 默认样式：\u@\h:\w#"

# 提示用户输入选择
read -p "请输入对应样式的数字： " choice

# 根据选择生成 PS1
if [[ $choice -ge 1 && $choice -le 32 ]]; then
    FG_COLOR=${COLORS[$((choice % 12))]}
    BG_COLOR=${COLORS[$(((choice + 6) % 12))]}
    PS1="${FG_COLOR}\u@${BG_COLOR}\h:${FG_COLOR}\w${RESET}#"
elif [[ $choice -eq 33 ]]; then
    PS1="\u@\h:\w#"
else
    echo "无效选择，将使用默认样式。"
    PS1="\u@\h:\w#"
fi

# 将新的 PS1 写入配置文件
echo -e "\n# 自定义命令行提示符（支持 32 种颜色，去掉 black）" >> "$CONFIG_FILE"
echo "export PS1=\"${PS1}\"" >> "$CONFIG_FILE"

# 加载配置文件
source "$CONFIG_FILE"

# 提示用户
echo -e "提示符已永久更新！重新打开终端或运行 'source $CONFIG_FILE' 以确保设置生效。"