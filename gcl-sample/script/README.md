# GCL 测试脚本

> Diox Contracts GCL 版本的完整自动化测试套件

## 📋 测试概览

| 测试脚本 | 状态 | 测试用例数 | 说明 |
|---------|------|-----------|------|
| test_basic.gclts | ✅ 通过 | 1 | 合约部署和自动配置 |
| test_send.gclts | ✅ 通过 | 6 | 有序/无序消息发送 |
| test_receive.gclts | ✅ 通过 | 1 | 跨链消息接收 |
| test_am.gclts | ✅ 通过 | 2 | AuthMsg 合约功能 |
| test_sdp.gclts | ✅ 通过 | 3 | SDPMsg 合约功能 |
| test_app.gclts | ✅ 通过 | 3 | AppContract 完整流程 |
| **总计** | **✅ 100%** | **16** | **所有测试通过** |

## 🚀 快速开始

### 环境配置

1. **chsimu 路径配置**（任选其一）：
   ```bash
   # 方式 1: 设置环境变量（推荐）
   export GCL_PATH=/path/to/chsimu
   # 或
   export CHSIMU_PATH=/path/to/chsimu

   # 方式 2: 使用默认路径
   # $HOME/diox_dev_iobc_989_2511181655/gcl/bin/chsimu
   # 或 ../diox_dev_iobc_989_2511181655/gcl/bin/chsimu（相对于项目根目录）
   ```

2. **进入项目目录**：
   ```bash
   cd /path/to/diox_contracts/gcl-sample
   ```

### 运行测试

```bash
# 运行所有测试
./script/run_tests.sh all

# 运行特定测试
./script/run_tests.sh basic    # 基础功能测试
./script/run_tests.sh send     # 发送消息测试
./script/run_tests.sh receive  # 接收消息测试
./script/run_tests.sh am       # AuthMsg 测试
./script/run_tests.sh sdp      # SDPMsg 测试
./script/run_tests.sh app      # AppContract 测试

# 查看帮助
./script/run_tests.sh help
```

## 📁 测试脚本详细说明

### 1. test_basic.gclts ✅

**测试内容**:
- 部署 5 个工具库（Utils, SizeOf, TypesToBytes, BytesToTypes, TLVUtils）
- 部署 2 个协议库（SDPLib, AMLib）
- 部署 4 个接口（ISDPMessage, IContractUsingSDP, IAuthMessage, ISubProtocol）
- 部署 3 个核心合约（AuthMsg, SDPMsg, AppContract）
- 验证自动配置（依赖关系自动建立）

**运行方式**:
```bash
./script/run_tests.sh basic
```

**预期输出**:
```
✅ 工具库部署完成
✅ 协议库部署完成
✅ 接口部署完成
  ✅ AuthMsg deployed
  ✅ SDPMsg deployed
  ✅ AppContract deployed
✅ 基础功能 测试通过
```

### 2. test_send.gclts ✅

**测试内容**:
- 部署所有合约和依赖
- 测试单条有序消息发送
- 测试多条有序消息发送（序列号自动递增）
- 测试无序消息发送
- 测试不同发送者（序列号独立管理）
- 验证事件触发（sendCrosschainMsg）

**运行方式**:
```bash
./script/run_tests.sh send
```

**关键验证点**:
- 序列号管理：同一发送者的有序消息序列号递增（0 → 1 → 2 → 3）
- 无序消息：序列号为 0xFFFFFFFF
- 不同发送者：序列号独立管理
- 事件触发：所有消息发送都触发 sendCrosschainMsg 事件

### 3. test_receive.gclts ✅

**测试内容**:
- 接收 UCP 跨链数据包（来自 Testdata.md）
- 解析 AuthMessage（AM 层）
- 解析 SDPMessage（SDP 层）
- 验证消息路由到 AppContract

**运行方式**:
```bash
./script/run_tests.sh receive
```

**关键验证点**:
- UCP 包解析：正确读取 big-endian 格式的包头
- TLV 解析：正确解析 big-endian 存储的 TLV 数据
- 消息路由：消息正确路由到目标合约

### 4. test_am.gclts ✅

