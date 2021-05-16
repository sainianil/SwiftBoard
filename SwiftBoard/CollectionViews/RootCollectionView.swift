//
//  RootCollectionView.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-11-17.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import UIKit

struct DragProxyState {
    let view: UIView
    let originalCenter: CGPoint
}

class RootCollectionView: ListViewModelCollectionView, UIGestureRecognizerDelegate, RootViewModelDelegate {
    private var listDataSource: ListViewModelDataSource?
    private var regularLayout = CollectionViewLayout()
    
    private var tapGestureRecognizer: UITapGestureRecognizer!
    private var longPressRecognizer: UILongPressGestureRecognizer!
    private var panAndStopGestureRecognizer: PanAndStopGestureRecognizer!
    
    private var openFolderCollectionView: FolderCollectionView?
    private var dragProxyState: DragProxyState?
    private var draggingItemViewModel: ItemViewModel?

    private var lastCollectionView: UICollectionView?
    private var dragAndDropOperation: DragAndDropOperation?
    private var cancelDragAndDropOperationWhenExitsRect: CGRect?
    
    var rootViewModel: RootViewModel? {
        didSet {
            if rootViewModel != nil {
                rootViewModel!.listViewModelDelegate = self
                rootViewModel!.rootViewModelDelegate = self
                
                listDataSource = ListViewModelDataSource(rootViewModel!)
                dataSource = listDataSource
                delegate = listDataSource
            } else {
                listDataSource = nil
                dataSource = nil
                delegate = nil
            }
        }
    }
    
