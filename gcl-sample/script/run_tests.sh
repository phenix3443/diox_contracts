#!/bin/bash
# GCL 合约测试脚本

set -e

# 颜色定义
RED='\033[0:31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 获取脚本所在目录的绝对路径
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# 项目根目录（脚本目录的父目录）
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# GCL simulator 路径
# 优先使用环境变量，否则尝试常见路径
CHSIMU=""
if [ -n "$GCL_PATH" ] && [ -f "$GCL_PATH" ]; then
    CHSIMU="$GCL_PATH"
elif [ -n "$CHSIMU_PATH" ] && [ -f "$CHSIMU_PATH" ]; then
    CHSIMU="$CHSIMU_PATH"
elif [ -f "$HOME/diox_dev_iobc_989_2511181655/gcl/bin/chsimu" ]; then
    CHSIMU="$HOME/diox_dev_iobc_989_2511181655/gcl/bin/chsimu"
elif [ -f "$PROJECT_ROOT/../diox_dev_iobc_989_2511181655/gcl/bin/chsimu" ]; then
    CHSIMU="$(cd "$PROJECT_ROOT/../diox_dev_iobc_989_2511181655/gcl/bin" && pwd)/chsimu"
fi

echo -e "${GREEN}======================================${NC}"
echo -e "${GREEN}   Diox Contracts GCL 测试套件${NC}"
echo -e "${GREEN}======================================${NC}"
echo ""

# 检查 chsimu 是否存在
if [ -z "$CHSIMU" ] || [ ! -f "$CHSIMU" ]; then
    echo -e "${RED}错误: 找不到 chsimu${NC}"
    echo ""
    echo "请使用以下方式之一指定 chsimu 路径："
    echo "  1. 设置环境变量: export GCL_PATH=/path/to/chsimu"
    echo "  2. 设置环境变量: export CHSIMU_PATH=/path/to/chsimu"
    echo "  3. 将 chsimu 放在: \$HOME/diox_dev_iobc_989_2511181655/gcl/bin/chsimu"
    echo "  4. 将 chsimu 放在: ../diox_dev_iobc_989_2511181655/gcl/bin/chsimu"
    echo ""
    if [ -n "$CHSIMU" ]; then
        echo "尝试的路径: $CHSIMU"
    fi
    exit 1
fi

# 检查项目目录
if [ ! -d "$PROJECT_ROOT" ]; then
    echo -e "${RED}错误: 找不到项目目录: $PROJECT_ROOT${NC}"
    exit 1
fi

# 进入项目目录
cd "$PROJECT_ROOT"

# 运行测试的函数
run_test() {
    local test_file=$1
    local test_name=$2

    echo -e "${YELLOW}运行测试: $test_name${NC}"
    echo "测试文件: $test_file"
    echo ""

    # 切换到 chsimu 所在目录运行（需要加载动态库）
    cd "$(dirname "$CHSIMU")"

    # 运行测试并捕获输出
    local output=$(./chsimu "$test_file" -stdout -count:4 2>&1)
    local exit_code=$?

    # 检查输出中是否有错误
    local has_error=false
    if echo "$output" | grep -qiE "compile error|Compile failed|Engine invoke error|ExceptionThrown|not found"; then
        has_error=true
    fi

    # 检查是否成功运行
    local has_success=false
    if echo "$output" | grep -qiE "Run script successfully"; then
        has_success=true
    fi

    # 显示输出
    echo "$output"
    echo ""

    # 判断测试是否通过
    if [ "$exit_code" -eq 0 ] && [ "$has_success" = true ] && [ "$has_error" = false ]; then
        echo -e "${GREEN}✅ $test_name 测试通过${NC}"
        echo ""
        return 0
    else
        if [ "$has_error" = true ]; then
            echo -e "${RED}❌ $test_name 测试失败 - 发现编译或运行时错误${NC}"
        elif [ "$exit_code" -ne 0 ]; then
            echo -e "${RED}❌ $test_name 测试失败 - 退出码: $exit_code${NC}"
        else
            echo -e "${RED}❌ $test_name 测试失败 - 未找到成功标记${NC}"
        fi
        echo ""
        return 1
    fi
}

