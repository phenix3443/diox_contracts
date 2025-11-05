#!/bin/bash
# Foundry 测试快速启动脚本

set -e

echo "🚀 Diox Contracts - Foundry 测试"
echo "================================"
echo ""

# 检查 Foundry 是否已安装
if ! command -v forge &> /dev/null; then
    echo "❌ Foundry 未安装！"
    echo "📦 正在安装 Foundry..."
    curl -L https://foundry.paradigm.xyz | bash
    source ~/.bashrc
    foundryup
    echo "✅ Foundry 安装完成"
else
    echo "✅ Foundry 已安装: $(forge --version | head -n 1)"
fi

echo ""

# 安装依赖
if [ ! -d "lib/forge-std" ]; then
    echo "📦 安装测试依赖 forge-std..."
    forge install foundry-rs/forge-std --no-commit
    echo "✅ 依赖安装完成"
else
    echo "✅ 依赖已安装"
fi

echo ""
echo "🔨 编译合约..."
forge build

echo ""
echo "📊 运行测试..."
echo ""

# 根据参数选择测试类型
case "${1:-all}" in
    "all")
        echo "▶️  运行所有测试"
        forge test -vv
        ;;
    "integration")
        echo "▶️  运行集成测试"
        forge test --match-contract FullIntegrationTest -vv
        ;;
    "app")
        echo "▶️  运行 AppContract 测试"
        forge test --match-contract AppContractTest -vv
        ;;
    "gas")
        echo "▶️  运行测试并显示 Gas 报告"
        forge test --gas-report
        ;;
    "coverage")
        echo "▶️  生成覆盖率报告"
        forge coverage
        ;;
    "debug")
        echo "▶️  运行详细调试模式"
        forge test -vvvv
        ;;
    *)
        echo "❌ 未知选项: $1"
        echo ""
        echo "用法: ./run_tests.sh [选项]"
        echo ""
        echo "选项:"
        echo "  all         - 运行所有测试 (默认)"
        echo "  integration - 运行集成测试"
        echo "  app         - 运行 AppContract 测试"
        echo "  gas         - 显示 Gas 报告"
        echo "  coverage    - 生成覆盖率报告"
        echo "  debug       - 详细调试模式"
        exit 1
        ;;
esac

echo ""
echo "✅ 测试完成！"

