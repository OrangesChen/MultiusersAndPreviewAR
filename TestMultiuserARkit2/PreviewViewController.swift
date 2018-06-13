//
//  PreviewViewController.swift
//  TestMultiuserARkit2
//
//  Created by cfq on 2018/6/8.
//  Copyright © 2018 Dlodlo. All rights reserved.
//

import UIKit
import QuickLook


class PreviewViewController: UIViewController, QLPreviewControllerDelegate, QLPreviewControllerDataSource{
    
    let pviewController = QLPreviewController()
    var pushIndex: Int!
    
    @IBOutlet weak var QLView: UIView!
    var urlList: [URL]!  = {
        let url1 = Bundle.main.url(forResource: "redchair", withExtension: "usdz", subdirectory: "usdz")!
        let url2 = Bundle.main.url(forResource: "cupandsaucer", withExtension: "usdz", subdirectory: "usdz")!
        let url3 = Bundle.main.url(forResource: "gramophone", withExtension: "usdz", subdirectory: "usdz")!
        let url4 = Bundle.main.url(forResource: "plantpot", withExtension: "usdz", subdirectory: "usdz")!
        let url5 = Bundle.main.url(forResource: "retrotv", withExtension: "usdz", subdirectory: "usdz")!
        let url6 = Bundle.main.url(forResource: "teapot", withExtension: "usdz", subdirectory: "usdz")!
        return [url1 , url2, url3, url4, url5, url6]
    }()

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        pviewController.dataSource = self
        pviewController.delegate = self
        pviewController.view.frame = self.view.frame
        self.view.addSubview(pviewController.view)
//        present(pviewController, animated: true, completion: {})
        
//        self.navigationController?.present(pviewController, animated: true, completion: {})
    }
    
    
  
    
    // MARK: - QLPreviewControllerDataSource
    public func numberOfPreviewItems(in controller: QLPreviewController) -> Int
    {
        return 1;
    }
    
    
    /*!
     * @abstract Returns the item that the preview controller should preview.
     * @param panel The Preview Controller.
     * @param index The index of the item to preview.
     * @result An item conforming to the QLPreviewItem protocol.
     */
  
    public func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        
        print("index: \(index)")
        return urlList[pushIndex!] as QLPreviewItem
    }

 
    /*!
     * @abstract Invoked when the preview controller is about to be presented full screen or dismissed from full screen, to provide a smooth transition when zooming.
     * @discussion  Return the view that will crossfade with the preview.
     */
//    @available(iOS 10.0, *)
     public func previewController(_ controller: QLPreviewController, transitionViewFor item: QLPreviewItem) -> UIView? {
        return self.view
    }

}
