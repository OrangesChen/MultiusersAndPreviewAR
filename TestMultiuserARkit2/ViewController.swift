//
//  ViewController.swift
//  TestMultiuserARkit2
//
//  Created by cfq on 2018/6/7.
//  Copyright © 2018 Dlodlo. All rights reserved.
//

import UIKit
import ARKit
import SceneKit
import MultipeerConnectivity

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate{

    // MARK: -IBOutlet
    @IBOutlet weak var sessionLabel: UILabel!
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var sendWorldMap: UIButton!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var addObjectsButton: UIButton!
    
    var currentVirtualObject: SCNReferenceNode!
    
    
    /// The view controller that displays the virtual object selection menu.
    var objectsViewController: VirtualObjectSelectionViewController?
    
    
    // MARK: - View Life Cycle
    var multipeerSession: MultipeerSession!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        multipeerSession = MultipeerSession(receivedDataHandler: receivedData)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // check the device is support ar
        guard ARWorldTrackingConfiguration.isSupported else {
            fatalError("""
                ARKit is not available on this device. For apps that require ARKit
                for core functionality, use the `arkit` key in the key in the
                `UIRequiredDeviceCapabilities` section of the Info.plist to prevent
                the app from installing. (If the app can't be installed, this error
                can't be triggered in a production scenario.)
                In apps where AR is an additive feature, use `isSupported` to
                determine whether to show UI for launching AR experiences.
            """) // For details, see https://developer.apple.com/documentation/arkit
        }
        
        // Start the view's AR session 开始AR会话
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
        
        // Set a delegate to track the number of plane anchors for providing UI feedback
        sceneView.session.delegate = self
        
        sceneView.delegate = self

        // 跟踪反馈平面锚点的数量
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        // prevent the screen from being dimmed after a while as users will likely
        // have long periods of interaction without touching the screen or buttons.
        // 防止屏幕在一段时间内变暗 长时间互动而无需触摸屏幕按钮
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    
    // MARK: - multiuser shared session
    /// -Tag: PlanceCharacter
    @IBAction func handleSceneTap(_ sender: Any) {
        // Hit test to find place for a virtual object
        guard let hitTestResult = sceneView.hitTest((sender as! UITapGestureRecognizer).location(in: sceneView), types: [.existingPlaneUsingGeometry, .estimatedHorizontalPlane]).first
            else{ return }
        // Place an anchor for a virtual character. The model appears in renderer(_:didAdd:for:)
        let anchor = ARAnchor(name: "panda", transform: hitTestResult.worldTransform)
        sceneView.session.add(anchor: anchor)
        
        guard let data = try? NSKeyedArchiver.archivedData(withRootObject: anchor, requiringSecureCoding: true)
            else {  fatalError("cant encoder anchor0")        }
        self.multipeerSession.senfToAllPeers(data)
        
    }
    
    
    // - Tag: GetWorldMap
    @IBAction func sessionMap(_ sender: Any) {
        sceneView.session.getCurrentWorldMap { worldMap, error in
            guard let map = worldMap
                else {
                    print("Error \(error!.localizedDescription)"); return
            }
            guard let data = try? NSKeyedArchiver.archivedData(withRootObject: map, requiringSecureCoding: true)
                else { fatalError("cant encode map")}
            self.multipeerSession.senfToAllPeers(data)
        }
    }
    
    // 重置场景 将场景中添加的所有anchor移除
    @IBAction func Clear(_ sender: UIButton) {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    // MARK: - ARSCNViewDelegate 代理
    /**
     Called when a new node has been mapped to the given anchor.
     ASCNView 添加anchor时执行的函数
     @param renderer： The renderer that will render the scene.
     @param node：The node that maps to the anchor.
     @param anchor：The added anchor.
     */
     public func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor)
    {
        if let name = anchor.name, name.hasPrefix("panda"){
            // 添加虚拟物体模型
            node.addChildNode(loadRedPandaModel())
        }
    }
    
    
    // MARK: - ARSessionDelegate
    // 相机
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        UpdateSessionLabel(for: session.currentFrame!, trackingState: camera.trackingState)
    }
    
    /// -Tag: CheckMappingStatus
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        switch frame.worldMappingStatus {
        case .notAvailable, .limited:
            sendWorldMap.isEnabled = false
        case .extending:
            sendWorldMap.isEnabled = !multipeerSession.connectedPeers.isEmpty
        case .mapped:
            sendWorldMap.isEnabled = !multipeerSession.connectedPeers.isEmpty
        }
        
        statusLabel.text = frame.worldMappingStatus.description
        UpdateSessionLabel(for: frame, trackingState: frame.camera.trackingState)
        
    }
    
   
    // MARK: - ARSessionObserver
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay.
        sessionLabel.text = "Session was interrupted"
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required.
        sessionLabel.text = "Session interruption ended"
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user.
        sessionLabel.text = "Session failed: \(error.localizedDescription)"
