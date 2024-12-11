#!/bin/bash

# 定义 ANSI 颜色代码
GREEN="\033[1;32m"
BLUE="\033[1;34m"
RED="\033[1;31m"
MAGENTA="\033[1;35m"
CYAN="\033[1;36m"
YELLOW="\033[1;33m"
WHITE="\033[1;37m"
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
echo -e "1. ${GREEN}\u@${BLUE}\h:${RED}\w${RESET}#"
echo -e "2. ${MAGENTA}\u@${CYAN}\h:${YELLOW}\w${RESET}#"
echo -e "3. ${RED}\u@${GREEN}\h:${BLUE}\w${RESET}#"
echo -e "4. ${CYAN}\u@${YELLOW}\h:${WHITE}\w${RESET}#"
echo -e "5. ${WHITE}\u@${RED}\h:${GREEN}\w${RESET}#"
echo -e "6. ${YELLOW}\u@${BLUE}\h:${MAGENTA}\w${RESET}#"
echo -e "7. 默认样式：\u@\h:\w#"

# 提示用户输入选择
read -p "请输入对应样式的数字： " choice

# 根据选择生成 PS1
case $choice in
    1)
        PS1="${GREEN}\u@${BLUE}\h:${RED}\w${RESET}#"
        ;;
    2)
        PS1="${MAGENTA}\u@${CYAN}\h:${YELLOW}\w${RESET}#"
        ;;
    3)
        PS1="${RED}\u@${GREEN}\h:${BLUE}\w${RESET}#"
        ;;
    4)
        PS1="${CYAN}\u@${YELLOW}\h:${WHITE}\w${RESET}#"
        ;;
    5)
        PS1="${WHITE}\u@${RED}\h:${GREEN}\w${RESET}#"
        ;;
    6)
        PS1="${YELLOW}\u@${BLUE}\h:${MAGENTA}\w${RESET}#"
        ;;
    7)
        PS1="\u@\h:\w#"
        ;;
    *)
        echo "无效选择，将使用默认样式。"
        PS1="\u@\h:\w#"
        ;;
esac

# 将新的 PS1 写入配置文件
echo -e "\n# 自定义命令行提示符（去掉 ~ 和 # 之间的空格）" >> "$CONFIG_FILE"
echo "export PS1=\"${PS1}\"" >> "$CONFIG_FILE"

# 加载配置文件
source "$CONFIG_FILE"

# 提示用户
echo -e "提示符已永久更新！重新打开终端或运行 'source $CONFIG_FILE' 以确保设置生效。"