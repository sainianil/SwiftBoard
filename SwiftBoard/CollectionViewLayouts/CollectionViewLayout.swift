//
//  CollectionViewLayout.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-09-15.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import UIKit

class CollectionViewLayout: DroppableCollectionViewLayout {
    
    let itemSize = CGFloat(80)
    let heightPadding = CGFloat(20)
    var itemFrames: [CGRect] = []
    var numberOfItems = 0
    var zoomToIndex: Int?
    var overrideSize: CGSize?
    
    func getSize() -> CGSize {
        if let mySize = overrideSize {
            return mySize
        } else if let cv = collectionView {
            return cv.bounds.size
        }
        
        return CGSize.zero
    }
    
    override var collectionViewContentSize: CGSize {
        return getSize()
    }
    
    override func prepare() {
        if collectionView == nil {
            return
        }
        
        let myCollectionView = collectionView!
        let mySize = getSize()
        let availableHeight = mySize.height
        let availableWidth = mySize.width
        var myItemWidth = CGFloat(itemSize)
        
        itemsPerRow = Int(floor(availableWidth / itemSize))
        let floatItems = Float(availableWidth) / Float(itemsPerRow)
        myItemWidth = CGFloat(floor(floatItems))
        
        var top = CGFloat(0)
        var left = CGFloat(0)
        var column = 1
        var zoomedSize = myItemWidth
        var rowOffset = myItemWidth + heightPadding
        var columnOffset = myItemWidth
        
        if zoomToIndex != nil {
            if availableWidth < availableHeight {
                zoomedSize = availableWidth - 10
                rowOffset = zoomedSize + (availableHeight - zoomedSize) / 2 + heightPadding
                columnOffset = zoomedSize
            } else {
                zoomedSize = availableHeight - 10
                rowOffset = zoomedSize
                columnOffset = zoomedSize + (availableWidth - zoomedSize) / 2 + heightPadding
            }
        }

        itemFrames = []
        numberOfItems = myCollectionView.numberOfItems(inSection: 0)
        
        for _ in 0..<numberOfItems {
            let itemFrame = CGRect(x: left, y: top, width: zoomedSize, height: zoomedSize + heightPadding)
            itemFrames.append(itemFrame)
            
            column += 1
            if column > itemsPerRow {
                column = 1
                left = CGFloat(0)
                top += rowOffset
            } else {
                left += columnOffset
            }
        }
        
        if let zoomIndex = zoomToIndex {
            let frame = itemFrames[zoomIndex]
            var transform = CGAffineTransform(translationX: -frame.origin.x, y: -frame.origin.y)
            transform = transform.translatedBy(x: (availableWidth - zoomedSize) / 2, y: (availableHeight - zoomedSize) / 2)
            
            for itemIndex in 0..<numberOfItems {
                itemFrames[itemIndex] = itemFrames[itemIndex].applying(transform)
            }
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attributes: [UICollectionViewLayoutAttributes] = []
        
        if collectionView != nil {
            for itemIndex in 0..<numberOfItems {
                attributes.append(layoutAttributesForItem(at: itemIndex.toIndexPath())!)
            }
        }
        
        return attributes;
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let itemAttributes = UICollectionViewLayoutAttributes(forCellWith: indexPath as IndexPath)
        itemAttributes.frame = itemFrames[indexPath.item]
        
        return itemAttributes
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }    
}
