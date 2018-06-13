//
//  QLCollectionViewCell.swift
//  TestMultiuserARkit2
//
//  Created by cfq on 2018/6/11.
//  Copyright © 2018 Dlodlo. All rights reserved.
//

import UIKit

class QLCollectionViewCell: UICollectionViewCell {
    
    var imgView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        imgView = UIImageView.init(frame: CGRect.init(origin: CGPoint.init(x: 0, y: 0), size: self.frame.size))
        imgView.isUserInteractionEnabled = true
        self.contentView.addSubview(imgView)
    }
    
    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
    }
    
}
