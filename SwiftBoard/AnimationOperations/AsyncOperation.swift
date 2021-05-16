//
//  AsyncOperation.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-12-02.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import Foundation

class AsyncOperation: Operation {
    private var _executing = false
    override var isExecuting: Bool {
        get {
            return _executing
        }
        set {
            willChangeValue(forKey: "isExecuting")
            _executing = newValue
            didChangeValue(forKey: "isExecuting")
        }
    }
    
    private var _finished = false
    override var isFinished: Bool {
        get {
            return _finished
        }
        set {
            willChangeValue(forKey: "isFinished")
            _finished = newValue
            didChangeValue(forKey: "isFinished")
        }
    }
}
