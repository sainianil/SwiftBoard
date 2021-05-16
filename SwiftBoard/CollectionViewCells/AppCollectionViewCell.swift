//
//  AppCollectionViewCell.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-09-18.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import UIKit

class AppCollectionViewCell : ItemViewModelCell, AppViewModelDelegate {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightConstraint: NSLayoutConstraint!
    
    weak var appViewModel: AppViewModel? {
        didSet {
            if let myViewModel = appViewModel {
                isHidden = myViewModel.dragging
                editing = myViewModel.editing
                zoomed = myViewModel.zoomed
                label.text = myViewModel.name
                containerView.backgroundColor = myViewModel.color
                myViewModel.delegate = self
            } else {
                isHidden = false
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
        deleteButton.layer.cornerRadius = 11
    }
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        
        if zoomed {
            updateConstraintsZoomed()
        } else if bounds.width < 80 {
            updateConstraintsSmall()
        } else {
            updateConstraintsNormal()
        }
        
        // Trigger constraint re-evaluation, so the subview sizes get animated too
        // http://stackoverflow.com/questions/23564453/uicollectionview-layout-transitions
        layoutIfNeeded()
    }
    
    @IBAction func deleteApp(sender: AnyObject) {
        appViewModel?.delete()
    }
    
    override func iconRect() -> CGRect? {
        return containerView.frame
    }
    
    override func showDeleteButton(animated: Bool) {
        deleteButton.isHidden = false
        
        if animated {
            deleteButton.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            
            UIView.animate(withDuration: 0.2, animations: { () -> Void in
                self.deleteButton.transform = CGAffineTransform.identity
            })
        }
    }
    
    override func hideDeleteButton(animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.2, animations: { () -> Void in
                self.deleteButton.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            }, completion: { (finished: Bool) -> Void in
                self.deleteButton.isHidden = true
                self.deleteButton.transform = CGAffineTransform.identity
            })
        } else {
            self.deleteButton.isHidden = true
        }
    }
    
    func updateConstraintsZoomed() {
        topConstraint.constant = 10
        bottomConstraint.constant = 30
        leftConstraint.constant = 10
        rightConstraint.constant = 10
    }
    
    func updateConstraintsSmall() {
        deleteButton.alpha = 0
        label.alpha = 0
        
        topConstraint.constant = 2
        bottomConstraint.constant = 2
        leftConstraint.constant = 2
        rightConstraint.constant = 2
    }
    
    func updateConstraintsNormal() {
        deleteButton.alpha = 1
        label.alpha = 1
        
        let extraWidth = (bounds.width - 60) / 2
        let extraHeight = (bounds.height - 80) / 2
        
        topConstraint.constant = extraHeight
        bottomConstraint.constant = extraHeight + 20
        leftConstraint.constant = extraWidth
        rightConstraint.constant = extraWidth

    }
    
    // MARK: AppViewModelDelegate
    
    func appViewModelDraggingDidChange(_ newValue: Bool) {
        isHidden = newValue
    }
    
    func appViewModelDeletingDidChange(_ newValue: Bool) {
        if newValue {
            let op = FadeOutCellOperation(self)
            OperationQueue.main.addOperation(op)
        }
    }
    
    func appViewModelEditingDidChange(_ newValue: Bool) {
        editing = newValue
    }
    
    func appViewModelZoomedDidChange(_ newValue: Bool) {
        zoomed = newValue
    }
}
