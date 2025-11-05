# Ethereum Sample 测试指南

> 使用 Foundry 测试 Diox Contracts 的 Solidity 实现

## 🚀 快速开始

### 1. 安装 Foundry

```bash
# 安装 Foundry（如果还没安装）
curl -L https://foundry.paradigm.xyz | bash
foundryup

# 验证安装
forge --version
```

### 2. 安装依赖

```bash
cd /data/home/liushangliang/github/idea/diox_contracts/ethereum-sample

# 安装 forge-std（测试库）
forge install foundry-rs/forge-std --no-commit
```

### 3. 运行测试

```bash
# 运行所有测试
forge test

# 运行特定测试文件
forge test --match-contract FullIntegrationTest

# 显示详细输出
forge test -vv

# 显示非常详细的输出（包括调用栈）
forge test -vvvv
```

## 📁 测试文件说明

### test/FullIntegration.t.sol ⭐ 推荐

**完整的端到端集成测试**

测试内容：
- ✅ AppContract → SDPMsg → AuthMsg 完整消息链路
- ✅ 所有合约的事件触发验证
- ✅ 所有合约的状态变更验证
- ✅ 序列号管理
- ✅ 权限控制
- ✅ Gas 分析

包含 9 个测试用例：
1. `test_FullSendFlow_AllEventsTriggered` - 验证所有事件
2. `test_FullSendFlow_AllStateChanges` - 验证所有状态
3. `test_MultipleMessages_SequenceIncrement` - 多消息序列号测试
4. `test_UnorderedMessage_FullFlow` - 无序消息测试
5. `test_ProtocolRegistration` - 协议注册测试
6. `test_UnauthorizedCalls_Reverted` - 权限控制测试
7. `test_Gas_FullSendFlow` - Gas 分析
8. `test_Initialization` - 初始化测试
9. `test_ConfigurationChanges` - 配置变更测试

```bash
# 运行集成测试
forge test --match-contract FullIntegrationTest -vv
```

### test/AppContract.t.sol

**AppContract 单元测试**

测试内容：
- ✅ 基础功能（初始化、配置）
- ✅ 发送消息（有序、无序）
- ✅ 接收消息（有序、无序）
- ✅ Getter 函数
- ✅ Fuzzing 测试

包含 13+ 个测试用例。

```bash
# 运行 AppContract 测试
forge test --match-contract AppContractTest -vv
```

## 📊 测试命令速查

### 基础测试

```bash
# 运行所有测试
forge test

# 运行特定测试文件
forge test --match-path test/FullIntegration.t.sol

# 运行特定测试函数
forge test --match-test test_FullSendFlow_AllEventsTriggered

# 运行匹配模式的测试
forge test --match-test "test_Full*"
```

### 详细输出

```bash
# -v: 显示失败的测试
forge test -v

# -vv: 显示控制台日志
forge test -vv

# -vvv: 显示失败测试的堆栈跟踪
forge test -vvv

# -vvvv: 显示所有测试的堆栈跟踪
forge test -vvvv

# -vvvvv: 显示执行 traces
forge test -vvvvv
```

### Gas 报告

```bash
# 生成 Gas 报告
forge test --gas-report

# 指定合约的 Gas 报告
forge test --match-contract FullIntegrationTest --gas-report

# 保存 Gas 报告到文件
forge test --gas-report > gas-report.txt
```

### 覆盖率

```bash
# 生成覆盖率报告
forge coverage

# 生成 lcov 格式的覆盖率报告
forge coverage --report lcov

# 查看详细的覆盖率
forge coverage --report debug
```

### Fuzzing

```bash
# 运行 fuzzing 测试（默认 256 次）
forge test --match-test testFuzz

# 增加 fuzzing 运行次数
forge test --match-test testFuzz --fuzz-runs 10000
```

### 调试

```bash
# 使用交互式调试器
forge test --debug test_FullSendFlow_AllEventsTriggered

# 查看特定测试的详细追踪
forge test --match-test test_FullSendFlow -vvvvv
```

