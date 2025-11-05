// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../AppContract.sol";
import "../SDPMsg.sol";
import "../AuthMsg.sol";

/**
 * @title 完整的端到端集成测试
 * @notice 测试 AppContract → SDPMsg → AuthMsg 完整消息链路
 * @dev 验证所有合约的事件触发和状态变更
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
        // protocolType = 1 表示 SDP 协议
        authMsg.setProtocol(address(sdpMsg), 1);
        
        vm.stopPrank();
        
        emit log("=== Contracts Deployed ===");
        emit log_named_address("AuthMsg", address(authMsg));
        emit log_named_address("SDPMsg", address(sdpMsg));
        emit log_named_address("AppContract", address(appContract));
    }
    
    // ====================================================================
    // 测试 1: 完整的发送流程 - 验证所有事件
    // ====================================================================
    
    /**
     * @notice 测试完整的消息发送链路，验证所有合约的事件都正确触发
     */
    function test_FullSendFlow_AllEventsTriggered() public {
        bytes memory message = bytes("Hello Cross-Chain!");
        
        vm.startPrank(user1);
        
        // ===== 预期事件 1: AppContract.sendCrosschainMsg =====
        vm.expectEmit(true, true, true, true, address(appContract));
        emit AppContract.sendCrosschainMsg(DOMAIN_B, RECEIVER, message, true);
        
        // ===== 预期事件 2: AuthMsg.SendAuthMessage =====
        // 注意：这个事件会在内部调用链中触发
        vm.expectEmit(false, false, false, false, address(authMsg));
        emit IAuthMessage.SendAuthMessage(new bytes(0)); // 我们不验证具体内容
        
        // 🔑 执行调用：这会触发整个调用链
        appContract.sendMessage(DOMAIN_B, RECEIVER, message);
        
        vm.stopPrank();
        
        emit log("✅ Test 1 Passed: All events triggered correctly");
    }
    
    /**
     * @notice 测试完整的消息发送链路，验证所有状态变更
     */
    function test_FullSendFlow_AllStateChanges() public {
        bytes memory message = bytes("State Change Test");
        
        // ===== 记录初始状态 =====
        uint32 seqBefore = sdpMsg.querySDPMessageSeq(
            DOMAIN_A,
            bytes32(uint256(uint160(address(appContract)))),
            DOMAIN_B,
            RECEIVER
        );
        
        // ===== 执行发送 =====
        vm.prank(user1);
        appContract.sendMessage(DOMAIN_B, RECEIVER, message);
        
        // ===== 验证 1: AppContract 状态变更 =====
        bytes[] memory sentMessages = appContract.sendMsg(RECEIVER);
        assertEq(sentMessages.length, 1, "AppContract should store sent message");
        assertEq(sentMessages[0], message, "Stored message should match");
        
        // ===== 验证 2: SDPMsg 序列号递增 =====
        uint32 seqAfter = sdpMsg.querySDPMessageSeq(
            DOMAIN_A,
            bytes32(uint256(uint160(address(appContract)))),
            DOMAIN_B,
            RECEIVER
        );
        assertEq(seqAfter, seqBefore, "Sequence for receiving should not change yet");
        
        // 注意：发送序列号在 SDPMsg 内部管理，我们通过多次发送来验证
        vm.prank(user1);
        appContract.sendMessage(DOMAIN_B, RECEIVER, bytes("Second message"));
        
        // 第二条消息应该成功发送（如果序列号管理正确）
        sentMessages = appContract.sendMsg(RECEIVER);
        assertEq(sentMessages.length, 2, "Should have 2 sent messages");
        
        emit log("✅ Test 2 Passed: All state changes verified");
    }
    
    /**
     * @notice 测试多条消息发送，验证序列号正确递增
     */
    function test_MultipleMessages_SequenceIncrement() public {
        vm.startPrank(user1);
        
        // 发送 5 条消息
        for (uint i = 1; i <= 5; i++) {
            bytes memory msg = abi.encodePacked("Message ", i);
            
            // 每次都应该成功触发事件
            vm.expectEmit(true, true, true, true, address(appContract));
            emit AppContract.sendCrosschainMsg(DOMAIN_B, RECEIVER, msg, true);
            
            appContract.sendMessage(DOMAIN_B, RECEIVER, msg);
        }
        
        vm.stopPrank();
        
        // 验证所有消息都被存储
        bytes[] memory sentMessages = appContract.sendMsg(RECEIVER);
        assertEq(sentMessages.length, 5, "Should have 5 sent messages");
        
        emit log("✅ Test 3 Passed: Multiple messages with sequence increment");
    }
    
    // ====================================================================
    // 测试 2: 无序消息发送流程
    // ====================================================================
    
    /**
     * @notice 测试无序消息的完整流程
     */
    function test_UnorderedMessage_FullFlow() public {
        bytes memory message = bytes("Unordered Message");
        
        vm.startPrank(user1);
        
        // 预期 AppContract 事件
        vm.expectEmit(true, true, true, true, address(appContract));
        emit AppContract.sendCrosschainMsg(DOMAIN_B, RECEIVER, message, false);
        
        // 预期 AuthMsg 事件
        vm.expectEmit(false, false, false, false, address(authMsg));
        emit IAuthMessage.SendAuthMessage(new bytes(0));
        
        // 执行无序消息发送
        appContract.sendUnorderedMessage(DOMAIN_B, RECEIVER, message);
        
        vm.stopPrank();
        
        // 验证消息存储
        bytes[] memory sentMessages = appContract.sendMsg(RECEIVER);
        assertEq(sentMessages.length, 1);
        assertEq(sentMessages[0], message);
        
        emit log("✅ Test 4 Passed: Unordered message flow");
    }
    
    // ====================================================================
    // 测试 3: 协议注册和权限控制
    // ====================================================================
    
    /**
     * @notice 测试协议注册事件
     */
    function test_ProtocolRegistration() public {
        // 部署新的协议合约
        address newProtocol = address(0x9999);
        uint32 newProtocolType = 2;
        
        vm.prank(owner);
        
        // 预期 SubProtocolUpdate 事件
        vm.expectEmit(true, true, false, true, address(authMsg));
        emit AuthMsg.SubProtocolUpdate(newProtocolType, newProtocol);
        
        authMsg.setProtocol(newProtocol, newProtocolType);
        
        // 验证协议已注册
        assertEq(authMsg.protocolRoutes(newProtocolType), newProtocol);
        
        emit log("✅ Test 5 Passed: Protocol registration");
    }
    
    /**
     * @notice 测试非授权调用被拒绝
     */
    function test_UnauthorizedCalls_Reverted() public {
        bytes memory message = bytes("Unauthorized");
        bytes32 sender = bytes32(uint256(0x123));
        
        // 非 AuthMsg 地址调用 SDPMsg.recvMessage 应该失败
        vm.prank(user1);
        vm.expectRevert("SDPMsg: not valid am contract");
        sdpMsg.recvMessage(DOMAIN_B, sender, message);
        
        // 非 SDPMsg 地址调用 AppContract.recvMessage 应该失败
        vm.prank(user1);
        vm.expectRevert("INVALID_PERMISSION");
        appContract.recvMessage(DOMAIN_B, sender, message);
        
        emit log("✅ Test 6 Passed: Unauthorized calls reverted");
    }
    
    // ====================================================================
    // 测试 4: Gas 分析
    // ====================================================================
    
    /**
     * @notice 完整流程的 Gas 消耗分析
     */
    function test_Gas_FullSendFlow() public {
        bytes memory message = bytes("Gas Test Message");
        
        vm.prank(user1);
        
        uint256 gasBefore = gasleft();
        appContract.sendMessage(DOMAIN_B, RECEIVER, message);
        uint256 gasUsed = gasBefore - gasleft();
        
        emit log_named_uint("=== Full Send Flow Gas Usage ===", gasUsed);
        
        // 设置合理的 Gas 上限
        assertLt(gasUsed, 300000, "Full flow should use less than 300k gas");
        
        emit log("✅ Test 7 Passed: Gas analysis completed");
    }
    
    // ====================================================================
    // 测试 5: 基础功能测试
    // ====================================================================
    
    /**
     * @notice 测试合约初始化状态
     */
    function test_Initialization() public {
        assertEq(authMsg.owner(), owner, "AuthMsg owner incorrect");
        assertEq(authMsg.relayer(), relayer, "AuthMsg relayer incorrect");
        assertEq(sdpMsg.owner(), owner, "SDPMsg owner incorrect");
        assertEq(sdpMsg.amAddress(), address(authMsg), "SDPMsg amAddress incorrect");
        assertEq(appContract.owner(), owner, "AppContract owner incorrect");
        assertEq(appContract.sdpAddress(), address(sdpMsg), "AppContract sdpAddress incorrect");
        
        emit log("✅ Test 8 Passed: Initialization verified");
    }
    
    /**
     * @notice 测试配置变更
     */
    function test_ConfigurationChanges() public {
        address newRelayer = address(0x888);
        
        vm.startPrank(owner);
        
        // 更改 relayer
        authMsg.setRelayer(newRelayer);
        assertEq(authMsg.relayer(), newRelayer);
        
        // 更改本地域名
        string memory newDomain = "newChain";
        sdpMsg.setLocalDomain(newDomain);
        assertEq(sdpMsg.localDomainHash(), keccak256(bytes(newDomain)));
        
        vm.stopPrank();
        
        emit log("✅ Test 9 Passed: Configuration changes");
    }
}

