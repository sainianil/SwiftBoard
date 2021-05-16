//
//  MoveAppToFolder.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-11-24.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import Foundation

class MoveAppToFolder: NSObject, DragAndDropOperation {
    let prepareToOpenFolderAfterSeconds = 1.0
    let openFolderAfterSeconds = 0.4
    
    let rootViewModel: RootViewModel
    let appViewModel: AppViewModel
    let folderViewModel: FolderViewModel
    
    private var openFolderTimer: Timer?
    
    init(rootViewModel initRoot: RootViewModel, appViewModel initApp: AppViewModel, folderViewModel initFolder: FolderViewModel) {
        rootViewModel = initRoot
        appViewModel = initApp
        folderViewModel = initFolder
    }
    
    func dragStart() {
        folderViewModel.state = .AppHovering
        openFolderTimer = Timer.scheduledTimer(timeInterval: prepareToOpenFolderAfterSeconds, target: self, selector: Selector(("prepareToOpenFolder")), userInfo: nil, repeats: false)
    }
    
    func dragCancel() {
        cancelTimer()
        folderViewModel.state = .Closed
    }
    
    func drop() {
        cancelTimer()
        rootViewModel.moveAppToFolder(appViewModel: appViewModel, folderViewModel: folderViewModel, open: false)
        folderViewModel.state = .Closed
    }
    
    func prepareToOpenFolder() {
        cancelTimer()
        
        folderViewModel.state = .PreparingToOpen
        openFolderTimer = Timer.scheduledTimer(timeInterval: openFolderAfterSeconds, target: self, selector: Selector(("openFolder")), userInfo: nil, repeats: false)
    }
    
    func openFolder() {
        cancelTimer()
        
        rootViewModel.moveAppToFolder(appViewModel: appViewModel, folderViewModel: folderViewModel, open: true)
    }
    
    private func cancelTimer() {
        openFolderTimer?.invalidate()
        openFolderTimer = nil
    }
}
