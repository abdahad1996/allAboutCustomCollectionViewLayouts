//
//  SnappingFlowLayout.swift
//  Custom Flow Layout Test
//
//  Created by Michał Kwiecień on 07/05/2018.
//  Copyright © 2018 Kwiecien.co. All rights reserved.
//

import UIKit

class SnappingFlowLayout: UICollectionViewFlowLayout {
    
    private var firstSetupDone = false
    
    override func prepare() {
        super.prepare()
        print("PREPARING")
        if !firstSetupDone {
            setup()
            firstSetupDone = true
        }
    }
    
    private func setup() {
        scrollDirection = .vertical
        minimumLineSpacing = 20
        itemSize = CGSize(width: collectionView!.bounds.width, height: 350)
        collectionView!.decelerationRate = UIScrollViewDecelerationRateFast
    }
    
    //we basically check if the vertical offset from center of collectionview is nearer to which 2 cell's center.y . offset we get from forProposedContentOffset and we add it to collectionview center to get vertical offset from center of collectionview . we then subtract cells center.y from it and check which cell at indexpath is closer and we basically snap to the cell at that indexpath 
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {

        let layoutAttributes = layoutAttributesForElements(in: collectionView!.bounds)
        print("collectionView bounds ",collectionView!.bounds)
        print("layout attributes",layoutAttributes)
        let centerOffset = collectionView!.bounds.size.height / 2
        print("collectionView center ",centerOffset)
        print("proposedContentOffset  ",proposedContentOffset)
        let offsetWithCenter = proposedContentOffset.y + centerOffset
        print("offsetWithCenter  ",offsetWithCenter)
        let closestAttribute = layoutAttributes!
            .sorted { abs($0.center.y - offsetWithCenter) < abs($1.center.y - offsetWithCenter) }
            .first ?? UICollectionViewLayoutAttributes()
        print("closestAttribute center y  ",closestAttribute.center.y)
        print("closestAttribute  ",closestAttribute)
        let target = CGPoint(x: 0, y: closestAttribute.center.y - centerOffset)
        print("target",target)
        
        return CGPoint(x: 0, y: closestAttribute.center.y - centerOffset)
    }
}
