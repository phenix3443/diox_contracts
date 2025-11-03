# 【开放链课题一 + 三】Dioxide链-gcl合约开发进度对齐

## 文件夹内容说明

***ethereum-sample***：是课题三开发的部署在以太坊的solidity合约，**Dioxide的gcl合约逻辑完全基于ethereum-sample中的合约逻辑开发**。如果遇到确实难以实现的逻辑可以变通，具体在**【开发注意事项】**中有说明，也可以随时交流。



## 合约介绍

- 下图展示了①需开发的合约核心结构模板，②ethereum-sample文件夹中的合约结构。简单来说，需要实现AM与SDP两个合约，其余都是支撑这两个合约运作的接口和库。
- 更详细的接口解释可以参考github链接：[区块链桥接组件开发手册 V0 · AntChainOpenLabs/AntChainBridge Wiki](https://github.com/AntChainOpenLabs/AntChainBridge/wiki/区块链桥接组件开发手册-V0)

<img src="C:\Users\saraday\AppData\Roaming\Typora\typora-user-images\image-20251103143938101.png" alt="image-20251103143938101" style="zoom: 50%;" />

<img src="C:\Users\saraday\AppData\Roaming\Typora\typora-user-images\image-20251103144120071.png" alt="image-20251103144120071" style="zoom: 50%;" />





## gcl合约开发进度对齐

|           SDP合约功能            |                 对应接口                  | 开发进度 |                    说明                    |
| :------------------------------: | :---------------------------------------: | :------: | :----------------------------------------: |
|            初始化过程            |      setAmContract、setLocalDomain等      |   100%   |                     /                      |
|   接收DAPP消息，并转发给AM合约   |     sendMessage、sendUnorderedMessage     | **80%**  |  已完成序列化部分，剩具体的跨合约方法调用  |
| 接收AM合约消息，并转发给DAPP合约 | recvMessage（其中有序和无序消息分别处理） | **60%**  | 已完成反序列化部分，剩具体的跨合约方法调用 |


|                 AM合约功能                 |         对应接口          | 开发进度 |                             说明                             |
| :----------------------------------------: | :-----------------------: | :------: | :----------------------------------------------------------: |
|                 初始化过程                 | setRelayer、setProtocol等 |   100%   |                              /                               |
| 接收SDP消息，并抛出事件（relay@external）  |     recvFromProtocol      | **80%**  |              已完成序列化部分，剩小部分内容补充              |
| 接收链下中继发送的消息ucp，并转发给SDP合约 |    recvPkgFromRelayer     | **20%**  | ①ucp --> 字节形式的AM消息的反序列化（未完成，开发重点）<br />②字节形式的AM消息 --> 结构化的AM消息（已完成） <br />③具体的跨合约方法调用（未完成） |

|       DAPP合约功能        |             对应接口              | 开发进度 |                           说明                            |
| :-----------------------: | :-------------------------------: | :------: | :-------------------------------------------------------: |
| 简单测试SDP和AM功能正确性 | 能调用和接收SDP合约相关消息的接口 | **80%**  | 接口定义参考IContractUsingSDP.sol，已给出代码（尚未调试） |





## 开发注意事项

- 由于gclts只能测试@address的方法，所以为了测试简便，部分变量和方法从@global改成了@address。目前对最终版合约的设想是：
  - 变量全部使用@global
  - 合约方法
    - 只会被其他合约调用的方法用@global
    - 被外部账户调用的方法就用@address
- 因为Dioxide上没有`bytes`类型，以及`string`类型只能用于拼接字符串，所以solidity中的`string`和`bytes`在gcl合约开发中全部用`array<uint8>`代替
- 跨合约调用中，使用`address`类型来完成访问控制，例如`debug.assert(transaction.get_sender() == amAddress)`；用`uint64`类型的合约`cid`来完成其他合约方法的调用。
- 不需要实现SDPV2的消息，参考solidity代码时忽略掉这一部分即可。
- 除XDAPP.gclts外，仓库中的gclts文件都是能够跑通的，可以看情况继续使用。

