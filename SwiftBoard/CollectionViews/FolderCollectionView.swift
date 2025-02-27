//
//  FolderCollectionView.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-11-17.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import UIKit

class FolderCollectionView: ListViewModelCollectionView {
    var listDataSource: ListViewModelDataSource?
    
    var folderViewModel: FolderViewModel? {
        didSet {
            if let myViewModel = folderViewModel {
                listDataSource = ListViewModelDataSource(myViewModel)
                dataSource = listDataSource
                delegate = listDataSource
                
                myViewModel.listViewModelDelegate = self
            } else {
                listDataSource = nil
                dataSource = nil
                delegate = nil
            }
        }
    }
    
    override var listViewModel: ListViewModel? {
        return folderViewModel
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        register(UINib(nibName: "AppCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "App")
    }
}
