//
//  ARViewController.swift
//  TestMultiuserARkit2
//
//  Created by cfq on 2018/6/11.
//  Copyright © 2018 Dlodlo. All rights reserved.
//

import UIKit
import QuickLook

class ARViewController: QLPreviewController, QLPreviewControllerDataSource, QLPreviewControllerDelegate {

    
    var pushIndex: Int!
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

        self.delegate = self
        self.dataSource = self
        // Do any additional setup after loading the view.
    }
    

    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
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
//    public func previewController(_ controller: QLPreviewController, transitionViewFor item: QLPreviewItem) -> UIView? {
//        return self.view
//    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
