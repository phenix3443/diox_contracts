#!/bin/bash
# GCL 合约测试脚本

set -e

# 颜色定义
RED='\033[0:31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# GCL simulator 路径
CHSIMU="/data/home/liushangliang/diox_dev_iobc_989_2511181655/gcl/bin/chsimu"

# 项目根目录
PROJECT_ROOT="/data/home/liushangliang/github/idea/diox_contracts/gcl-sample"

# 脚本目录
SCRIPT_DIR="$PROJECT_ROOT/script"

echo -e "${GREEN}======================================${NC}"
echo -e "${GREEN}   Diox Contracts GCL 测试套件${NC}"
echo -e "${GREEN}======================================${NC}"
echo ""

# 检查 chsimu 是否存在
if [ ! -f "$CHSIMU" ]; then
    echo -e "${RED}错误: 找不到 chsimu: $CHSIMU${NC}"
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
    cd "$(dirname $CHSIMU)"
    
    if ./chsimu "$test_file" -stdout -count:4; then
        echo -e "${GREEN}✅ $test_name 测试通过${NC}"
        echo ""
        return 0
    else
        echo -e "${RED}❌ $test_name 测试失败${NC}"
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
        echo "  all     - 运行所有测试 (默认)"
        echo "  help    - 显示此帮助信息"
        echo ""
        echo "示例:"
        echo "  $0              # 运行所有测试"
        echo "  $0 basic        # 只运行基础测试"
        echo "  $0 send         # 只运行发送测试"
        echo "  $0 receive      # 只运行接收测试"
        exit 0
        ;;
    
    *)
        echo -e "${RED}未知选项: $1${NC}"
        echo "使用 '$0 help' 查看帮助"
        exit 1
        ;;
esac

echo -e "${GREEN}✨ 测试完成！${NC}"

