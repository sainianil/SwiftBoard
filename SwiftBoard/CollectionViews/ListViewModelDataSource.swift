//
//  ListViewModelDataSource.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-10-21.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import UIKit

class ListViewModelDataSource : NSObject, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var listViewModel: ListViewModel
    
    init(_ initViewModel: ListViewModel) {
        listViewModel = initViewModel
        
        super.init()
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listViewModel.numberOfItems()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell:UICollectionViewCell
        let itemViewModel = listViewModel.itemAtIndex(index: indexPath.item)
        
        switch itemViewModel {
        case let appViewModel as AppViewModel:
            let myCell = collectionView.dequeueReusableCell(withReuseIdentifier: "App", for: indexPath as IndexPath) as! AppCollectionViewCell
            myCell.appViewModel = appViewModel
                        
            cell = myCell
        case let folderViewModel as FolderViewModel:
            let myCell = collectionView.dequeueReusableCell(withReuseIdentifier: "Folder", for: indexPath as IndexPath) as! FolderCollectionViewCell
            myCell.folderViewModel = folderViewModel
            
            cell = myCell
        default:
            cell = UICollectionViewCell()
        }
        
        return cell
    }
    
}
