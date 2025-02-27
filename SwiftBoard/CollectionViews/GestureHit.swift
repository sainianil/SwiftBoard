//
//  GestureHit.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-11-24.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import Foundation

protocol GestureHit {}

class CollectionViewGestureHit: GestureHit {
    let collectionView: ListViewModelCollectionView
    let locationInCollectionView: CGPoint
    
    init(collectionView initCollectionView: ListViewModelCollectionView, locationInCollectionView initViewLocation: CGPoint) {
        collectionView = initCollectionView
        locationInCollectionView = initViewLocation
    }
}

class CellGestureHit: GestureHit {
    let collectionViewHit: CollectionViewGestureHit
    let cell: ItemViewModelCell
    let locationInCell: CGPoint
    let itemViewModel: ItemViewModel
    
    init(collectionViewHit initHit: CollectionViewGestureHit, cell initCell: ItemViewModelCell, locationInCell initCellLocation: CGPoint, itemViewModel initItem: ItemViewModel) {
        collectionViewHit = initHit
        cell = initCell
        locationInCell = initCellLocation
        itemViewModel = initItem
    }
}

class AppGestureHit: CellGestureHit {
    let appViewModel: AppViewModel
    
    init(collectionViewHit initHit: CollectionViewGestureHit, cell initCell: ItemViewModelCell, locationInCell initCellLocation: CGPoint, appViewModel initApp: AppViewModel) {
        appViewModel = initApp
        super.init(collectionViewHit: initHit, cell: initCell, locationInCell: initCellLocation, itemViewModel: initApp)
    }
}

class FolderGestureHit: CellGestureHit {
    let folderViewModel: FolderViewModel
    
    init(collectionViewHit initHit: CollectionViewGestureHit, cell initCell: ItemViewModelCell, locationInCell initCellLocation: CGPoint, folderViewModel initFolder: FolderViewModel) {
        folderViewModel = initFolder
        super.init(collectionViewHit: initHit, cell: initCell, locationInCell: initCellLocation, itemViewModel: initFolder)
    }
}
