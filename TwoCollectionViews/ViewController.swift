//
//  ViewController.swift
//  TwoCollectionViews
//
//  Created by gustavo nascimento on 10/28/16.
//  Copyright © 2016 gustavo nascimento. All rights reserved.
//

import UIKit


extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}

extension UIColor {
    static func randomColor() -> UIColor {
        // If you wanted a random alpha, just create another
        // random number for that too.
        return UIColor(red:   .random(),
                       green: .random(),
                       blue:  .random(),
                       alpha: 1.0)
    }
}

class ViewController: UIViewController, UICollectionViewDataSource {
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        let screenSize = UIScreen.main.bounds
        
        let bottomVCLayout = CenterCellCollectionViewFlowLayout()
        bottomVCLayout.itemSize = CGSize(width: screenSize.width, height: screenSize.height)
        bottomVCLayout.minimumInteritemSpacing = 0.0
        bottomVCLayout.minimumLineSpacing = 0.0
        bottomVCLayout.scrollDirection = .horizontal
        
        let bottomVC = UICollectionView(frame: .zero, collectionViewLayout: bottomVCLayout)
        bottomVC.backgroundColor = .yellow
        bottomVC.dataSource = self
        bottomVC.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        bottomVC.tag = 101
        
        let topVCLayout = CenterCellCollectionViewFlowLayout()
        let iconHeight = 50
        topVCLayout.itemSize = CGSize(width: iconHeight, height: iconHeight)
        topVCLayout.minimumLineSpacing = 70.0
        topVCLayout.scrollDirection = .horizontal
        let topVC = UICollectionView(frame: .zero, collectionViewLayout: topVCLayout)
        topVC.backgroundColor = .green
        topVC.dataSource = self
        
        topVC.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        
        
        let twoVC = TwoCollectionsViews(topCollectionView: topVC, bottomCollectionView: bottomVC)
        twoVC.view.backgroundColor = .purple
        

        addChildViewController(twoVC)
        view.addSubview(twoVC.view)
        
        // Necessary to declare type explicitely, see http://stackoverflow.com/questions/39520534/autolayout-issue-xcode-8-swiftvalue-nsli-superitem
        let viewDic: [String: UIView] = ["vcView": twoVC.view]
        twoVC.view.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[vcView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewDic))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[vcView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewDic))
        
        twoVC.didMove(toParentViewController: self)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.backgroundColor = .red
        if collectionView.tag == 101 {
            cell.backgroundColor = UIColor.randomColor()
        }
        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


