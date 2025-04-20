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
    echo "3. 退出"
    echo "==========================================="

    # 输入验证
    read -p "请输入选项（1-3）: " choice
    while [[ ! "$choice" =~ ^[1-3]$ ]]; do
        echo "❌ 请输入有效的选项（1-3）"
        read -p "请输入选项（1-3）: " choice
    done

    case "$choice" in
        1)
            echo ">>> 开始安装基础环境和项目..."
            # 安装依赖（已安装则跳过）
            for pkg in python3 python3-venv python3-pip curl screen git; do
                dpkg -s $pkg &>/dev/null || sudo apt install -y $pkg
            done

            # 安装 Yarn
            if ! command -v yarn &>/dev/null; then
                curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
                echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
                sudo apt update && sudo apt install -y yarn
            fi

            # 安装 Node.js 和 npm
            if ! command -v node &>/dev/null || ! command -v npm &>/dev/null; then
                curl -sSL https://raw.githubusercontent.com/zunxbt/installation/main/node.sh | bash
            fi

            # 克隆项目
            rm -rf rl-swarm && git clone https://github.com/zunxbt/rl-swarm.git && cd rl-swarm

            # 安装 protobuf 稳定版本
            pip install "protobuf==4.25.3"

            # 启动 Python 虚拟环境并在 screen 中运行，保持不退出
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
            echo "👋 已退出脚本"
            exit 0
            ;;

        *)
            echo "❌ 无效输入，请输入 1~3"
            ;;
    esac
done
