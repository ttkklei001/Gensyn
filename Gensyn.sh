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
    echo "6. 修改 mac 和 gpu 配置文件"
    echo "7. 退出"
    echo "==========================================="

    read -p "请输入选项（1-7）: " choice
    while [[ ! "$choice" =~ ^[1-7]$ ]]; do
        echo "❌ 请输入有效的选项（1-7）"
        read -p "请输入选项（1-7）: " choice
    done

    case "$choice" in
        1)
            echo ">>> 开始安装基础环境和项目..."

            # 检查并安装基础依赖
            for pkg in python3 python3-venv python3-pip curl screen git; do
                dpkg -s $pkg &>/dev/null || sudo apt install -y $pkg
            done

            # 检查并更新 git
            current_git_version=$(git --version | awk '{print $3}')
            latest_git_version=$(apt-cache show git | grep Version | head -n 1 | awk '{print $2}')
            if [ "$current_git_version" != "$latest_git_version" ]; then
                echo ">>> git 不是最新版本，正在更新..."
                sudo apt update && sudo apt install --only-upgrade git
            else
                echo ">>> git 已是最新版本"
            fi

            # 安装 yarn 和 nodejs
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

            # 安装指定版本的 protobuf
            pip install "protobuf==4.25.3"

            # 如果有旧的 gensyn 会话，则先删除
            if screen -list | grep -q "gensyn"; then
                screen -S gensyn -X quit
                echo "🛑 已终止旧的 gensyn 会话"
            fi

            # 删除旧的虚拟环境（如果存在）
            if [ -d ".venv" ]; then
                rm -rf .venv
                echo "🛑 已删除旧的虚拟环境"
            fi

            # 启动新的 gensyn 会话并执行命令：创建虚拟环境、激活虚拟环境、安装依赖、执行脚本
            screen -S gensyn -dm bash -c "
                python3 -m venv .venv && 
                source .venv/bin/activate && 
                pip install -r requirements.txt && 
                ./run_rl_swarm.sh
                exec bash
            "

            echo ">>> gensyn 会话已启动，使用 'screen -r gensyn' 查看"
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

            # 删除旧的虚拟环境（如果存在）
            if [ -d ".venv" ]; then
                rm -rf .venv
                echo "🛑 已删除旧的虚拟环境"
            fi

            screen -S gensyn -dm bash -c "
                python3 -m venv .venv && 
                source .venv/bin/activate && 
                pip install -r requirements.txt && 
                ./run_rl_swarm.sh
                exec bash
            "
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
            echo ">>> 修改 mac 和 gpu 配置文件..."

            # 修改 mac 配置文件中的参数
            echo ">>> 正在修改 mac 配置文件..."
            sed -i 's/max_steps: [0-9]\+/max_steps: 5/' /root/rl-swarm/hivemind_exp/configs/mac/grpo-qwen-2.5-0.5b-deepseek-r1.yaml
            sed -i 's/train_batch_size: [0-9]\+/train_batch_size: 1/' /root/rl-swarm/hivemind_exp/configs/mac/grpo-qwen-2.5-0.5b-deepseek-r1.yaml
            sed -i 's/gradient_accumulation_steps: [0-9]\+/gradient_accumulation_steps: 1/' /root/rl-swarm/hivemind_exp/configs/mac/grpo-qwen-2.5-0.5b-deepseek-r1.yaml
            sed -i 's/max_prompt_length: [0-9]\+/max_prompt_length: 64/' /root/rl-swarm/hivemind_exp/configs/mac/grpo-qwen-2.5-0.5b-deepseek-r1.yaml
            sed -i 's/max_completion_length: [0-9]\+/max_completion_length: 64/' /root/rl-swarm/hivemind_exp/configs/mac/grpo-qwen-2.5-0.5b-deepseek-r1.yaml

            # 修改 gpu 配置文件中的参数
            echo ">>> 正在修改 gpu 配置文件..."
            sed -i 's/max_steps: [0-9]\+/max_steps: 5/' /root/rl-swarm/hivemind_exp/configs/gpu/grpo-qwen-2.5-0.5b-deepseek-r1.yaml
            sed -i 's/train_batch_size: [0-9]\+/train_batch_size: 1/' /root/rl-swarm/hivemind_exp/configs/gpu/grpo-qwen-2.5-0.5b-deepseek-r1.yaml
            sed -i 's/gradient_accumulation_steps: [0-9]\+/gradient_accumulation_steps: 1/' /root/rl-swarm/hivemind_exp/configs/gpu/grpo-qwen-2.5-0.5b-deepseek-r1.yaml
            sed -i 's/max_prompt_length: [0-9]\+/max_prompt_length: 64/' /root/rl-swarm/hivemind_exp/configs/gpu/grpo-qwen-2.5-0.5b-deepseek-r1.yaml
            sed -i 's/max_completion_length: [0-9]\+/max_completion_length: 64/' /root/rl-swarm/hivemind_exp/configs/gpu/grpo-qwen-2.5-0.5b-deepseek-r1.yaml

            echo ">>> 配置文件已更新！"
            read -n 1 -s -r -p "按任意键返回主菜单..."
            ;;

        7)
            echo "👋 已退出脚本"
            exit 0
            ;;

    esac
done