**测试内容**:
- 部署 AuthMsg 合约及其依赖
- 测试 `setProtocolWithID`：注册子协议
- 测试协议注册事件触发

**运行方式**:
```bash
./script/run_tests.sh am
```

**注意**: `recvFromProtocol` 需要从已注册的协议地址调用，暂未包含在测试中。

### 5. test_sdp.gclts ✅

**测试内容**:
- 部署 SDPMsg 合约及其依赖（包括 AuthMsg）
- 测试 `setLocalDomain`：设置本地域
- 测试 `setAmContract`：设置 AM 合约地址
- 验证自动注册到 AuthMsg（protocolType=3）

**运行方式**:
```bash
./script/run_tests.sh sdp
```

**注意**: `recvMessage` 需要正确格式的 pkg 数据，完整测试在 test_receive.gclts 中。

### 6. test_app.gclts ✅

**测试内容**:
- 完整的合约部署流程
- 测试发送无序消息（sendUnorderedMessage）
- 测试发送有序消息（sendMessage）
- 测试接收跨链消息（使用 Testdata.md 真实数据）
- 验证端到端消息流程

**运行方式**:
```bash
./script/run_tests.sh app
```

## 📊 测试覆盖详情

### ✅ 核心功能测试

- [x] **合约部署**: 所有库、接口、合约正确部署
- [x] **自动配置**: 依赖关系自动建立
  - SDPMsg 自动注册到 AuthMsg
  - AppContract 自动获取 SDPMsg
- [x] **消息发送**:
  - 有序消息（序列号管理）
  - 无序消息（序列号 0xFFFFFFFF）
  - 多条消息（序列号递增）
  - 不同发送者（独立序列号）
- [x] **消息接收**:
  - UCP 包解析
  - AuthMessage 解码
  - SDPMessage 解码
  - 消息路由
- [x] **事件触发**: sendCrosschainMsg 事件
- [x] **TLV 解析**: 正确解析 big-endian TLV 数据
- [x] **字节序处理**: Big-endian ↔ Little-endian 转换

### ⚠️ 待扩展测试

- [ ] 序列号验证（边界情况）
- [ ] 权限控制测试
- [ ] 错误处理测试（无效数据、越界等）
- [ ] 性能测试
- [ ] 并发测试

## 🔧 已修复的关键问题

### 1. 字节序不一致 ⭐ 核心问题

**错误**: `Engine invoke error: ExceptionThrown (Underflow/OutOfRange)`

**根本原因**:
- UCP 包头（hints length, proof length）使用 **big-endian** 格式
- TLV 数据（tag, length）使用 **big-endian** 存储
- 但代码使用 `BytesToTypes.bytesToUint32()` 读取，该函数使用 **little-endian**

**修复方案**:
1. UCP 包头使用 big-endian 手动读取：
   ```gcl
   uint32 hintsLen = 0u32;
   for (uint32 i = 0u32; i < 4u32; i++) {
       hintsLen = (hintsLen << 8u32) | uint32(rawMessage[offset + i]);
   }
   ```

2. TLV 解析：读取 big-endian 然后反转
   ```gcl
   // Read as big-endian
   uint16 tagBE = (uint16(rawData[offset]) << 8u16) | uint16(rawData[offset + 1u32]);
   // Reverse to little-endian
   result.tlvItem.tagType = ((tagBE & 0xFF00u16) >> 8u16) | ((tagBE & 0x00FFu16) << 8u16);
   ```

**参考**: Solidity 实现使用 `Utils.reverseUint16(Utils.readUint16(rawData, offset))`

### 2. 数据提取下溢

**错误**: `Engine invoke error: ExceptionThrown (Underflow)`

**根本原因**:
- `BytesToTypes.bytesToSubBytes(offset, input, output)` 期望从**末尾向前**读取
- 当 `offset < 32` 时，`offset -= 32u32` 导致下溢

**修复方案**: 使用直接循环复制
```gcl
for (uint32 i = 0u32; i < bodyLen; i++) {
    body.push(rawData[12u32 + i]);
}
```

### 3. 测试数据错误

