#!/bin/bash

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
            # (省略安装和启动项目的代码)
            read -n 1 -s -r -p "按任意键返回主菜单..."
            ;;

        2)
            echo ">>> 正在查看 gensyn 会话..."
            # (省略查看 gensyn 会话的代码)
            read -n 1 -s -r -p "按任意键返回主菜单..."
            ;;

        3)
            echo ">>> 正在重启 gensyn 会话..."
            # (省略重启 gensyn 会话的代码)
            read -n 1 -s -r -p "按任意键返回主菜单..."
            ;;

        4)
            echo ">>> 正在安装 ngrok..."
            # (省略安装 ngrok 的代码)
            read -n 1 -s -r -p "按任意键返回主菜单..."
            ;;

        5)
            echo ">>> 启动 ngrok 隧道 (端口3000)..."
            # (省略启动 ngrok 隧道的代码)
            read -n 1 -s -r -p "按任意键返回主菜单..."
            ;;

        6)
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
