//
//  TwoCollectionViewsController.swift
//  TwoCollectionViews
//
//  Created by gustavo nascimento on 11/1/16.
//  Copyright © 2016 gustavo nascimento. All rights reserved.
//

import UIKit


class TwoCollectionsViews: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var topCollectionView: UICollectionView!
    var bottomCollectionView: UICollectionView!
    
    var topDataSource: UICollectionViewDataSource!
    var bottomDataSource: UICollectionViewDataSource!
    var firstLaunch = true
    
    
    init(topCollectionView: UICollectionView, bottomCollectionView: UICollectionView) {
        self.topCollectionView = topCollectionView
        self.topCollectionView.translatesAutoresizingMaskIntoConstraints = false
        self.bottomCollectionView = bottomCollectionView
        self.bottomCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        self.topDataSource = topCollectionView.dataSource!
        self.bottomDataSource = bottomCollectionView.dataSource!
        
        super.init(nibName: nil, bundle: nil)
    }
    
    var originalContentInset = UIEdgeInsets.zero
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        
        // center first cell
        var topInsets = self.topCollectionView.contentInset
        let topValue = (self.view.frame.size.width - (self.topCollectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize.width) * 0.5
        topInsets.left = topValue
        topInsets.right = topValue
        self.topCollectionView.contentInset = topInsets
        self.topCollectionView.decelerationRate = UIScrollViewDecelerationRateFast
        
        
        originalContentInset = topInsets
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        bottomCollectionView.dataSource = self
        topCollectionView.dataSource = self
        
        bottomCollectionView.delegate = self
        topCollectionView.delegate = self
        
        setupViews()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        firstLaunch = false
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == topCollectionView {
            return topDataSource.collectionView(topCollectionView, numberOfItemsInSection: section)
        } else {
            return bottomDataSource.collectionView(bottomCollectionView, numberOfItemsInSection: section)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == topCollectionView {
            return topDataSource.collectionView(topCollectionView, cellForItemAt: indexPath)
        } else {
            return bottomDataSource.collectionView(bottomCollectionView, cellForItemAt: indexPath)
        }
    }
    
    
    func setupViews() {
        let viewDic: [String: UIView] = [
            "topCollectionView": topCollectionView,
            "bottomCollectionView": bottomCollectionView
        ]
        
        view.addSubview(topCollectionView)
        view.addSubview(bottomCollectionView)
        
        
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[topCollectionView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewDic))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[bottomCollectionView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewDic))
        
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[topCollectionView(80)][bottomCollectionView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewDic))
    }
    
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if firstLaunch {
            return
        }
        let bottomCollectionViewFlowLayout = bottomCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let topCollectionViewFlowLayout = topCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        
        let bottomDistanceBetweenItemsCenter = bottomCollectionViewFlowLayout.minimumLineSpacing + bottomCollectionViewFlowLayout.itemSize.width
        let topDistanceBetweenItemsCenter = topCollectionViewFlowLayout.minimumLineSpacing + topCollectionViewFlowLayout.itemSize.width
        let offsetFactor = bottomDistanceBetweenItemsCenter / topDistanceBetweenItemsCenter
        
        if (scrollView == bottomCollectionView) {
            
            let xOffset = scrollView.contentOffset.x - scrollView.frame.origin.x
            let v: CGFloat =  (xOffset / offsetFactor)
            
            
            // to prevent multiple calls
            let scrollViewDelegate = topCollectionView.delegate
            topCollectionView.delegate = nil
            topCollectionView.contentOffset.x = -originalContentInset.left + v
            topCollectionView.delegate = scrollViewDelegate
            
        }
        else if (scrollView == topCollectionView) {
            
            // the first cell has a padding of "originalContentInset.left" because it is centered, we have to take this into consideration.
            let xOffset = scrollView.contentOffset.x + originalContentInset.left - scrollView.frame.origin.x
            
            
            // to prevent multiple calls
            let scrollViewDelegate = bottomCollectionView.delegate
            bottomCollectionView.delegate = nil
            
            let v = (xOffset) * offsetFactor
            bottomCollectionView.contentOffset.x =  v  //xOffset * offsetFactor
            bottomCollectionView.delegate = scrollViewDelegate
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

class CenterCellCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        
        if let cv = self.collectionView {
            
            let cvBounds = cv.bounds
            let halfWidth = cvBounds.size.width * 0.5;
            let proposedContentOffsetCenterX = proposedContentOffset.x + halfWidth;
            
            
            
            if let attributesForVisibleCells = self.layoutAttributesForElements(in: cvBounds) {
                
                var candidateAttributes : UICollectionViewLayoutAttributes?
                for attributes in attributesForVisibleCells {
                    
                    // == Skip comparison with non-cell items (headers and footers) == //
                    if attributes.representedElementCategory != UICollectionElementCategory.cell {
                        continue
                    }
                    
                    if let candAttrs = candidateAttributes {
                        
                        let a = attributes.center.x - proposedContentOffsetCenterX
                        let b = candAttrs.center.x - proposedContentOffsetCenterX
                        
                        if fabsf(Float(a)) < fabsf(Float(b)) {
                            candidateAttributes = attributes;
                        }
                        
                    }
                    else { // == First time in the loop == //
                        
                        candidateAttributes = attributes;
                        continue;
                    }
                    
                    
                }
                
                return CGPoint(x: round(candidateAttributes!.center.x - halfWidth), y: proposedContentOffset.y)
                
            }
            
        }
        
        // Fallback
        return super.targetContentOffset(forProposedContentOffset: proposedContentOffset)
    }
    
}
