# GCL 测试脚本

> Diox Contracts GCL 版本的自动化测试脚本

## 🚀 快速开始

```bash
cd /data/home/liushangliang/github/idea/diox_contracts/gcl-sample

# 运行所有测试
./script/run_tests.sh

# 运行特定测试
./script/run_tests.sh basic    # 基础功能测试
./script/run_tests.sh send     # 发送消息测试
```

## 📁 测试脚本说明

### 1. test_basic.gclts ✅ 通过

**测试内容**:
- 部署所有工具库
- 部署所有接口
- 部署核心合约（AuthMsg, SDPMsg, AppContract）
- 验证自动配置

**运行方式**:
```bash
./script/run_tests.sh basic
```

**预期输出**:
```
[HIGHLIGHT] ===== 开始基础功能测试 =====
✅ 工具库部署完成
✅ 协议库部署完成
✅ 接口部署完成
  ✅ AuthMsg deployed
  ✅ SDPMsg deployed
  ✅ AppContract deployed
[HIGHLIGHT] ===== 所有合约部署成功 =====
```

### 2. test_send.gclts ✅ 通过

**测试内容**:
- 部署所有合约
- 测试有序消息发送
- 测试多条消息发送
- 测试无序消息发送
- 测试不同发送者

**运行方式**:
```bash
./script/run_tests.sh send
```

**预期输出**:
```
[HIGHLIGHT] 所有合约部署完成，开始测试发送功能
===== 测试有序消息发送 =====
✅ 有序消息发送成功
===== 测试发送多条消息 =====
✅ 多条有序消息发送成功
===== 测试无序消息发送 =====
✅ 无序消息发送成功
===== 测试不同发送者 =====
✅ 不同发送者测试成功
[HIGHLIGHT] 所有发送测试完成
```

## 📊 测试覆盖

### ✅ 已测试功能

- [x] 合约部署
- [x] 自动配置（依赖关系）
- [x] 有序消息发送
- [x] 无序消息发送
- [x] 多条消息发送
- [x] 不同发送者
- [x] 事件触发（sendCrosschainMsg）

### ⚠️ 待测试功能

- [ ] 消息接收（recvMessage）
- [ ] 跨链消息解码（需要修复 TLV 解析）
- [ ] 序列号验证
- [ ] 权限控制测试

## 🔧 已修复的问题

### 1. 下溢错误 (Underflow) ✅

**问题**: `BytesToTypes.bytesToSubBytes` 在 offset < 32 时会下溢

**修复**: 使用直接循环复制数据，不使用 `bytesToSubBytes`

### 2. 字节序问题 ✅

**问题**: UCP 包头使用 big-endian，但代码使用 little-endian 读取

**修复**: 在 `AMLib.decodeMessageFromRelayer` 中使用 big-endian 读取 hintsLen 和 proofLen

### 3. 数据提取问题 ✅

**问题**: `_decodeMsgBodyFromUDAGResp` 使用错误的函数提取数据

**修复**: 使用循环直接复制指定范围的字节

## 📝 使用说明

### 运行单个测试

```bash
cd /data/home/liushangliang/diox_dev_iobc_989_2511181655/gcl/bin

# 直接运行测试文件
./chsimu /data/home/liushangliang/github/idea/diox_contracts/gcl-sample/script/test_basic.gclts -stdout -count:4

# 或使用脚本
cd /data/home/liushangliang/github/idea/diox_contracts/gcl-sample
./script/run_tests.sh basic
```

### 运行所有测试

```bash
cd /data/home/liushangliang/github/idea/diox_contracts/gcl-sample
./script/run_tests.sh all
```

### 查看帮助

```bash
./script/run_tests.sh help
```

## 🐛 已知问题

### 1. 消息接收测试失败

**状态**: 正在调试中

**问题**: TLV 解析在处理复杂嵌套结构时出现越界错误

**临时方案**: 目前只测试发送功能

### 2. 跨合约调用未实现

**状态**: 待开发

**问题**: AppContract 中的跨合约调用代码被注释

**影响**: 无法测试完整的消息流程

## 📚 相关文档

- [项目分析报告.md](../../../phenix3443/idea/cursor/diox_contract/项目分析报告.md) - 项目现状分析
- [开发测试指南.md](../../../phenix3443/idea/cursor/diox_contract/开发测试指南.md) - 开发和测试指南
- [README.md](../README.md) - GCL 版本说明

---

**测试脚本创建时间**: 2025-11-05  
**状态**: 基础测试和发送测试 ✅ 通过

