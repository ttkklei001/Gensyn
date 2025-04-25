#!/bin/bash

clear

# 显示主菜单
while true; do
    echo ""
    echo "============== 一键部署脚本 =============="
    echo "脚本作者：K2 节点教程分享"
    echo "推特地址：https://x.com/BtcK241918"
    echo "订阅电报频道：https://t.me/+EaCiFDOghoM3Yzll"
    echo "==========================================="
    echo "1. 安装基础环境并启动项目"
    echo "2. 查看 gensyn 会话"
    echo "3. 重启 gensyn 会话"
    echo "4. 安装并配置 ngrok"
    echo "5. 启动 ngrok 隧道 (3000端口)"
    echo "6. 退出"
    echo "==========================================="

    read -p "请输入选项（1-6）: " choice
    while [[ ! "$choice" =~ ^[1-6]$ ]]; do
        echo "❌ 请输入有效的选项（1-6）"
        read -p "请输入选项（1-6）: " choice
    done

    case "$choice" in
        1)
            echo ">>> 开始安装基础环境和项目..."

            for pkg in python3 python3-venv python3-pip curl screen git; do
                dpkg -s $pkg &>/dev/null || sudo apt install -y $pkg
            done

            if ! command -v yarn &>/dev/null; then
                curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
                echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
                sudo apt update && sudo apt install -y yarn
            fi

            if ! command -v node &>/dev/null || ! command -v npm &>/dev/null; then
                curl -sSL https://raw.githubusercontent.com/zunxbt/installation/main/node.sh | bash
            fi

            if [ ! -d "rl-swarm" ]; then
                git clone https://github.com/zunxbt/rl-swarm.git && cd rl-swarm
            else
                cd rl-swarm && git pull
            fi

            pip install "protobuf==4.25.3"

            if screen -list | grep -q "gensyn"; then
                screen -S gensyn -X quit
                echo "🛑 已终止旧的 gensyn 会话"
            fi

            screen -S gensyn -dm bash -c "python3 -m venv .venv && source .venv/bin/activate && ./run_rl_swarm.sh; exec bash"

            echo "✅ 项目已在 screen 会话 gensyn 中启动，可用 'screen -r gensyn' 查看"
            read -n 1 -s -r -p "按任意键返回主菜单..."
            ;;

        2)
            echo ">>> 正在查看 gensyn 会话..."
            screen -r gensyn
            echo "🔙 按 CTRL+A+D 返回主菜单"
            ;;

        3)
            echo ">>> 正在重启 gensyn 会话..."
            if screen -list | grep -q "gensyn"; then
                screen -S gensyn -X quit
                echo "🛑 已终止旧的 gensyn 会话"
            fi

            cd ~/rl-swarm || { echo "❌ 未找到 rl-swarm 项目目录"; read -n 1 -s -r -p "按任意键返回主菜单..."; continue; }

            screen -S gensyn -dm bash -c "source .venv/bin/activate && ./run_rl_swarm.sh; exec bash"
            echo "✅ gensyn 会话已重启"
            read -n 1 -s -r -p "按任意键返回主菜单..."
            ;;

        4)
            echo ">>> 正在安装 ngrok..."

            wget https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz
            tar -xvzf ngrok-v3-stable-linux-amd64.tgz
            sudo mv ngrok /usr/local/bin/

            echo "✅ ngrok 安装完成！"
            echo "请访问 https://ngrok.com/ 注册一个账号"
            echo "注册后，请在控制台找到你的 Authtoken，并复制"
            echo "然后将 Authtoken 粘贴到下面的输入框中："

            read -p "请输入你的 ngrok Authtoken: " authtoken
            ngrok config add-authtoken $authtoken

            echo "✅ ngrok 配置完成！"
            read -n 1 -s -r -p "按任意键返回主菜单..."
            ;;

        5)
            echo ">>> 启动 ngrok 隧道 (端口3000)..."

            screen -S ngrok -dm bash -c "ngrok http 3000; exec bash"
            echo "✅ ngrok 已在 screen 会话 ngrok 中启动"
            echo "👉 使用 'screen -r ngrok' 查看公网地址"
            read -n 1 -s -r -p "按任意键返回主菜单..."
            ;;

        6)
            echo "👋 已退出脚本"
            exit 0
            ;;
    esac
done
