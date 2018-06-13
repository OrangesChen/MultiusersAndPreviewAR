////
////  MutipeerSeesion.swift
////  TestMultiuserARkit2
////
////  Created by cfq on 2018/6/7.
////  Copyright © 2018 Dlodlo. All rights reserved.
////
///*
// MultipeerConnectivity API use 点对点连接，可以通过同一WiFi、蓝牙来近距离传输数据, 互相链接结点可以安全的传递消息、流或是其他文件资源
// */
//
import MultipeerConnectivity

/// -Tag: MutipeerSession
class MultipeerSession: NSObject {

    static let serviceType = "ar-multi-sample"
    // MCPeerID: 表示一个用户 设备名称
    private let myPeerID = MCPeerID(displayName: UIDevice.current.name)
    // MCSession: 启用和管理MultiPeer连接会话中的所有人之间的沟通，通过seesion发送数据
    private var session: MCSession!
    // MCNearbyServiceAdvertiser: 可以接收，并处理用户请求连接的响应，这个类会有回调，告知有用户要与你的设备连接，可以自定义提示框以及自定义连接处理
    private var serviceAdvertiser: MCNearbyServiceAdvertiser!
    // MCNearbyServiceBrowser: 用于搜索附近用户，并可以对搜索到的附近用户发出邀请加入某个会话中
    private var serviceBrowser: MCNearbyServiceBrowser!

    private let receivedDataHandler: (Data, MCPeerID)->Void

    /// -Tag: MultipeerSetup
    // @escaping: 逃逸闭包（swift3.0之后，闭包默认是非逃逸的，如果一个函数参数可能导致引用循环，那么需要被显示地标记出来。@escaping标记可以作为一个警告，来提醒开发者注意引用关系），表明这个闭包会“逃逸”，通俗一点说就是这个闭包在函数执行完成之后才会被调用
    init(receivedDataHandler: @escaping (Data, MCPeerID) -> Void) {
        self.receivedDataHandler = receivedDataHandler
        super.init()

        // 建立连接 设置代理
        session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .required)
        session.delegate = self

        // 设置广播服务（发送方）
        serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: MultipeerSession.serviceType)
        serviceAdvertiser.delegate = self
        // 开始广播
        serviceAdvertiser.startAdvertisingPeer()

        // 设置发现服务（接收方）
        serviceBrowser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: MultipeerSession.serviceType)
        serviceBrowser.delegate = self
        serviceBrowser.startBrowsingForPeers()
    }
    
    // 发送数据
    func senfToAllPeers(_ data: Data) {
        do {
            try session.send(data, toPeers: session.connectedPeers, with: .reliable)
        }catch {
            print("error sending data to peers: \(error.localizedDescription)")
        }
    }
    
    var connectedPeers: [MCPeerID] {
        return session.connectedPeers
    }
}


extension MultipeerSession: MCSessionDelegate {
    /**
     *  当检测到连接状态发生改变后进行存储
     *
     *  @param session MC流
     *  @param peerID  用户
     *  @param state   连接状态
     */
    @available(iOS 7.0, *)
    public func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState)
    {
        // not used
    }
    
    // Received data from remote peer.
    /**
     *  接收到消息
     *
     *  @param session MC流
     *  @param data    传入的二进制数据
     *  @param peerID  用户
     */
    @available(iOS 7.0, *)
    public func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID)
    {
        receivedDataHandler(data, peerID)
    }
    
    // Received a byte stream from remote peer.
    /**
     *  接收数据流
     *
     *  @param session    MC流
     *  @param stream     数据流
     *  @param streamName 数据流名称（标示）
     *  @param peerID     用户
     */
    @available(iOS 7.0, *)
    public func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID)
    {
        fatalError("This service does not send/receive streams")
    }
    
    // Start receiving a resource from remote peer.
    /**
     *  开始接收资源
     */
    @available(iOS 7.0, *)
    public func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress)
    {
        
    }
    
    // Finished receiving a resource from remote peer and saved the content
    // in a temporary location - the app is responsible for moving the file
    // to a permanent location within its sandbox.
    /**
     *  资源接收结束
     */
    @available(iOS 7.0, *)
    public func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?)
    {
        
    }
}


extension MultipeerSession: MCNearbyServiceAdvertiserDelegate {
    /// Tag: AcceptInvite 接收到的邀请
    /**
     *  发现附近用户
     *
     *  @param advertiser 接收邀请的advertiser
     *  @param peerID     从哪个peerID过来的邀请
     *  @param context    用来表示接收邀请的时候，接收的contex
     *  @param invitationHandler   回调
     */
   public func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void)
   {
        // Call handler to accept invitation and join the session
        invitationHandler(true, self.session)
    }

}

extension MultipeerSession: MCNearbyServiceBrowserDelegate {
    /// Tag: FoundPeer
    /**
     *  发现附近用户
     *
     *  @param browser 搜索附近用户
     *  @param peerID  附近用户
     *  @param info    详情
     */
     public func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?)
     {
        // invite the new peer to the session
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 10)
    }
    
    // A nearby peer has stopped advertising.
    /**
     *  附近某个用户消失了
     *
     *  @param browser 搜索附近用户
     *  @param peerID  用户
     */
    @available(iOS 7.0, *)
    public func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID)
    {
        // This app doesn't do anything with non-invited peers, so there's nothing to do here.
    }
    
}

