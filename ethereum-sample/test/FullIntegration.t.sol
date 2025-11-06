// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../AppContract.sol";
import "../SDPMsg.sol";
import "../AuthMsg.sol";
import "../interfaces/IAuthMessage.sol";
import "../lib/sdp/SDPLib.sol";
import "../lib/am/AMLib.sol";
import "../lib/utils/TypesToBytes.sol";
import "../lib/utils/Utils.sol";
import "../lib/utils/TLVUtils.sol";

/**
 * @title 完整的端到端集成测试
 * @notice 测试 AppContract 中完整的消息发送和接收流程
 * @dev 验证完整调用链中的所有状态变更和事件触发
 *
 * 调用链说明：
 *
 * 发送流程：
 *   AppContract.sendMessage
 *     -> SDPMsg.sendMessage
 *     -> AuthMsg.recvFromProtocol
 *     -> 触发 AuthMsg.SendAuthMessage 事件
 *
 * 接收流程：
 *   AuthMsg.recvPkgFromRelayer
 *     -> SDPMsg.recvMessage
 *     -> AppContract.recvMessage
 *     -> 触发 AppContract.recvCrosschainMsg 事件
 */
contract FullIntegrationTest is Test {

    // ===== 合约实例 =====
    AppContract public appContract;
    SDPMsg public sdpMsg;
    AuthMsg public authMsg;

    // ===== 测试账户 =====
    address owner = address(0x1);
    address relayer = address(0x2);
    address user1 = address(0x3);
    address user2 = address(0x4);

    // ===== 测试数据 =====
    string constant DOMAIN_A = "chainA";
    string constant DOMAIN_B = "chainB";
    bytes32 constant RECEIVER = bytes32(uint256(0x123456));

    function setUp() public {
        vm.label(owner, "Owner");
        vm.label(relayer, "Relayer");
        vm.label(user1, "User1");
        vm.label(user2, "User2");

        deployAndConfigureContracts();
    }

    /**
     * @dev 部署并配置所有合约
     */
    function deployAndConfigureContracts() internal {
        vm.startPrank(owner);

        // 1. 部署 AuthMsg
        authMsg = new AuthMsg();
        authMsg.init();
        authMsg.setRelayer(relayer);
        vm.label(address(authMsg), "AuthMsg");

        // 2. 部署 SDPMsg
        sdpMsg = new SDPMsg();
        sdpMsg.init();
        sdpMsg.setAmContract(address(authMsg));
        sdpMsg.setLocalDomain(DOMAIN_A);
        vm.label(address(sdpMsg), "SDPMsg");

        // 3. 部署 AppContract
        appContract = new AppContract();
        appContract.setProtocol(address(sdpMsg));
        vm.label(address(appContract), "AppContract");

        // 4. 在 AuthMsg 中注册 SDPMsg 协议
        authMsg.setProtocol(address(sdpMsg), 1);

        vm.stopPrank();

        emit log("=== Contracts Deployed ===");
        emit log_named_address("AuthMsg", address(authMsg));
        emit log_named_address("SDPMsg", address(sdpMsg));
        emit log_named_address("AppContract", address(appContract));
    }

    // ====================================================================
    // 测试 1: 有序消息的完整流程（发送 + 接收）
    // ====================================================================

    /**
     * @notice 测试有序消息的完整跨链通信流程
     * @dev 模拟真实场景：ChainA 发送消息到 ChainB，然后接收来自 ChainB 的响应
     *
     * 发送链路: AppContract.sendMessage -> SDPMsg.sendMessage -> AuthMsg.recvFromProtocol
     * 接收链路: AuthMsg.recvPkgFromRelayer -> SDPMsg.recvMessage -> AppContract.recvMessage
     *
     * 验证：
     * - 发送事件: AppContract.sendCrosschainMsg, IAuthMessage.SendAuthMessage
     * - 接收事件: AuthMsg.recvAuthMessage, SDPMsg.receiveMessage, AppContract.recvCrosschainMsg
     * - 状态变更: sendMsg, last_msg, recvMsg
     */
    function test_OrderedMessage_FullFlow() public {
        // ===== 阶段 1: 发送有序消息 =====
        bytes memory sendMessage = bytes("Request from ChainA");

        vm.prank(user1);

        // 预期发送事件
        vm.expectEmit(true, true, true, true, address(appContract));
        emit AppContract.sendCrosschainMsg(DOMAIN_B, RECEIVER, sendMessage, true);

        vm.expectEmit(false, false, false, false, address(authMsg));
        emit IAuthMessage.SendAuthMessage(bytes(""));

        // 执行发送
        appContract.sendMessage(DOMAIN_B, RECEIVER, sendMessage);

        // 验证发送状态
        bytes[] memory sent = appContract.sendMsg(RECEIVER);
        assertEq(sent.length, 1, "Should have 1 sent message");
        assertEq(sent[0], sendMessage, "Sent message should match");

        // ===== 阶段 2: 接收来自 ChainB 的有序响应 =====
        bytes memory recvMessage = bytes("Response from ChainB");
        bytes32 sender = bytes32(uint256(uint160(user2)));

        // 构造完整的 UCP 包
        bytes memory ucpPackage = _buildUCPPackage(
            DOMAIN_B,              // senderDomain
            sender,                // author
            DOMAIN_A,              // receiveDomain
            address(appContract),  // receiver
            recvMessage,           // message
            0,                     // sequence (ordered)
            true                   // ordered
        );

        // 模拟 relayer 调用
        vm.prank(relayer);

        // 预期接收事件
        vm.expectEmit(false, false, false, false, address(authMsg));
        emit AuthMsg.recvAuthMessage(DOMAIN_B, bytes(""));

        vm.expectEmit(true, true, true, false, address(sdpMsg));
        emit SDPMsg.receiveMessage(DOMAIN_B, sender, address(appContract), 0, true, "");

        vm.expectEmit(true, true, false, false, address(appContract));
        emit AppContract.recvCrosschainMsg(DOMAIN_B, sender, recvMessage, true);

        // 执行接收
        authMsg.recvPkgFromRelayer(ucpPackage);

        // 验证接收状态
        assertEq(appContract.last_msg(), recvMessage, "last_msg should be updated");

        bytes[] memory recv = appContract.recvMsg(sender);
        assertEq(recv.length, 1, "Should have 1 received message");
        assertEq(recv[0], recvMessage, "Received message should match");

        emit log("Test 1 Passed: Ordered message full flow (send + receive)");
    }

    // ====================================================================
    // 测试 2: 无序消息的完整流程（发送 + 接收）
    // ====================================================================

    /**
     * @notice 测试无序消息的完整跨链通信流程
     * @dev 模拟真实场景：ChainA 发送无序消息到 ChainB，然后接收来自 ChainB 的无序响应
     *
     * 发送链路: AppContract.sendUnorderedMessage -> SDPMsg.sendUnorderedMessage -> AuthMsg
     * 接收链路: AuthMsg.recvPkgFromRelayer -> SDPMsg.recvMessage -> AppContract.recvUnorderedMessage
     *
     * 验证：
     * - 发送事件: AppContract.sendCrosschainMsg (ordered=false), IAuthMessage.SendAuthMessage
     * - 接收事件: AuthMsg.recvAuthMessage, SDPMsg.receiveMessage (ordered=false), AppContract.recvCrosschainMsg (ordered=false)
     * - 状态变更: sendMsg, last_msg, recvMsg
     */
    function test_UnorderedMessage_FullFlow() public {
        // ===== 阶段 1: 发送无序消息 =====
        bytes memory sendMessage = bytes("Unordered request from ChainA");

        vm.prank(user1);

        // 预期发送事件
        vm.expectEmit(true, true, true, true, address(appContract));
        emit AppContract.sendCrosschainMsg(DOMAIN_B, RECEIVER, sendMessage, false);

        vm.expectEmit(false, false, false, false, address(authMsg));
        emit IAuthMessage.SendAuthMessage(bytes(""));

        // 执行无序消息发送
        appContract.sendUnorderedMessage(DOMAIN_B, RECEIVER, sendMessage);

        // 验证发送状态
        bytes[] memory sent = appContract.sendMsg(RECEIVER);
        assertEq(sent.length, 1, "Should have 1 sent message");
        assertEq(sent[0], sendMessage, "Sent message should match");

        // ===== 阶段 2: 接收来自 ChainB 的无序响应 =====
        bytes memory recvMessage = bytes("Unordered response from ChainB");
        bytes32 sender = bytes32(uint256(uint160(user2)));

        // 构造无序消息的 UCP 包
        bytes memory ucpPackage = _buildUCPPackage(
            DOMAIN_B,              // senderDomain
            sender,                // author
            DOMAIN_A,              // receiveDomain
            address(appContract),  // receiver
            recvMessage,           // message
            type(uint32).max,      // sequence (unordered)
            false                  // ordered
        );

        // 模拟 relayer 调用
        vm.prank(relayer);

        // 预期接收事件
        vm.expectEmit(false, false, false, false, address(authMsg));
        emit AuthMsg.recvAuthMessage(DOMAIN_B, bytes(""));

        vm.expectEmit(true, true, true, false, address(sdpMsg));
        emit SDPMsg.receiveMessage(DOMAIN_B, sender, address(appContract), type(uint32).max, false, "");

        vm.expectEmit(true, true, false, false, address(appContract));
        emit AppContract.recvCrosschainMsg(DOMAIN_B, sender, recvMessage, false);

        // 执行接收
        authMsg.recvPkgFromRelayer(ucpPackage);

        // 验证接收状态
        assertEq(appContract.last_msg(), recvMessage, "last_msg should be updated");

        bytes[] memory recv = appContract.recvMsg(sender);
        assertEq(recv.length, 1, "Should have 1 received message");
        assertEq(recv[0], recvMessage, "Received message should match");

        emit log("Test 2 Passed: Unordered message full flow (send + receive)");
    }

    // ====================================================================
    // 辅助函数：构造 UCP 包
    // ====================================================================

    /**
     * @dev 构造完整的 UCP 包（MessageFromRelayer）
     * @param senderDomain 发送方域名
     * @param author 发送方地址（编码为 bytes32）
     * @param receiveDomain 接收方域名
     * @param receiver 接收方合约地址
     * @param message 消息内容
     * @param sequence 序列号（type(uint32).max 表示无序）
     * @param ordered 是否有序
     */
    function _buildUCPPackage(
        string memory senderDomain,
        bytes32 author,
        string memory receiveDomain,
        address receiver,
        bytes memory message,
        uint32 sequence,
        bool ordered
    ) internal pure returns (bytes memory) {
        // 1. 构造 SDPMessage
        SDPMessage memory sdpMsg = SDPMessage({
            receiveDomain: receiveDomain,
            receiver: bytes32(uint256(uint160(receiver))),
            message: message,
            sequence: sequence
        });
        bytes memory encodedSDPMsg = SDPLib.encode(sdpMsg);

        // 2. 构造 AuthMessage
        AuthMessage memory authMsg = AuthMessage({
            version: 1,
            author: author,
            protocolType: 1,  // SDP protocol
            body: encodedSDPMsg
        });
        bytes memory encodedAuthMsg = AMLib.encodeAuthMessage(authMsg);

        // 3. 构造 UDAG Response Body (简化版本)
        // Format: [4 bytes status][4 bytes reserved][4 bytes body length][body]
        bytes memory udagResp = new bytes(12 + encodedAuthMsg.length);
        // status = 0 (success)
        TypesToBytes.uint32ToBytes(4, 0, udagResp);
        // reserved = 0
        TypesToBytes.uint32ToBytes(8, 0, udagResp);
        // body length (big endian)
        uint32 bodyLen = uint32(encodedAuthMsg.length);
        udagResp[8] = bytes1(uint8((bodyLen >> 24) & 0xFF));
        udagResp[9] = bytes1(uint8((bodyLen >> 16) & 0xFF));
        udagResp[10] = bytes1(uint8((bodyLen >> 8) & 0xFF));
        udagResp[11] = bytes1(uint8(bodyLen & 0xFF));
        // body
        for (uint i = 0; i < encodedAuthMsg.length; i++) {
            udagResp[12 + i] = encodedAuthMsg[i];
        }

        // 4. 构造 Proof (使用 TLV 编码)
        bytes memory proof = _buildProofTLV(senderDomain, udagResp);

        // 5. 构造 MessageFromRelayer
        // Format: [4 bytes hints length][hints][4 bytes proof length][proof]
        bytes memory hints = new bytes(300);  // 空 hints (300 bytes)

        bytes memory ucpPackage = new bytes(4 + hints.length + 4 + proof.length);
        uint offset = 0;

        // hints length
        TypesToBytes.uint32ToBytes(offset + 4, uint32(hints.length), ucpPackage);
        offset += 4;

        // hints
        for (uint i = 0; i < hints.length; i++) {
            ucpPackage[offset + i] = hints[i];
        }
        offset += hints.length;

        // proof length
        TypesToBytes.uint32ToBytes(offset + 4, uint32(proof.length), ucpPackage);
        offset += 4;

        // proof
        for (uint i = 0; i < proof.length; i++) {
            ucpPackage[offset + i] = proof[i];
        }

        return ucpPackage;
    }

    /**
     * @dev 构造 Proof 的 TLV 编码
     */
    function _buildProofTLV(
        string memory senderDomain,
        bytes memory udagResp
    ) internal pure returns (bytes memory) {
        // TLV Header: [2 bytes type][2 bytes version][2 bytes reserved]
        // TLV Items: [2 bytes tag][4 bytes length][value]

        bytes memory domainBytes = bytes(senderDomain);

        // 计算总长度
        // Header: 6 bytes
        // TLV_PROOF_SENDER_DOMAIN (tag=9): 2+4+domainBytes.length
        // TLV_PROOF_RESPONSE_BODY (tag=5): 2+4+udagResp.length
        uint totalLen = 6 + (2 + 4 + domainBytes.length) + (2 + 4 + udagResp.length);

        bytes memory proof = new bytes(totalLen);
        uint offset = 0;

        // TLV Header
        proof[offset++] = bytes1(uint8(0)); // type high byte
        proof[offset++] = bytes1(uint8(1)); // type low byte (VERSION_SIMPLE_PROOF = 1)
        proof[offset++] = bytes1(uint8(0)); // version high byte
        proof[offset++] = bytes1(uint8(1)); // version low byte
        proof[offset++] = bytes1(uint8(0)); // reserved
        proof[offset++] = bytes1(uint8(0)); // reserved

        // TLV Item: SENDER_DOMAIN (tag = 9)
        proof[offset++] = bytes1(uint8(0));  // tag high byte
        proof[offset++] = bytes1(uint8(9));  // tag low byte (TLV_PROOF_SENDER_DOMAIN)
        TypesToBytes.uint32ToBytes(offset + 4, uint32(domainBytes.length), proof);
        offset += 4;
        for (uint i = 0; i < domainBytes.length; i++) {
            proof[offset++] = domainBytes[i];
        }

        // TLV Item: RESPONSE_BODY (tag = 5)
        proof[offset++] = bytes1(uint8(0));  // tag high byte
        proof[offset++] = bytes1(uint8(5));  // tag low byte (TLV_PROOF_RESPONSE_BODY)
        TypesToBytes.uint32ToBytes(offset + 4, uint32(udagResp.length), proof);
        offset += 4;
        for (uint i = 0; i < udagResp.length; i++) {
            proof[offset++] = udagResp[i];
        }

        return proof;
    }
}
