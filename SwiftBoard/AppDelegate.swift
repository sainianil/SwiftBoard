//
//  AppDelegate.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-09-15.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var rootViewModel: RootViewModel?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?) -> Bool {
        if let viewController = window?.rootViewController as? ViewController {
            let viewModels: [ItemViewModel] = [
                AppViewModel(name: "App 1", color: UIColor.green),
                AppViewModel(name: "App 2", color: UIColor.blue),
                FolderViewModel(name: "Folder 1", viewModels: [
                    AppViewModel(name: "App 5", color: UIColor.purple),
                    AppViewModel(name: "App 6", color: UIColor.red),
                    AppViewModel(name: "App 7", color: UIColor.yellow),
                    AppViewModel(name: "App 8", color: UIColor.magenta),
                    AppViewModel(name: "App 9", color: UIColor.red),
                    AppViewModel(name: "App 10", color: UIColor.purple),
                    AppViewModel(name: "App 11", color: UIColor.blue),
                    ]),
                FolderViewModel(name: "Folder 2", viewModels: [
                    AppViewModel(name: "App 4", color: UIColor.darkGray)
                    ]),
                AppViewModel(name: "App 3", color: UIColor.cyan),
                AppViewModel(name: "App 12", color: UIColor.magenta),
                AppViewModel(name: "App 13", color: UIColor.orange),
                AppViewModel(name: "App 14", color: UIColor.brown),
                AppViewModel(name: "App 15", color: UIColor.blue),
                AppViewModel(name: "App 16", color: UIColor.red)
            ]
            
            rootViewModel = RootViewModel(viewModels: viewModels)
            viewController.rootViewModel = rootViewModel
        }
        
        return true
    }
    
    // The jiggling animation will be automatically killed if the app loses active status, so I think it's better
    // to treat that as disabling editing mode. Then the view model state and what's happening on screen match.
    func applicationWillResignActive(_ application: UIApplication) {
        rootViewModel?.editingModeEnabled = false
    }
}

