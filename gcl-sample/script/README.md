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