**根本原因**: test_receive.gclts 中的 UCP 包数据与 Testdata.md 不一致

**修复方案**: 从 Testdata.md 复制正确的十六进制数据

### 4. 错误检测改进

**问题**: 测试脚本只检查退出码，即使有编译/运行时错误也可能显示"通过"

**修复方案**:
- 检查输出中的错误关键词（compile error, Engine invoke error, ExceptionThrown）
- 检查成功标记（Run script successfully）
- 提供详细的错误信息

## 📝 使用说明

### 运行单个测试

```bash
# 方式 1: 使用测试脚本（推荐）
cd /path/to/diox_contracts/gcl-sample
./script/run_tests.sh basic

# 方式 2: 直接运行 chsimu
cd /path/to/gcl/bin
./chsimu /path/to/diox_contracts/gcl-sample/script/test_basic.gclts -stdout -count:4
```

### 运行所有测试

```bash
cd /path/to/diox_contracts/gcl-sample
./script/run_tests.sh all
```

**预期输出**:
```
======================================
   Diox Contracts GCL 测试套件
======================================

✅ 基础功能 测试通过
✅ 发送消息 测试通过
✅ 接收消息 测试通过
✅ AuthMsg 测试通过
✅ SDPMsg 测试通过
✅ AppContract 测试通过

======================================
测试总结：
  通过：6
  失败：0
======================================

✨ 测试完成！
```

### 查看帮助

```bash
./script/run_tests.sh help
```

## 🎯 测试结果

### 当前状态

- **测试脚本数**: 6
- **测试用例数**: 16
- **通过率**: 100%
- **状态**: ✅ 所有测试通过

### 测试环境

- **GCL Simulator**: chsimu v0.0.1
- **执行引擎**: PREDA_NATIVE
- **测试框架**: gclts
- **路径**: 使用相对路径，支持环境变量配置

## 🔍 技术要点

### 字节序处理

**UCP 包格式** (big-endian):
```
[4 bytes hintsLen (big-endian)]
[hintsLen bytes hints]
[4 bytes proofLen (big-endian)]
[proofLen bytes proof]
```

**TLV 格式** (big-endian 存储，需反转）:
```
[2 bytes tag (big-endian)]
[4 bytes length (big-endian)]
[length bytes value]
```

### 关键发现

1. **Solidity 参考实现**:
   - 使用 `readUint16()` 读取 big-endian
   - 使用 `reverseUint16()` 转换为 little-endian

2. **GCL BytesToTypes 函数**:
   - 向前读取：从 `[offset-N, offset-1]`
   - 不适合直接用于 TLV 解析

3. **正确的实现方式**:
   - 手动读取 big-endian
   - 手动反转字节序

## 📚 相关文档

- [项目分析报告。md](../../../phenix3443/idea/cursor/diox_contract/项目分析报告。md) - 项目现状分析
- [开发测试指南。md](../../../phenix3443/idea/cursor/diox_contract/开发测试指南。md) - 开发和测试指南
- [最终测试报告。md](../../../phenix3443/idea/cursor/diox_contract/最终测试报告。md) - 完整测试报告
- [README.md](../README.md) - GCL 版本说明
- [Testdata.md](../../Testdata.md) - 测试数据说明

## 🐛 故障排除

### 问题 1: 找不到 chsimu

**错误**: `错误：找不到 chsimu`

**解决方案**:
1. 设置环境变量：`export GCL_PATH=/path/to/chsimu`
2. 或将 chsimu 放在默认路径：`$HOME/diox_dev_iobc_989_2511181655/gcl/bin/chsimu`

### 问题 2: 测试失败但显示通过

**原因**: 旧版本脚本只检查退出码

**解决方案**: 已修复，新版本会检查输出中的错误信息

### 问题 3: 路径错误

**原因**: 使用绝对路径

**解决方案**: 已改为相对路径，脚本会自动计算项目根目录

---

**测试脚本创建时间**: 2025-11-05
**最后更新**: 2025-12-12
**状态**: ✅ 所有测试通过（6 个测试脚本，16 个测试用例）
**维护者**: Diox Contracts 开发团队
