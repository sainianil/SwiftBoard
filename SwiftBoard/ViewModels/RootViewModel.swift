//
//  RootViewModel.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-11-15.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import Foundation

protocol RootViewModelDelegate: class {
    func rootViewModelFolderOpened(folderViewModel: FolderViewModel)
    func rootViewModelFolderClosed(folderViewModel: FolderViewModel)
    
    func rootViewModelWillMoveAppToFolder(appViewModel: AppViewModel, folderViewModel: FolderViewModel, open: Bool)
    func rootViewModelDidMoveAppToFolder(appViewModel: AppViewModel, folderViewModel: FolderViewModel, open: Bool)
}

class RootViewModel: ListViewModel {
    weak var rootViewModelDelegate: RootViewModelDelegate?
    
    var editingModeEnabled: Bool = false {
        didSet {
            for i in 0..<numberOfItems() {
                let item = itemAtIndex(index: i)
                item.editing = editingModeEnabled
            }
        }
    }
    
    private var openFolderViewModel: FolderViewModel? {
        didSet {
            let zoomed = openFolderViewModel != nil
            
            for i in 0..<numberOfItems() {
                let item = itemAtIndex(index: i)
                item.zoomed = zoomed
            }
        }
    }
    
    func moveAppToFolder(appViewModel: AppViewModel, folderViewModel: FolderViewModel, open: Bool) {
        if let index = indexOfItem(item: appViewModel) {
            rootViewModelDelegate?.rootViewModelWillMoveAppToFolder(appViewModel: appViewModel, folderViewModel: folderViewModel, open: open)
            
//            let addIndex = folderViewModel.numberOfItems()
            
            appViewModel.parentListViewModel = folderViewModel
            removeItemAtIndex(index: index)
            folderViewModel.appendItem(itemViewModel: appViewModel)
            
            if open {
                openFolder(folderViewModel: folderViewModel)
            }
            
            rootViewModelDelegate?.rootViewModelDidMoveAppToFolder(appViewModel: appViewModel, folderViewModel: folderViewModel, open: open)
        } else {
            assertionFailure("moveAppToFolder: AppViewModel isn't in the RootViewModel")
        }
    }
    
    func moveAppFromFolder(appViewModel: AppViewModel, folderViewModel: FolderViewModel) {
        if let removeIndex = folderViewModel.indexOfItem(item: appViewModel) {
//            let addIndex = numberOfItems()
            
            appViewModel.parentListViewModel = self
            folderViewModel.removeItemAtIndex(index: removeIndex)
            appendItem(itemViewModel: appViewModel)
        } else {
            assertionFailure("moveAppFromFolder: AppViewModel isn't in the FolderViewModel")
        }
    }
    
    func openFolder(folderViewModel: FolderViewModel) {
        if openFolderViewModel == nil {
            openFolderViewModel = folderViewModel
            
            folderViewModel.state = .Open
            rootViewModelDelegate?.rootViewModelFolderOpened(folderViewModel: folderViewModel)
        } else {
            assertionFailure("openFolder: Tried to open a folder when another is open.")
        }
    }
    
    func closeFolder(folderViewModel: FolderViewModel) {
        if openFolderViewModel != nil {
            openFolderViewModel = nil
            
            folderViewModel.state = .Closed
            rootViewModelDelegate?.rootViewModelFolderClosed(folderViewModel: folderViewModel)
        } else {
            assertionFailure("closeFolder: Tried to close a folder when no folder is open.")
        }
    }
}
