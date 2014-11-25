//
//  AppCollectionViewCell.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-09-18.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import UIKit

class AppCollectionViewCell : SwiftBoardCell, AppViewModelDelegate {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightConstraint: NSLayoutConstraint!
    
    weak var appViewModel: AppViewModel? {
        didSet {
            if appViewModel != nil {
                hidden = appViewModel!.dragging
                label.text = appViewModel!.name
                containerView.backgroundColor = appViewModel!.color
                appViewModel!.delegate = self
            } else {
                hidden = false
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        appViewModel = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        containerView.layer.cornerRadius = 5
    }
    
    override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes!) {
        super.applyLayoutAttributes(layoutAttributes)
        
        if bounds.width < 80 {
            deleteButton.alpha = 0
            label.alpha = 0
            
            topConstraint.constant = 0
            bottomConstraint.constant = 0
            leftConstraint.constant = 0
            rightConstraint.constant = 0
        } else {
            deleteButton.alpha = 1
            label.alpha = 1
            
            let extraWidth = (bounds.width - 60) / 2
            let extraHeight = (bounds.height - 80) / 2
            
            topConstraint.constant = extraHeight
            bottomConstraint.constant = extraHeight + 20
            leftConstraint.constant = extraWidth
            rightConstraint.constant = extraWidth
        }
        
        // Trigger constraint re-evaluation, so the subview sizes get animated too
        // http://stackoverflow.com/questions/23564453/uicollectionview-layout-transitions
        layoutIfNeeded()
    }
    
    override func pointInsideIcon(point:CGPoint) -> Bool {
        let converted = convertPoint(point, toView:containerView)
        return containerView.pointInside(converted, withEvent: nil)
    }
    
    @IBAction func deleteApp(sender: AnyObject) {
        appViewModel?.delete()
    }
    
    // MARK: AppViewModelDelegate
    func appViewModelDraggingDidChange(dragging: Bool) {
        hidden = dragging
    }
}
