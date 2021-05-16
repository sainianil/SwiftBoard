//
//  FolderCollectionViewLayout.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-09-22.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import UIKit

class FolderCollectionViewLayout: DroppableCollectionViewLayout {

    var itemFrames: [CGRect] = []
    var previousItemFrames: [CGRect] = []
    var numberOfItems = 0
    var updating = false
    
    override var collectionViewContentSize: CGSize {
        if let myCollectionView = collectionView {
            return myCollectionView.bounds.size
        } else {
            return CGSize.zero
        }
    }
    
    override func prepare() {
        if collectionView == nil {
            return
        }
        
        previousItemFrames = itemFrames
        itemsPerRow = 3
        
        let myCollectionView = collectionView!
        numberOfItems = myCollectionView.numberOfItems(inSection: 0)
        
        let itemsToLayout = numberOfItems > 9 ? 9 : numberOfItems
        let availableWidth = myCollectionView.bounds.width
        let itemSize = ceil(availableWidth / 3)
        
        itemFrames = []
        
        for i in 0..<itemsToLayout {
            let row = CGFloat(i / 3)
            let column = CGFloat(i % 3)
            
            let rect = CGRect(x: column*itemSize, y: row*itemSize, width: itemSize, height: itemSize)
            itemFrames.append(rect)
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attributes: [UICollectionViewLayoutAttributes] = []
        
        if collectionView != nil {
            for itemIndex in 0..<numberOfItems {
                attributes.append(layoutAttributesForItem(at: itemIndex.toIndexPath()) ?? UICollectionViewLayoutAttributes())
            }
        }
        
        return attributes;
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let itemAttributes = UICollectionViewLayoutAttributes(forCellWith: indexPath as IndexPath)
        
        if indexPath.item < 9 {
            itemAttributes.frame = itemFrames[indexPath.item]
        } else {
            itemAttributes.isHidden = true
        }
        
        return itemAttributes
    }
    
    // Set a flag to indicate we're adding/removing items. The initial/final layout attribute methods need to use
    // the default behaviour in this case... and has special code for animating a bounds change.
    override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
        updating = true
    }
    
    override func finalizeCollectionViewUpdates() {
        updating = false
    }
    
    override func initialLayoutAttributesForAppearingItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if (updating) {
            return super.initialLayoutAttributesForAppearingItem(at: indexPath as IndexPath)
        } else {
            // When the bounds change, all items are "removed" from view then re-"added" if they're still visible. Provide their
            // original frame so the change will be animated.
            let itemAttributes = UICollectionViewLayoutAttributes(forCellWith: indexPath as IndexPath)
            
            if indexPath.item < 9 {
                itemAttributes.frame = previousItemFrames[indexPath.item]
            } else {
                itemAttributes.isHidden = true
            }
            
            return itemAttributes
        }
    }
    
    override func finalLayoutAttributesForDisappearingItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if (updating) {
            return super.finalLayoutAttributesForDisappearingItem(at: indexPath as IndexPath)
        } else {
            return nil
        }
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}
