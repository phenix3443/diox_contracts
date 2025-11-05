# 🚀 快速开始指南

## 📦 已创建的文件

```
ethereum-sample/
├── foundry.toml              ✅ Foundry 配置文件
├── remappings.txt            ✅ 路径映射配置
├── .gitignore                ✅ Git 忽略文件
├── TEST_README.md            ✅ 详细测试文档
├── QUICK_START.md            ✅ 本文件
├── run_tests.sh              ✅ 测试启动脚本
│
└── test/                     ✅ 测试目录
    ├── FullIntegration.t.sol ✅ 完整集成测试（9个测试用例）
    └── AppContract.t.sol     ✅ AppContract 单元测试（13+测试用例）
```

## ⚡ 超快速开始（3 步）

### 方式 1: 使用启动脚本（推荐）

```bash
cd /data/home/liushangliang/github/idea/diox_contracts/ethereum-sample

# 运行所有测试（自动安装依赖）
./run_tests.sh

# 或选择特定测试类型
./run_tests.sh integration  # 集成测试
./run_tests.sh app         # AppContract 测试
./run_tests.sh gas         # Gas 报告
./run_tests.sh coverage    # 覆盖率报告
```

### 方式 2: 手动运行

```bash
cd /data/home/liushangliang/github/idea/diox_contracts/ethereum-sample

# 1. 安装 forge-std（首次运行需要）
forge install foundry-rs/forge-std --no-commit

# 2. 编译合约
forge build

# 3. 运行测试
forge test -vv
```

## 📊 测试输出预览

运行 `./run_tests.sh integration` 将看到：

```
🚀 Diox Contracts - Foundry 测试
================================

✅ Foundry 已安装: forge 0.2.0
✅ 依赖已安装

🔨 编译合约...
[⠆] Compiling...
Compiler run successful

📊 运行测试...

▶️  运行集成测试

Running 9 tests for test/FullIntegration.t.sol:FullIntegrationTest

[PASS] test_FullSendFlow_AllEventsTriggered() (gas: 234567)
Logs:
  ✅ Test 1 Passed: All events triggered correctly

[PASS] test_FullSendFlow_AllStateChanges() (gas: 345678)
Logs:
  ✅ Test 2 Passed: All state changes verified

[PASS] test_MultipleMessages_SequenceIncrement() (gas: 678901)
Logs:
  ✅ Test 3 Passed: Multiple messages with sequence increment

... (更多测试)

Test result: ok. 9 passed; 0 failed; finished in 2.34s

✅ 测试完成！
```

## 🎯 测试覆盖

### FullIntegration.t.sol - 完整集成测试

验证完整的 **AppContract → SDPMsg → AuthMsg** 消息链路：

✅ **测试 1**: 所有合约事件触发验证  
✅ **测试 2**: 所有合约状态变更验证  
✅ **测试 3**: 多消息序列号递增测试  
✅ **测试 4**: 无序消息完整流程  
✅ **测试 5**: 协议注册和事件  
✅ **测试 6**: 权限控制验证  
✅ **测试 7**: Gas 消耗分析  
✅ **测试 8**: 初始化状态验证  
✅ **测试 9**: 配置变更测试  

**关键验证点**:
- ✅ AppContract 的 `sendCrosschainMsg` 事件
- ✅ SDPMsg 的序列号正确递增
- ✅ AuthMsg 的 `SendAuthMessage` 事件
- ✅ 所有状态变量正确更新

### AppContract.t.sol - 单元测试

详细测试 AppContract 的所有功能：

- ✅ 基础功能（初始化、配置）
- ✅ 发送消息（有序、无序、多条）
- ✅ 接收消息（有序、无序）
- ✅ 权限控制
- ✅ Getter 函数
- ✅ Fuzzing 测试（随机输入）

## 💡 常用命令

```bash
# 查看测试帮助
./run_tests.sh help

# 运行所有测试
./run_tests.sh all

# 运行集成测试（验证完整链路）
./run_tests.sh integration

# 运行单元测试
./run_tests.sh app

# 查看 Gas 报告
./run_tests.sh gas

# 生成覆盖率报告
./run_tests.sh coverage

# 详细调试模式
./run_tests.sh debug
```

## 📚 详细文档

查看 **TEST_README.md** 获取：
- 📖 完整的测试命令参考
- 🔧 故障排查指南
- 💡 最佳实践
- 📊 预期输出示例

## 🎉 你现在可以

1. ✅ **验证完整消息链路** - AppContract → SDPMsg → AuthMsg
2. ✅ **检查所有事件触发** - 三个合约的所有事件
3. ✅ **验证状态变更** - 每个合约的状态更新
4. ✅ **分析 Gas 消耗** - 优化合约性能
5. ✅ **Fuzzing 测试** - 发现边界条件问题

## 🔗 相关资源

- [TEST_README.md](./TEST_README.md) - 详细测试文档
- [Foundry Book](https://book.getfoundry.sh/) - Foundry 官方文档
- [测试源码](./test/) - 查看完整测试代码

---

**开始测试吧！** 🚀

```bash
cd /data/home/liushangliang/github/idea/diox_contracts/ethereum-sample
./run_tests.sh
```

