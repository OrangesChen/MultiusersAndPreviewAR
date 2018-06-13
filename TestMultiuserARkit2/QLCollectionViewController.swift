//
//  QLCollectionViewController.swift
//  TestMultiuserARkit2
//
//  Created by cfq on 2018/6/11.
//  Copyright © 2018 Dlodlo. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class QLCollectionViewController: UICollectionViewController {
    
    var imgList: [String]!  = {
        let url1 = Bundle.main.path(forResource: "redchair", ofType: "jpg", inDirectory: "usdz")!
        let url2 = Bundle.main.path(forResource: "cupandsaucer", ofType: "jpg", inDirectory: "usdz")!
        let url3 = Bundle.main.path(forResource: "gramophone", ofType: "jpg", inDirectory: "usdz")!
        let url4 = Bundle.main.path(forResource: "plantpot", ofType: "jpg", inDirectory: "usdz")!
        let url5 = Bundle.main.path(forResource: "retrotv", ofType: "jpg", inDirectory: "usdz")!
        let url6 = Bundle.main.path(forResource: "teapot", ofType: "jpg", inDirectory: "usdz")!
        return [url1, url2, url3, url4, url5, url6]
    }()

   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(QLCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
//        self.collectionView = UICollectionView.init(frame: self.view.frame)
        self.collectionView.isScrollEnabled = true
        
        let layout = UICollectionViewFlowLayout.init()
        layout.itemSize = CGSize(width: (self.view.frame.size.width - 40) / 2, height: 150)
        layout.minimumLineSpacing = 10
        layout.sectionInset = UIEdgeInsets.init(top: 10, left: 15, bottom: 10, right: 15)
        
        self.collectionView.collectionViewLayout = layout
//        self.collectionView.backgroundColor = UIColor.red
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return imgList.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! QLCollectionViewCell
    
        let index = indexPath.item
        cell.backgroundColor = UIColor.red
        // Configure the cell
        cell.imgView.image = UIImage(named: imgList![index])
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

   
     //Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let qlViewController = ARViewController()
        qlViewController.pushIndex = indexPath.item
//        self.navigationController?.
        present(qlViewController, animated: false, completion: {})
        return true
    }
   

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
