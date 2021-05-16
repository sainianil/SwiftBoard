//
//  ListViewModel.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-11-17.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import Foundation

protocol ListViewModelDelegate: class {
    func listViewModelItemMoved(fromIndex: Int, toIndex: Int)
    func listViewModelItemAddedAtIndex(index: Int)
    func listViewModelItemRemovedAtIndex(index: Int)
}

class ListViewModel {
    private var viewModels: [ItemViewModel]
    weak var listViewModelDelegate: ListViewModelDelegate?
    
    init(viewModels initViewModels:[ItemViewModel]) {
        viewModels = initViewModels
        
        for itemViewModel in viewModels {
            itemViewModel.parentListViewModel = self
        }
    }
    
    func numberOfItems() -> Int {
        return viewModels.count
    }
    
    func itemAtIndex(index: Int) -> ItemViewModel {
        return viewModels[index]
    }
    
    func indexOfItem(item: ItemViewModel) -> Int? {
        for (index, compareItem) in viewModels.enumerated() {
            if item === compareItem {
                return index
            }
        }
        
        return nil
    }
    
    func moveItemAtIndex(fromIndex: Int, toIndex: Int) {
        let item: ItemViewModel = viewModels[fromIndex]
        viewModels.remove(at: fromIndex)
        viewModels.insert(item, at: toIndex)
        
        listViewModelDelegate?.listViewModelItemMoved(fromIndex: fromIndex, toIndex: toIndex)
    }
    
    func removeItemAtIndex(index: Int)  {
        viewModels.remove(at: index)
        listViewModelDelegate?.listViewModelItemRemovedAtIndex(index: index)
    }
    
    func appendItem(itemViewModel: ItemViewModel) {
        let index = viewModels.count
        viewModels.append(itemViewModel)
        listViewModelDelegate?.listViewModelItemAddedAtIndex(index: index)
    }
}
