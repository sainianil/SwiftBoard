//
//  FolderViewModel.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-11-15.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import Foundation

protocol FolderViewModelDelegate: class {
    func folderViewModelDraggingDidChange(dragging: Bool)
    func folderViewModelAppDidMove(fromIndex: Int, toIndex: Int)
}

class FolderViewModel: SwiftBoardViewModel {
    var name: String
    var appViewModels: [AppViewModel]
    
    var dragging: Bool = false {
        didSet {
            delegate?.folderViewModelDraggingDidChange(dragging)
        }
    }
    
    weak var delegate: FolderViewModelDelegate?
    
    init(name folderName: String, appViewModels apps: [AppViewModel]) {
        name = folderName
        appViewModels = apps
    }
    
    func numberOfAppViewModels() -> Int {
        return appViewModels.count
    }
    
    func appViewModelAtIndex(index: Int) -> AppViewModel {
        return appViewModels[index]
    }
    
    func moveAppAtIndex(fromIndex: Int, toIndex: Int) {
        var app: AppViewModel = appViewModels[fromIndex]
        appViewModels.removeAtIndex(fromIndex)
        appViewModels.insert(app, atIndex: toIndex)
        
        delegate?.folderViewModelAppDidMove(fromIndex, toIndex: toIndex)
    }
}
