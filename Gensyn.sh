#!/bin/bash

clear

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
    echo "6. 修改配置文件"
    echo "7. 退出"
    echo "==========================================="

    read -p "请输入选项（1-7）: " choice
    while [[ ! "$choice" =~ ^[1-7]$ ]]; do
        echo "❌ 请输入有效的选项（1-7）"
        read -p "请输入选项（1-7）: " choice
    done

    case "$choice" in
        1)
            echo ">>> 正在安装基础环境..."

            for pkg in python3 python3-venv python3-pip curl screen git; do
                if ! dpkg -s "$pkg" &>/dev/null; then
                    echo ">>> 安装 $pkg..."
                    sudo apt install -y "$pkg"
                fi
            done

            echo ">>> 检查 Git 是否是最新版本..."
            current_git_version=$(git --version | awk '{print $3}')
            latest_git_version=$(apt-cache policy git | grep Candidate | awk '{print $2}')
            if [ "$current_git_version" != "$latest_git_version" ]; then
                echo ">>> 更新 Git..."
                sudo apt update && sudo apt install --only-upgrade -y git
            fi

            if ! command -v yarn &>/dev/null; then
                echo ">>> 安装 Yarn..."
                curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo gpg --dearmor -o /usr/share/keyrings/yarnkey.gpg
                echo "deb [signed-by=/usr/share/keyrings/yarnkey.gpg] https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
                sudo apt update && sudo apt install -y yarn
            fi

            if ! command -v node &>/dev/null || ! command -v npm &>/dev/null; then
                echo ">>> 安装 Node.js 和 npm..."
                curl -sSL https://raw.githubusercontent.com/zunxbt/installation/main/node.sh | bash
            fi

            if [ ! -d "/root/rl-swarm" ]; then
                echo ">>> 克隆 rl-swarm 项目..."
                git clone https://github.com/zunxbt/rl-swarm.git /root/rl-swarm
            else
                echo ">>> 项目已存在，执行更新..."
                cd /root/rl-swarm && git pull
            fi

            echo ">>> 正在安装 Python 依赖..."
            cd /root/rl-swarm && \
            pip install --upgrade pip && \
            pip install "protobuf==4.25.3" && \
            pip install -r requirements.txt

            if screen -list | grep -q "gensyn"; then
                screen -S gensyn -X quit
                echo "🛑 已关闭旧的 gensyn 会话"
            fi

            echo ">>> 启动 gensyn 会话..."
            screen -S gensyn -dm bash -c "./run_rl_swarm.sh; exec bash"
            echo "✅ gensyn 会话已启动"
            read -n 1 -s -r -p "按任意键返回主菜单..."
            ;;

        2)
            echo ">>> 正在连接 gensyn 会话..."
            screen -r gensyn || echo "❌ 当前没有正在运行的 gensyn 会话"
            echo "🔙 按 CTRL+A+D 返回主菜单"
            ;;

        3)
            echo ">>> 正在重启 gensyn 会话..."
            if screen -list | grep -q "gensyn"; then
                screen -S gensyn -X quit
                echo "🛑 旧的 gensyn 会话已关闭"
            fi

            cd /root/rl-swarm || { echo "❌ 未找到 rl-swarm 目录"; read -n 1 -s -r -p "按任意键返回主菜单..."; continue; }

            screen -S gensyn -dm bash -c "./run_rl_swarm.sh; exec bash"
            echo "✅ gensyn 会话已重启"
            read -n 1 -s -r -p "按任意键返回主菜单..."
            ;;

        4)
            echo ">>> 安装并配置 ngrok..."

            if ! command -v ngrok &>/dev/null; then
                wget -q https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz
                tar -xzf ngrok-v3-stable-linux-amd64.tgz
                sudo mv ngrok /usr/local/bin/
                rm -f ngrok-v3-stable-linux-amd64.tgz
                echo "✅ ngrok 安装完成"
            else
                echo "✅ ngrok 已安装"
            fi

            echo "请访问 https://ngrok.com 获取 Authtoken"
            read -p "请输入你的 ngrok Authtoken: " authtoken
            ngrok config add-authtoken "$authtoken"

            echo "✅ ngrok 配置成功"
            read -n 1 -s -r -p "按任意键返回主菜单..."
            ;;

        5)
            echo ">>> 启动 ngrok 隧道 (端口 3000)..."
            if screen -list | grep -q "ngrok"; then
                screen -S ngrok -X quit
                echo "🛑 旧 ngrok 会话已关闭"
            fi

            screen -S ngrok -dm bash -c "ngrok http 3000; exec bash"
            echo "✅ ngrok 隧道已启动，使用 'screen -r ngrok' 查看"
            read -n 1 -s -r -p "按任意键返回主菜单..."
            ;;

        6)
            echo ">>> 修改配置文件..."
            for target in mac gpu; do
                file="/root/rl-swarm/hivemind_exp/configs/$target/grpo-qwen-2.5-0.5b-deepseek-r1.yaml"
                if [ -f "$file" ]; then
                    sed -i 's/max_steps: [0-9]\+/max_steps: 5/' "$file"
                    sed -i 's/train_batch_size: [0-9]\+/train_batch_size: 1/' "$file"
                    sed -i 's/gradient_accumulation_steps: [0-9]\+/gradient_accumulation_steps: 1/' "$file"
                    sed -i 's/max_prompt_length: [0-9]\+/max_prompt_length: 64/' "$file"
                    sed -i 's/max_completion_length: [0-9]\+/max_completion_length: 64/' "$file"
                    echo "✅ 已更新 $target 配置"
                else
                    echo "⚠️ 未找到 $target 配置文件"
                fi
            done
            read -n 1 -s -r -p "按任意键返回主菜单..."
            ;;

        7)
            echo "👋 已退出脚本"
            exit 0
            ;;
    esac
done