# 根据参数选择测试
case "${1:-all}" in
    "basic")
        echo -e "${YELLOW}运行基础功能测试...${NC}"
        run_test "$SCRIPT_DIR/test_basic.gclts" "基础功能"
        ;;

    "send")
        echo -e "${YELLOW}运行发送消息测试...${NC}"
        run_test "$SCRIPT_DIR/test_send.gclts" "发送消息"
        ;;

    "receive")
        echo -e "${YELLOW}运行接收消息测试...${NC}"
        run_test "$SCRIPT_DIR/test_receive.gclts" "接收消息"
        ;;

    "am")
        echo -e "${YELLOW}运行 AuthMsg 测试...${NC}"
        run_test "$SCRIPT_DIR/test_am.gclts" "AuthMsg"
        ;;

    "sdp")
        echo -e "${YELLOW}运行 SDPMsg 测试...${NC}"
        run_test "$SCRIPT_DIR/test_sdp.gclts" "SDPMsg"
        ;;

    "app")
        echo -e "${YELLOW}运行 AppContract 测试...${NC}"
        run_test "$SCRIPT_DIR/test_app.gclts" "AppContract"
        ;;

    "all")
        echo -e "${YELLOW}运行所有测试...${NC}"
        echo ""

        passed=0
        failed=0

        if run_test "$SCRIPT_DIR/test_basic.gclts" "基础功能"; then
            ((passed++))
        else
            ((failed++))
        fi

        if run_test "$SCRIPT_DIR/test_send.gclts" "发送消息"; then
            ((passed++))
        else
            ((failed++))
        fi

        if run_test "$SCRIPT_DIR/test_receive.gclts" "接收消息"; then
            ((passed++))
        else
            ((failed++))
        fi

        if run_test "$SCRIPT_DIR/test_am.gclts" "AuthMsg"; then
            ((passed++))
        else
            ((failed++))
        fi

        if run_test "$SCRIPT_DIR/test_sdp.gclts" "SDPMsg"; then
            ((passed++))
        else
            ((failed++))
        fi

        if run_test "$SCRIPT_DIR/test_app.gclts" "AppContract"; then
            ((passed++))
        else
            ((failed++))
        fi

        echo -e "${GREEN}======================================${NC}"
        echo -e "${GREEN}测试总结:${NC}"
        echo -e "${GREEN}  通过: $passed${NC}"
        if [ $failed -gt 0 ]; then
            echo -e "${RED}  失败: $failed${NC}"
        else
            echo -e "${GREEN}  失败: $failed${NC}"
        fi
        echo -e "${GREEN}======================================${NC}"

        if [ $failed -gt 0 ]; then
            exit 1
        fi
        ;;

    "help"|"-h"|"--help")
        echo "用法: $0 [选项]"
        echo ""
        echo "选项:"
        echo "  basic   - 运行基础功能测试"
        echo "  send    - 运行发送消息测试"
        echo "  receive - 运行接收消息测试"
        echo "  am      - 运行 AuthMsg 测试"
        echo "  sdp     - 运行 SDPMsg 测试"
        echo "  app     - 运行 AppContract 测试"
        echo "  all     - 运行所有测试 (默认)"
        echo "  help    - 显示此帮助信息"
        echo ""
        echo "示例:"
        echo "  $0              # 运行所有测试"
        echo "  $0 basic        # 只运行基础测试"
        echo "  $0 send         # 只运行发送测试"
        echo "  $0 receive      # 只运行接收测试"
        echo "  $0 am           # 只运行 AuthMsg 测试"
        echo "  $0 sdp          # 只运行 SDPMsg 测试"
        echo "  $0 app          # 只运行 AppContract 测试"
        exit 0
        ;;

    *)
        echo -e "${RED}未知选项: $1${NC}"
        echo "使用 '$0 help' 查看帮助"
        exit 1
        ;;
esac

echo -e "${GREEN}✨ 测试完成！${NC}"

