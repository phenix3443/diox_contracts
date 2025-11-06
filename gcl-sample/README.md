# GCL Sample - 跨链通信协议 GCL 实现

这个目录包含了跨链通信协议的 GCL (通用合约语言) 实现版本。

## 目录结构

```
gcl-sample/
├── README.md                    # 本文件
├── AppContract.gcl             # DApp 层合约
├── SDPMsg.gcl                  # SDP 层合约  
├── AuthMsg.gcl                 # AM 层合约
├── XApp.gclts                  # AppContract 测试脚本
├── XSdp.gclts                  # SDPMsg 测试脚本
├── XAM.gclts                   # AuthMsg 测试脚本
├── interfaces/                 # 接口定义
│   ├── IAuthMessage.gcl
│   ├── IContractUsingSDP.gcl
│   ├── ISDPMessage.gcl
│   └── ISubProtocol.gcl
└── lib/                        # 库文件
    ├── am/
    │   └── AMLib.gcl           # AuthMessage 编解码库
    ├── sdp/
    │   └── SDPLib.gcl          # SDP 消息编解码库
    └── utils/
        ├── BytesToTypes.gcl    # 字节转类型工具
        ├── SizeOf.gcl          # 类型大小计算
        ├── TLVUtils.gcl        # TLV 解析工具
        ├── TypesToBytes.gcl    # 类型转字节工具
        └── Utils.gcl           # 通用工具函数
```

## 合约层次结构

1. **AppContract** (DApp 层)
   - 实现 `IContractUsingSDP.ContractUsingSDPInterface` 接口
   - 提供 `sendMessage` 和 `sendUnorderedMessage` 功能
   - 处理接收到的跨链消息

2. **SDPMsg** (SDP 层)  
   - 实现 `ISDPMessage.SDPMessageInterface` 和 `ISubProtocol.SubProtocolInterface` 接口
   - 负责消息序列化和路由
   - 管理发送序列号

3. **AuthMsg** (AM 层)
   - 实现 `IAuthMessage.AuthMessageInterface` 接口
   - 处理来自 Relayer 的 UCP 包
   - 管理协议路由和认证

## 运行测试

使用 gclts 测试脚本来验证合约功能：

```bash
# 测试 AppContract 完整流程
gclts XApp.gclts

# 测试 SDPMsg 功能
gclts XSdp.gclts  

# 测试 AuthMsg 功能
gclts XAM.gclts
```

## 与 Solidity 版本的对应关系

- `AppContract.gcl` ↔ `ethereum-sample/AppContract.sol`
- `SDPMsg.gcl` ↔ `ethereum-sample/SDPMsg.sol`  
- `AuthMsg.gcl` ↔ `ethereum-sample/AuthMsg.sol`
- `lib/am/AMLib.gcl` ↔ `ethereum-sample/lib/am/AMLib.sol`
- `lib/sdp/SDPLib.gcl` ↔ `ethereum-sample/lib/sdp/SDPLib.sol`

## 主要特性

- ✅ 完整的跨链消息发送和接收流程
- ✅ UCP (Universal Cross-chain Package) 解析
- ✅ TLV (Type-Length-Value) 编码支持
- ✅ 字节序转换 (大端/小端)
- ✅ 合约间接口调用
- ✅ 事件发射和调试输出
- ✅ 完整的测试覆盖

## 开发状态

所有核心功能已实现并通过测试验证。