//        resetTracking(nil)
    }
    
    func sessionShouldAttemptRelocalization(_ session: ARSession) -> Bool {
        return true
    }
    
    
    // MARK: - AR session management
    private func UpdateSessionLabel(for frame: ARFrame, trackingState: ARCamera.TrackingState) {
        // Update the UI to provide feedback on the state of the AR experience
        let message: String
        switch trackingState {
        case .normal where frame.anchors.isEmpty && multipeerSession.connectedPeers.isEmpty:
            // 未检测到平面
            message = "Move around to map the environment, or wait to join a shared session."
        case .normal where !multipeerSession.connectedPeers.isEmpty && mapProvider == nil:
            let peerName = multipeerSession.connectedPeers.map({$0.displayName}).joined(separator: ", ")
            message = "Connected with \(peerName)"
        case .notAvailable:
            message = "Tracking unavavilable"
        case .limited(.excessiveMotion):
            message = "Tracking limited - Move the device more slowly."
        case .limited(.insufficientFeatures):
            message = "Tracking limited - Point the device at an area with visible surface detail, or improve lighting conditions."
            
        case .limited(.initializing) where mapProvider != nil,
             .limited(.relocalizing) where mapProvider != nil:
            message = "Received map from \(mapProvider!.displayName)."
            
        case .limited(.relocalizing):
            message = "Resuming session — move to where you were when the session was interrupted."
            
        case .limited(.initializing):
            message = "Initializing AR session."
        default:
            message = ""
        }
        sessionLabel.text =  message
    }

    // load panda model
    private func loadRedPandaModel() -> SCNNode {
//        let sceneURL = Bundle.main.url(forResource: "max", withExtension: "scn", subdirectory: "Assets.scnassets")!
//        let referenceNode = SCNReferenceNode(url: sceneURL)!
       
//       let  referenceNode = VirtualObject.availableObjects.first!
        
        if currentVirtualObject == nil {
            currentVirtualObject = VirtualObject.availableObjects.first!
            currentVirtualObject.load()
            return currentVirtualObject
        }
        currentVirtualObject.load()
        return currentVirtualObject
    }
    
    var mapProvider: MCPeerID?
    
    func receivedData(_ data: Data, from peer: MCPeerID) {
        if let unarchived = try? NSKeyedUnarchiver.unarchivedObject(ofClasses: [ARWorldMap.classForKeyedUnarchiver()], from: data),
            let worldMap = unarchived as? ARWorldMap {
            // Run the session with the received world map
            let configuration = ARWorldTrackingConfiguration()
            configuration.planeDetection = .horizontal
            configuration.initialWorldMap = worldMap
            sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
            // Remember who provided the map for showing UI feedback
            mapProvider = peer
        } else {
            if let unarchived = try? NSKeyedUnarchiver.unarchivedObject(ofClasses: [ARAnchor.classForKeyedUnarchiver()], from: data),
                let anchor = unarchived as? ARAnchor {
                sceneView.session.add(anchor: anchor)
            } else {
              print("unknown data recieved from \(peer)")
            }
        }
    }


    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: {})
    }

    @IBAction func showMenuController(_ sender: Any) {
        guard !addObjectsButton.isHidden else { return }
                performSegue(withIdentifier: SegueIdentifier.showObjects.rawValue, sender: addObjectsButton)
    }
}

