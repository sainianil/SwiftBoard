//
//  FolderCollectionViewCell.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-09-18.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import UIKit

class FolderCollectionViewCell : ItemViewModelCell, FolderViewModelDelegate {
    @IBOutlet weak var collectionView: FolderCollectionView!
    @IBOutlet weak var expandingView: UIView!
    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightConstraint: NSLayoutConstraint!
    
    let flickeringAnimationKey = "flickering"
    
    private var expanded: Bool = false {
        didSet {
            expanded ? expand() : collapse()
        }
    }
    
    private var flickering: Bool = false {
        didSet {
            flickering ? startFlickering() : stopFlickering()
        }
    }
    
    weak var folderViewModel: FolderViewModel? {
        didSet {
            if let myViewModel = folderViewModel {
                isHidden = myViewModel.dragging
                editing = myViewModel.editing
                zoomed = myViewModel.zoomed
                label.text = myViewModel.name
                collectionView.folderViewModel = myViewModel
                myViewModel.folderViewModelDelegate = self
            } else {
                isHidden = false
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.backgroundColor = UIColor.clear
        expandingView.layer.cornerRadius = 5
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        isHidden = false
    }
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes?) {
        super.apply(layoutAttributes ?? UICollectionViewLayoutAttributes())
    
        if zoomed {
            topConstraint.constant = 10
            bottomConstraint.constant = 30
            leftConstraint.constant = 10
            rightConstraint.constant = 10
        } else {
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
    
    override func iconRect() -> CGRect? {
        return collectionView.frame
    }
    
    func expand() {
        UIView.animate(withDuration: 0.4) {
            self.expandingView.layer.transform = CATransform3DMakeScale(1.2, 1.2, 1)
            self.label.alpha = 0
        }
    }
    
    func collapse() {
        UIView.animate(withDuration: 0.4) {
            self.expandingView.layer.transform = CATransform3DIdentity
            self.label.alpha = 1
        }
    }
    
    func startFlickering() {
        let anim = CABasicAnimation(keyPath: "backgroundColor")
        anim.toValue = UIColor.darkGray.cgColor
        anim.autoreverses = true
        anim.duration = 0.1
        anim.repeatCount = HUGE
        
        expandingView.layer.add(anim, forKey:flickeringAnimationKey);
    }
    
    func stopFlickering() {
        expandingView.layer.removeAnimation(forKey: flickeringAnimationKey)
    }
    
    // FolderViewModelDelegate
    
    func folderViewModelDraggingDidChange(_ newValue: Bool) {
        isHidden = newValue
    }
        
    func folderViewModelEditingDidChange(_ newValue: Bool) {
        editing = newValue
        updateJiggling()
    }
    
    func folderViewModelZoomedDidChange(_ newValue: Bool) {
        zoomed = newValue
        updateJiggling()
    }
    
    func folderViewModelStateDidChange(_ state: FolderViewModelState) {
        switch state {
        case .Closed:
            expanded = false
            flickering = false
        case .AppHovering:
            expanded = true
            flickering = false
        case .PreparingToOpen:
            expanded = true
            flickering = true
        case .Open:
            expanded = false
            flickering = false
        }
        
        updateJiggling()
    }
}
