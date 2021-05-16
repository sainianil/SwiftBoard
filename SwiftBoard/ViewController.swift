//
//  ViewController.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-09-15.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var rootCollectionView: RootCollectionView!
    var rootViewModel: RootViewModel?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rootCollectionView.rootViewModel = rootViewModel
    }
    
    @IBAction func handleHomeButton(sender: UIButton) {
        rootViewModel?.editingModeEnabled = false
    }
}














