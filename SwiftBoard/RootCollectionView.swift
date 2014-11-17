//
//  RootCollectionView.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-11-17.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import UIKit

struct GestureInfo {
    let listViewModel:SwiftBoardListViewModel
    let itemViewModel:SwiftBoardItemViewModel
    let itemIndexInList: Int
}

class RootCollectionView: SwiftBoardCollectionView, UIGestureRecognizerDelegate {
    private var rootDataSource: RootDataSource?
    private var zoomedLayout = CollectionViewLayout()
    private var regularLayout = CollectionViewLayout()
    
    private var tapGestureRecognizer: UITapGestureRecognizer!
    private var longPressRecognizer: UILongPressGestureRecognizer!
    private var panAndStopGestureRecognizer: PanAndStopGestureRecognizer!
    
    var rootViewModel: RootViewModel? {
        didSet {
            println("Gotcha!")
            
            if rootViewModel != nil {
                rootDataSource = RootDataSource(rootViewModel: rootViewModel!)
                dataSource = rootDataSource
                delegate = rootDataSource
            }
        }
    }
    
    override var listViewModel: SwiftBoardListViewModel? {
        return rootViewModel
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        registerNib(UINib(nibName: "AppCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "App")
        registerNib(UINib(nibName: "FolderCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "Folder")
        
        backgroundColor = UIColor.clearColor()
        scrollEnabled = false
        setCollectionViewLayout(regularLayout, animated: false)
        
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "handleTapGesture:")
        longPressRecognizer = UILongPressGestureRecognizer(target: self, action: "handleLongPressGesture:")
        panAndStopGestureRecognizer = PanAndStopGestureRecognizer(target: self, action: "handlePanGesture:", stopAfterSecondsWithoutMovement: 0.2) {
            (gesture:PanAndStopGestureRecognizer) in self.handlePanGestureStopped(gesture)
        }
        
        addGestureRecognizer(tapGestureRecognizer)
        addGestureRecognizer(longPressRecognizer)
        addGestureRecognizer(panAndStopGestureRecognizer)
    }
    
    func viewModelAtIndexPath(indexPath: NSIndexPath) -> SwiftBoardItemViewModel? {
        return nil
    }
    
    func handleTapGesture(gesture: UITapGestureRecognizer) {
        if let gestureInfo = infoForGesture(gesture) {
            gestureInfo.itemViewModel.open()
        }
    }
    
    func handleLongPressGesture(gesture: UILongPressGestureRecognizer) {
        
    }
    
    func handlePanGesture(gesture: PanAndStopGestureRecognizer) {
        
    }
    
    func handlePanGestureStopped(gesture: PanAndStopGestureRecognizer) {
        
    }
    
    // TODO: Not happy with "info", come up with a better name
    func infoForGesture(gesture: UIGestureRecognizer) -> GestureInfo? {
        var destCollectionView:SwiftBoardCollectionView?
        var indexPath:NSIndexPath?
        
        if let folderIndex = rootViewModel?.zoomedFolderIndex {
            let indexPath = NSIndexPath(forItem: folderIndex, inSection: 0)
            if let folderCell = cellForItemAtIndexPath(indexPath) as? FolderCollectionViewCell {
                destCollectionView = folderCell.collectionView
            }
        } else {
            destCollectionView = self
        }
        
        if let collectionView = destCollectionView {
            let location = gesture.locationInView(collectionView)
            
            if let indexPath = collectionView.indexPathForItemAtPoint(location) {
                if let listViewModel = collectionView.listViewModel {
                    let itemViewModel = listViewModel.itemAtIndex(indexPath.item)
                    
                    return GestureInfo(listViewModel: listViewModel, itemViewModel: itemViewModel, itemIndexInList: indexPath.item)
                }
            }
        }
        
        return nil
    }
    
    // MARK: UIGestureRecognizerDelegate
    
    override func gestureRecognizerShouldBegin(gesture: UIGestureRecognizer) -> Bool {
        switch gesture {
        case longPressRecognizer:
            return true
        case panAndStopGestureRecognizer:
            return true //currentDragState != nil
        default:
            return super.gestureRecognizerShouldBegin(gesture)
        }
    }
    
    func gestureRecognizer(gesture: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGesture: UIGestureRecognizer) -> Bool {
        switch gesture {
        case longPressRecognizer:
            return otherGesture === panAndStopGestureRecognizer
        case panAndStopGestureRecognizer:
            return otherGesture === longPressRecognizer
        default:
            return false
        }
    }

}
