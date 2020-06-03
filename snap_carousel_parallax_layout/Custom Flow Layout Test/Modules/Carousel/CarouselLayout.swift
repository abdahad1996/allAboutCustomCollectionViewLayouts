//
//  CarouselLayout.swift
//  Custom Flow Layout Test
//
//  Created by Michał Kwiecień on 07/05/2018.
//  Copyright © 2018 Kwiecien.co. All rights reserved.
//

import UIKit

class CarouselFlowLayout: UICollectionViewFlowLayout {
    
    private var firstSetupDone = false
    private let smallItemScale: CGFloat = 0.5
    private let smallItemAlpha: CGFloat = 0.2
    
    override func prepare() {
        super.prepare()
        print("scrolling and calling prepare")
        if !firstSetupDone {
            setup()
            firstSetupDone = true
        }
    }
    
    private func setup() {
        scrollDirection = .horizontal
        minimumLineSpacing = -60
        itemSize = CGSize(width: collectionView!.bounds.width + minimumLineSpacing, height: collectionView!.bounds.height / 2)
        
        let inset = (collectionView!.bounds.width - itemSize.width) / 2
        collectionView!.contentInset = .init(top: 0, left: inset, bottom: 0, right: inset)
        collectionView?.backgroundColor = .red
    }
    //This tells the UICollectionView that every time the user scrolls it, it should ask its layout class what items should look like
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    // //for that first we find the distance between offset and cells center and subtract it from collectionview center to get a dynamic value which will be changing as we are proceeding but it cannot be bigger then cell width
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        //Returns the layout attributes for all of the cells and views in the specified rectangle.
        guard let allAttributes = super.layoutAttributesForElements(in: rect) else { return nil }
//        print("ALL ATTTRIBUTES",allAttributes)
        for attributes in allAttributes {
//            Step 1: Find the Distance between Center of Cell and The CollectionView Center
            
            let collectionCenter = collectionView!.bounds.size.width / 2
            print(" collectionCenter",collectionCenter)
            let offset = collectionView!.contentOffset.x
            print(" collection horizontal offset ",offset)
            print(" attributes   ",attributes.center.x)
            //normalized center gives us the distance bewteen offset and cells center
            let normalizedCenter = attributes.center.x - offset
            print(" normalizedCenter   ",normalizedCenter)
            //total width of a cell and its spacings
            let maxDistance = itemSize.width + minimumLineSpacing
            print(" maxDistance   ",maxDistance)
//            Step 2: If the distance is greater or equal to the cell width , then take cell width
            let distanceFromCenter = min(collectionCenter - normalizedCenter, maxDistance)
            print(" distanceFromCenter   ",distanceFromCenter)

//            Step 3: Find ratio
            let ratio = (maxDistance - abs(distanceFromCenter)) / maxDistance
            print(" ratio   ",ratio)

            //Step 4: Find alpha and scale Value
//            ratio = 0 , alpha = 0.2, scale 0.5
//            ratio =0.5 , alpha = 0.6, scale 0.75
//            ratio =1 , alpha = 1, scale 1
//            ratio =-1.0 ,alpha = -0.61 , scale= 0.0

             
             let alpha = ratio * (1 - smallItemAlpha) + smallItemAlpha
            let scale = ratio * (1 - smallItemScale) + smallItemScale
            attributes.alpha = alpha
            print(" alpha   ",alpha)
            print(" scale   ",scale)
            print("///////////")
            let angleToSet = distanceFromCenter / (collectionView!.bounds.width / 2)
            var transform = CATransform3DScale(CATransform3DIdentity, scale, scale, 1)
            transform.m34 = 1.0 / 400
            transform = CATransform3DRotate(transform, angleToSet, 0, 1, 0)
            attributes.transform3D = transform
        }
        return allAttributes
    }
    
    //for snapping
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        
        let layoutAttributes = layoutAttributesForElements(in: collectionView!.bounds)
        
        let centerOffset = collectionView!.bounds.size.width / 2
        let offsetWithCenter = proposedContentOffset.x + centerOffset
        
        let closestAttribute = layoutAttributes!
            .sorted { abs($0.center.x - offsetWithCenter) < abs($1.center.x - offsetWithCenter) }
            .first ?? UICollectionViewLayoutAttributes()
        
        return CGPoint(x: closestAttribute.center.x - centerOffset, y: 0)
    }
}
