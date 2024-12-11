#!/bin/bash

# 定义 ANSI 颜色代码
BLACK="\033[0;30m"
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
MAGENTA="\033[0;35m"
CYAN="\033[0;36m"
WHITE="\033[0;37m"
BRIGHT_BLACK="\033[1;30m"
BRIGHT_RED="\033[1;31m"
BRIGHT_GREEN="\033[1;32m"
BRIGHT_YELLOW="\033[1;33m"
BRIGHT_BLUE="\033[1;34m"
BRIGHT_MAGENTA="\033[1;35m"
BRIGHT_CYAN="\033[1;36m"
BRIGHT_WHITE="\033[1;37m"
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

# 显示选项
echo -e "请选择您喜欢的命令行提示符样式:"
echo -e "1. ${RED}\u@${GREEN}\h:${BLUE}\w${RESET}#"
echo -e "2. ${YELLOW}\u@${MAGENTA}\h:${CYAN}\w${RESET}#"
echo -e "3. ${BRIGHT_RED}\u@${BRIGHT_GREEN}\h:${BRIGHT_BLUE}\w${RESET}#"
echo -e "4. ${BRIGHT_YELLOW}\u@${BRIGHT_MAGENTA}\h:${BRIGHT_CYAN}\w${RESET}#"
echo -e "5. ${BLACK}\u@${BRIGHT_RED}\h:${BRIGHT_WHITE}\w${RESET}#"
echo -e "6. ${BRIGHT_BLACK}\u@${WHITE}\h:${GREEN}\w${RESET}#"
echo -e "7. ${BLUE}\u@${BRIGHT_YELLOW}\h:${RED}\w${RESET}#"
echo -e "8. ${BRIGHT_BLUE}\u@${MAGENTA}\h:${CYAN}\w${RESET}#"
echo -e "9. ${CYAN}\u@${YELLOW}\h:${MAGENTA}\w${RESET}#"
echo -e "10. ${MAGENTA}\u@${BRIGHT_CYAN}\h:${BRIGHT_YELLOW}\w${RESET}#"
echo -e "11. ${WHITE}\u@${BRIGHT_BLACK}\h:${BRIGHT_RED}\w${RESET}#"
echo -e "12. ${BRIGHT_WHITE}\u@${BRIGHT_BLUE}\h:${BRIGHT_GREEN}\w${RESET}#"
echo -e "13. ${GREEN}\u@${CYAN}\h:${BRIGHT_MAGENTA}\w${RESET}#"
echo -e "14. ${BRIGHT_YELLOW}\u@${BRIGHT_RED}\h:${BRIGHT_BLACK}\w${RESET}#"
echo -e "15. ${BRIGHT_GREEN}\u@${BLUE}\h:${BLACK}\w${RESET}#"
echo -e "16. ${BRIGHT_MAGENTA}\u@${RED}\h:${BRIGHT_CYAN}\w${RESET}#"
echo -e "17. 默认样式：\u@\h:\w#"

# 提示用户输入选择
read -p "请输入对应样式的数字： " choice

# 根据选择生成 PS1
case $choice in
    1)
        PS1="${RED}\u@${GREEN}\h:${BLUE}\w${RESET}#"
        ;;
    2)
        PS1="${YELLOW}\u@${MAGENTA}\h:${CYAN}\w${RESET}#"
        ;;
    3)
        PS1="${BRIGHT_RED}\u@${BRIGHT_GREEN}\h:${BRIGHT_BLUE}\w${RESET}#"
        ;;
    4)
        PS1="${BRIGHT_YELLOW}\u@${BRIGHT_MAGENTA}\h:${BRIGHT_CYAN}\w${RESET}#"
        ;;
    5)
        PS1="${BLACK}\u@${BRIGHT_RED}\h:${BRIGHT_WHITE}\w${RESET}#"
        ;;
    6)
        PS1="${BRIGHT_BLACK}\u@${WHITE}\h:${GREEN}\w${RESET}#"
        ;;
    7)
        PS1="${BLUE}\u@${BRIGHT_YELLOW}\h:${RED}\w${RESET}#"
        ;;
    8)
        PS1="${BRIGHT_BLUE}\u@${MAGENTA}\h:${CYAN}\w${RESET}#"
        ;;
    9)
        PS1="${CYAN}\u@${YELLOW}\h:${MAGENTA}\w${RESET}#"
        ;;
    10)
        PS1="${MAGENTA}\u@${BRIGHT_CYAN}\h:${BRIGHT_YELLOW}\w${RESET}#"
        ;;
    11)
        PS1="${WHITE}\u@${BRIGHT_BLACK}\h:${BRIGHT_RED}\w${RESET}#"
        ;;
    12)
        PS1="${BRIGHT_WHITE}\u@${BRIGHT_BLUE}\h:${BRIGHT_GREEN}\w${RESET}#"
        ;;
    13)
        PS1="${GREEN}\u@${CYAN}\h:${BRIGHT_MAGENTA}\w${RESET}#"
        ;;
    14)
        PS1="${BRIGHT_YELLOW}\u@${BRIGHT_RED}\h:${BRIGHT_BLACK}\w${RESET}#"
        ;;
    15)
        PS1="${BRIGHT_GREEN}\u@${BLUE}\h:${BLACK}\w${RESET}#"
        ;;
    16)
        PS1="${BRIGHT_MAGENTA}\u@${RED}\h:${BRIGHT_CYAN}\w${RESET}#"
        ;;
    17)
        PS1="\u@\h:\w#"
        ;;
    *)
        echo "无效选择，将使用默认样式。"
        PS1="\u@\h:\w#"
        ;;
esac

# 将新的 PS1 写入配置文件
echo -e "\n# 自定义命令行提示符（支持 16 种颜色）" >> "$CONFIG_FILE"
echo "export PS1=\"${PS1}\"" >> "$CONFIG_FILE"

# 加载配置文件
source "$CONFIG_FILE"

# 提示用户
echo -e "提示符已永久更新！重新打开终端或运行 'source $CONFIG_FILE' 以确保设置生效。"