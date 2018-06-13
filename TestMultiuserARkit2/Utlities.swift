//
//  Utlities.swift
//  TestMultiuserARkit2
//
//  Created by cfq on 2018/6/8.
//  Copyright © 2018 Dlodlo. All rights reserved.
//

import Foundation
import simd
import ARKit

/**
     A value describing the world mapping status for the area visible in a given frame.
     描述给定帧中可见区域的世界映射状态的值
*/
extension ARFrame.WorldMappingStatus: CustomStringConvertible {
    public var description: String {
        switch self {
            /** World mapping is not available. 世界映射不可用 */
        case .notAvailable:
            return "Not Available"
            /** World mapping is available but has limited features.
             For the device's current position, the session’s world map is not recommended for relocalization.
             世界映射当前可用，但功能有限，对于设备当前位置，不建议会话的世界映射用于重定位
             */
        case .limited:
            return "Limited"
            /** World mapping is actively extending the map with the user's motion.
             The world map will be relocalizable for previously visited areas but is still being updated for the current space.
             World mapping 正在积极地利用用户的动作来扩展地图，可以重新定位以前访问过的地区，但仍在更新当前空间
             */
        case .extending:
            return "Extending"
            /** World mapping has adequately mapped the visible area.
             The map can be used to relocalize for the device's current position.
             World mapping 充分映射了可见光区域，该地图可用于重新定位该设备当前的位置
             */
        case .mapped:
            return "Mapped"
        }
    }
    
}

extension float4x4 {

    var translation: float3 {
        return float3(columns.3.x, columns.3.y, columns.3.z)
    }
    
    init(translation vector: float3) {
        self.init(float4(1, 0, 0, 0),
                  float4(0, 1, 0, 0),
                  float4(0, 0, 1, 0),
                  float4(vector.x, vector.y, vector.z, 1))
    }
}

extension float4 {
    var xyz : float3 {
        return float3(x, y, z)
    }
    
}
