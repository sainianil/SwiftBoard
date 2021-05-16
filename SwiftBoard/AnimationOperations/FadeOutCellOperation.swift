//
//  FadeOutCellOperation.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-12-03.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import Foundation

class FadeOutCellOperation: AsyncOperation {
    let collectionViewCell: UICollectionViewCell
    
    init(_ initCell: UICollectionViewCell) {
        collectionViewCell = initCell
    }
    
    override func start() {
        isExecuting = true
        
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.collectionViewCell.alpha = 0
        }, completion: { (Bool) -> Void in
            self.isFinished = true
        })
    }
}
