//
//  VirtualObject.swift
//  TestMultiuserARkit2
//
//  Created by cfq on 2018/6/12.
//  Copyright © 2018 Dlodlo. All rights reserved.
//

import Foundation
import SceneKit
import ARKit


class VirtualObject: SCNReferenceNode {
    /// The model name derived from the `referenceURL`.
    var modelName: String {
        return referenceURL.lastPathComponent.replacingOccurrences(of: ".scn", with: "")
    }
    
    
    var allowedAlignments: [ARPlaneAnchor.Alignment] {
        if modelName == "sticky note" {
            return [.horizontal, .vertical]
        } else if modelName == "painting" {
            return [.vertical]
        } else {
            return [.horizontal]
        }
    }
    
    /// Current alignment of the virtual object
    var currentAlignment: ARPlaneAnchor.Alignment = .horizontal
    
}


extension VirtualObject {
    static var availableObjects: [VirtualObject] = {
        let modelsURL = Bundle.main.url(forResource: "Models.scnassets", withExtension: nil)!
        
        let fileEnumerator = FileManager().enumerator(at: modelsURL, includingPropertiesForKeys: [])!
        
        return fileEnumerator.compactMap { element in
            let url = element as! URL
            
            guard url.pathExtension == "scn" && !url.path.contains("lighting") && !url.path.contains("painting") else { return nil }
            
            return VirtualObject(url: url)
        }
    }()
}