    override var listViewModel: ListViewModel? {
        return rootViewModel
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        register(UINib(nibName: "AppCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "App")
        register(UINib(nibName: "FolderCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "Folder")
        
        backgroundColor = UIColor.clear
        isScrollEnabled = false
        setCollectionViewLayout(regularLayout, animated: false)
        
        addGestureRecognizers()
    }
    
    func addGestureRecognizers() {
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        addGestureRecognizer(tapGestureRecognizer)
        
        longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture))
        longPressRecognizer.delegate = self
        addGestureRecognizer(longPressRecognizer)
        
        panAndStopGestureRecognizer = PanAndStopGestureRecognizer(target: self, action: #selector(handlePanGesture), stopAfterSecondsWithoutMovement: 0.2) {
            (gesture:PanAndStopGestureRecognizer) in self.handlePanGestureStopped(gesture: gesture)
        }
        panAndStopGestureRecognizer.delegate = self
        addGestureRecognizer(panAndStopGestureRecognizer)
    }

    @objc func handleTapGesture(gesture: UITapGestureRecognizer) {
        let gestureHit = gestureHitForGesture(gesture: gesture)
        
        if let folderHit = gestureHit as? FolderGestureHit {
            rootViewModel?.openFolder(folderViewModel: folderHit.folderViewModel)
        } else if gestureHit is CollectionViewGestureHit {
            if openFolderCollectionView != nil {
                rootViewModel?.closeFolder(folderViewModel: openFolderCollectionView!.folderViewModel!)
            }
        }
    }
    
    @objc func handleLongPressGesture(gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case UIGestureRecognizerState.began:
            startDrag(gesture: gesture)
        case UIGestureRecognizerState.ended, UIGestureRecognizerState.cancelled:
            endDrag(gesture: gesture)
        default:
            break
        }
    }
    
    @objc func handlePanGesture(gesture: PanAndStopGestureRecognizer) {
        if gesture.state == .began || gesture.state == .changed {
            updateDragProxyPosition(gesture: gesture)
            dragAppOutOfFolder(gesture: gesture)
            cancelDragAndDropOperationIfExitsRect(gesture: gesture)
        }
    }
    
    func handlePanGestureStopped(gesture: PanAndStopGestureRecognizer) {
        // Don't start a new operation if one is already in progress.
        if dragAndDropOperation != nil {
            return
        }

        if let dragOp = dragOperationForGesture(gesture: gesture) {
            dragOp.dragStart()
            
            if let dropOp = dragOp as? DragAndDropOperation {
                dragAndDropOperation = dropOp
            }
        }
    }
    
    func collectionViewForGesture(gesture: UIGestureRecognizer) -> ListViewModelCollectionView {
        var destCollectionView: ListViewModelCollectionView = self
        if let folderCollectionView = openFolderCollectionView {
            if folderCollectionView.point(inside: gesture.location(in: folderCollectionView), with: nil) {
                destCollectionView = folderCollectionView
            }
        }
        
        return destCollectionView
    }
    
    func gestureHitForGesture(gesture: UIGestureRecognizer) -> GestureHit {
        let destCollectionView = collectionViewForGesture(gesture: gesture)
        let locationInCollectionView = gesture.location(in: destCollectionView)
        let collectionViewHit = CollectionViewGestureHit(collectionView: destCollectionView, locationInCollectionView: locationInCollectionView)
        
        if let indexPath = destCollectionView.indexPathForItem(at: locationInCollectionView) {
            if let cell = destCollectionView.cellForItem(at: indexPath) as? ItemViewModelCell {
                if let listViewModel = destCollectionView.listViewModel {
                    let itemViewModel = listViewModel.itemAtIndex(index: indexPath.item)
                    let locationInCell = destCollectionView.convert(locationInCollectionView, to: cell)
                    
                    if let appViewModel = itemViewModel as? AppViewModel {
                        return AppGestureHit(collectionViewHit: collectionViewHit,
                                             cell: cell,
                                             locationInCell: locationInCell,
                                             appViewModel: appViewModel)
                    } else if let folderViewModel = itemViewModel as? FolderViewModel {
                        return FolderGestureHit(collectionViewHit: collectionViewHit,
                                                cell: cell,
                                                locationInCell: locationInCell,
                                                folderViewModel: folderViewModel)
                    }
                }
            }
        }
        
        return collectionViewHit
    }
    
    func dragOperationForGesture(gesture: UIGestureRecognizer) -> DragOperation? {
        let gestureHit = gestureHitForGesture(gesture: gesture)
        
        if let dragOperation = dragOperationForAppOnFolder(gestureHit: gestureHit) {
            return dragOperation
        }
        
        if let dragOperation = dragOperationForMoveItem(gestureHit: gestureHit) {
            return dragOperation
        }
        
        // TODO: Handle dragging an app on top of an app, creating a folder.
        
        return nil
    }
    
    func dragOperationForAppOnFolder(gestureHit: GestureHit) -> DragOperation? {
        if let appViewModel = draggingItemViewModel as? AppViewModel {
            if let folderHit = gestureHit as? FolderGestureHit {
                if let iconRect = folderHit.cell.iconRect() {
                    if iconRect.contains(folderHit.locationInCell) {
                        cancelDragAndDropOperationWhenExitsRect = convert(iconRect, from: folderHit.cell)
                        return MoveAppToFolder(rootViewModel: rootViewModel!, appViewModel: appViewModel, folderViewModel: folderHit.folderViewModel)
                    }
                }
            }
        }
        
        return nil
    }
    
    func dragOperationForMoveItem(gestureHit: GestureHit) -> DragOperation? {
        if let itemViewModel = draggingItemViewModel {
            if let listViewModel = itemViewModel.parentListViewModel {
                let dragIndex = listViewModel.indexOfItem(item: itemViewModel)
                
                if let cellHit = gestureHit as? CellGestureHit {
                    if itemViewModel === cellHit.itemViewModel {
                        return nil
                    }
                    
                    let layout = cellHit.collectionViewHit.collectionView.collectionViewLayout as! DroppableCollectionViewLayout
                    let dropIndex = listViewModel.indexOfItem(item: cellHit.itemViewModel)
                    var newIndex: Int
                    
                    if dragIndex != nil && dropIndex != nil {
                        if cellHit.locationInCell.x < (cellHit.cell.bounds.width / 2) {
                            newIndex = layout.indexToMoveSourceIndexLeftOfDestIndex(sourceIndex: dragIndex!, destIndex: dropIndex!)
                        } else {
                            newIndex = layout.indexToMoveSourceIndexRightOfDestIndex(sourceIndex: dragIndex!, destIndex: dropIndex!)
                        }
                        
                        return MoveItemInList(listViewModel: listViewModel, fromIndex: dragIndex!, toIndex: newIndex)
                    }
                } else if let collectionViewHit = gestureHit as? CollectionViewGestureHit {
                    let lastIndex = listViewModel.numberOfItems() - 1
                    
                    if collectionViewHit.collectionView.listViewModel === listViewModel && dragIndex != nil && lastIndex != dragIndex {
                        return MoveItemInList(listViewModel: listViewModel, fromIndex: dragIndex!, toIndex: lastIndex)
                    }
                }
            }
        }

        return nil
    }
    
    private func startDrag(gesture: UIGestureRecognizer) {
        if let cellHit = gestureHitForGesture(gesture: gesture) as? CellGestureHit {
            let cell = cellHit.cell
            cell.showDeleteButton(animated: false)
            
            let dragProxyView = cell.snapshotView(afterScreenUpdates: true)
            dragProxyView?.frame = convert(cell.frame, from: cell.superview)
            guard let dragView = dragProxyView else {
                return
            }
            addSubview(dragView)
            
            dragProxyState = DragProxyState(view: dragView, originalCenter: dragView.center)
            UIView.animate(withDuration: 0.2) {
                dragView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                dragView.alpha = 0.9
            }
            
            rootViewModel!.editingModeEnabled = true
            draggingItemViewModel = cellHit.itemViewModel
            draggingItemViewModel!.dragging = true
        }
    }
    
    private func endDrag(gesture: UIGestureRecognizer) {
        dragAndDropOperation?.drop()
        dragAndDropOperation = nil
        
        if let proxyState = dragProxyState {
            // Do the animation in the operation queue, so we can be sure the cell has been inserted into the
            // destination collection view.
            //
            // TODO: This isn't working again for dropping on a folder, might need to go back to setting
            // frame instead of center again?
            OperationQueue.main.addOperation({ () -> Void in
                if let returnToCenter = self.dragProxyReturnToCenter() {
                    UIView.animate(withDuration: 0.4, animations: { () -> Void in
                        proxyState.view.transform = CGAffineTransform.identity
                        proxyState.view.alpha = 1
                        proxyState.view.center = returnToCenter
                    }, completion: { (Bool) -> Void in
                        self.resetDrag()
                    })
                } else {
                    self.resetDrag()
                }
            })
        }
    }
    
    private func resetDrag() {
        if let itemViewModel = draggingItemViewModel {
            itemViewModel.dragging = false
            
            if let proxyState = dragProxyState {
                proxyState.view.removeFromSuperview()
            }
        
            draggingItemViewModel = nil
        }
    }
    
    private func updateDragProxyPosition(gesture: UIPanGestureRecognizer) {
        if let proxyState = dragProxyState {
            let translation = gesture.translation(in: self)
            proxyState.view.center = CGPoint(x: proxyState.originalCenter.x + translation.x, y: proxyState.originalCenter.y + translation.y)
        }
    }
    
    private func dragAppOutOfFolder(gesture: UIPanGestureRecognizer) {
        let gestureCollectionView = collectionViewForGesture(gesture: gesture)
        
        if lastCollectionView != nil && lastCollectionView === openFolderCollectionView && lastCollectionView !== gestureCollectionView {
            if let folderViewModel = openFolderCollectionView?.folderViewModel {
                if let appViewModel = draggingItemViewModel as? AppViewModel {
                    rootViewModel?.moveAppFromFolder(appViewModel: appViewModel, folderViewModel: folderViewModel)
                    rootViewModel?.closeFolder(folderViewModel: folderViewModel)
                    
                    // The AddItemOperation animation needs to be in-flight before we remove the folder so that the index
                    // paths line up.
                    if folderViewModel.numberOfItems() == 0 {
                        OperationQueue.main.addOperation { () -> Void in
                            if let folderIndex = self.rootViewModel?.indexOfItem(item: folderViewModel) {
                                self.rootViewModel?.removeItemAtIndex(index: folderIndex)
                            }
                        }
                    }
                }
            }
        }
        
        lastCollectionView = gestureCollectionView
    }
    
    private func cancelDragAndDropOperationIfExitsRect(gesture: UIPanGestureRecognizer) {
        if let dragOp = dragAndDropOperation {
            if let exitRect = cancelDragAndDropOperationWhenExitsRect {
                let location = gesture.location(in: self)
                
                if !exitRect.contains(location) {
                    dragOp.dragCancel()
                    dragAndDropOperation = nil
                }
            }
        }
    }
    
    private func dragProxyReturnToCenter() -> CGPoint? {
        if let itemViewModel = draggingItemViewModel {
            if let cell = cellForItemViewModel(itemViewModel: itemViewModel) {
                return convert(cell.center, from: cell.superview)
            }
        }
        
        return nil
    }
    
    private func cellForItemViewModel(itemViewModel: ItemViewModel) -> UICollectionViewCell? {
        var cell: UICollectionViewCell?
        
        if let rootViewModel = itemViewModel.parentListViewModel as? RootViewModel {
            if let index = rootViewModel.indexOfItem(item: itemViewModel) {
                cell = cellForItem(at: index.toIndexPath())
            }
        } else if let folderViewModel = itemViewModel.parentListViewModel as? FolderViewModel {
            if let indexOfFolder = rootViewModel?.indexOfItem(item: folderViewModel) {
                if let folderCell = cellForItem(at: indexOfFolder.toIndexPath()) as? FolderCollectionViewCell {
                    if let indexOfItem = folderViewModel.indexOfItem(item: itemViewModel) {
                        cell = folderCell.collectionView.cellForItem(at: indexOfItem.toIndexPath())
                    }
                }
            }
        }
        
        return cell
    }
    
    // MARK: UIGestureRecognizerDelegate
    
    override func gestureRecognizerShouldBegin(_ gesture: UIGestureRecognizer) -> Bool {
        switch gesture {
        case longPressRecognizer:
            return true
        case panAndStopGestureRecognizer:
            return draggingItemViewModel != nil
        default:
            return super.gestureRecognizerShouldBegin(gesture)
        }
    }
    
    func gestureRecognizer(_ gesture: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGesture: UIGestureRecognizer) -> Bool {
        switch gesture {
        case longPressRecognizer:
            return otherGesture === panAndStopGestureRecognizer
        case panAndStopGestureRecognizer:
            return otherGesture === longPressRecognizer
        default:
            return false
        }
    }
    
    // MARK: RootViewModelDelegate
    
    func rootViewModelWillMoveAppToFolder(appViewModel: AppViewModel, folderViewModel: FolderViewModel, open: Bool) {
        deferAnimations = false
    }
    
    func rootViewModelDidMoveAppToFolder(appViewModel: AppViewModel, folderViewModel: FolderViewModel, open: Bool) {
        deferAnimations = true
    }
    
    func rootViewModelFolderOpened(folderViewModel: FolderViewModel) {
        // Opening a folder terminates the current drag and drop operation
        dragAndDropOperation = nil
        
        if let index = rootViewModel?.indexOfItem(item: folderViewModel) {
            if let cell = cellForItem(at: index.toIndexPath()) as? FolderCollectionViewCell {
                openFolderCollectionView = cell.collectionView
                
                let zoomedLayout = CollectionViewLayout()
                zoomedLayout.zoomToIndex = index
                
                let op = SetLayoutOperation(collectionView: self, layout: zoomedLayout)
                if deferAnimations {
                    OperationQueue.main.addOperation(op)
                } else {
                    op.start()
                }
            }
        }
    }
    
    func rootViewModelFolderClosed(folderViewModel: FolderViewModel) {
        // Closing a folder terminates the current drag and drop operation
        dragAndDropOperation = nil
        
        if (rootViewModel?.indexOfItem(item: folderViewModel)) != nil {
            openFolderCollectionView = nil
            
            let op = SetLayoutOperation(collectionView: self, layout: regularLayout)
            OperationQueue.main.addOperation(op)
        }
    }
}