## 📈 预期输出示例

```bash
$ forge test --match-contract FullIntegrationTest -vv

[⠢] Compiling...
[⠆] Compiling 12 files with 0.8.0
[⠰] Solc 0.8.0 finished in 2.31s
Compiler run successful

Running 9 tests for test/FullIntegration.t.sol:FullIntegrationTest

[PASS] test_FullSendFlow_AllEventsTriggered() (gas: 234567)
Logs:
  === Contracts Deployed ===
  AuthMsg: 0x...
  SDPMsg: 0x...
  AppContract: 0x...
  ✅ Test 1 Passed: All events triggered correctly

[PASS] test_FullSendFlow_AllStateChanges() (gas: 345678)
Logs:
  ✅ Test 2 Passed: All state changes verified

[PASS] test_MultipleMessages_SequenceIncrement() (gas: 678901)
Logs:
  ✅ Test 3 Passed: Multiple messages with sequence increment

[PASS] test_UnorderedMessage_FullFlow() (gas: 234567)
Logs:
  ✅ Test 4 Passed: Unordered message flow

[PASS] test_ProtocolRegistration() (gas: 123456)
Logs:
  ✅ Test 5 Passed: Protocol registration

[PASS] test_UnauthorizedCalls_Reverted() (gas: 234567)
Logs:
  ✅ Test 6 Passed: Unauthorized calls reverted

[PASS] test_Gas_FullSendFlow() (gas: 234567)
Logs:
  === Full Send Flow Gas Usage ===: 234567
  ✅ Test 7 Passed: Gas analysis completed

[PASS] test_Initialization() (gas: 123456)
Logs:
  ✅ Test 8 Passed: Initialization verified

[PASS] test_ConfigurationChanges() (gas: 234567)
Logs:
  ✅ Test 9 Passed: Configuration changes

Test result: ok. 9 passed; 0 failed; finished in 2.34s
```

## 🎯 测试覆盖清单

### ✅ AppContract
- [x] 初始化和配置
- [x] 发送有序消息
- [x] 发送无序消息
- [x] 接收有序消息
- [x] 接收无序消息
- [x] 权限控制
- [x] 事件触发
- [x] Getter 函数
- [x] Fuzzing 测试

### ✅ SDPMsg
- [x] 初始化和配置
- [x] 序列号管理
- [x] 调用 AuthMsg
- [x] 权限控制

### ✅ AuthMsg
- [x] 初始化和配置
- [x] 协议注册
- [x] 接收来自 SDP 的消息
- [x] 事件触发
- [x] 权限控制

### ✅ 集成测试
- [x] 完整消息链路
- [x] 多合约事件验证
- [x] 跨合约状态验证
- [x] Gas 分析

## 🔧 故障排查

### 问题 1: `forge: command not found`

**解决方案**:
```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

### 问题 2: 编译错误 `File import callback not supported`

**解决方案**: 检查 `foundry.toml` 和 `remappings.txt` 配置是否正确。

### 问题 3: 测试失败但不显示详细信息

**解决方案**: 使用 `-vvvv` 查看详细的调用栈。
```bash
forge test --match-test test_FullSendFlow -vvvv
```

### 问题 4: Gas 报告不准确

**解决方案**: 确保在 `foundry.toml` 中启用了优化器。

## 📚 相关文档

- [Foundry Book](https://book.getfoundry.sh/)
- [Forge Standard Library](https://github.com/foundry-rs/forge-std)
- [Solidity 文档](https://docs.soliditylang.org/)

## 💡 最佳实践

1. **先运行单元测试，再运行集成测试**
2. **使用 `-vv` 查看日志输出**
3. **定期生成 Gas 报告，优化合约**
4. **使用 Fuzzing 发现边界情况**
5. **保持测试覆盖率 > 80%**

---

**测试愉快！** 🚀

