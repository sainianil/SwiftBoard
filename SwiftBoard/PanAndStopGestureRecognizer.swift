//
//  PanAndStopGestureRecognizer.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-11-10.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import UIKit

class PanAndStopGestureRecognizer: UIPanGestureRecognizer {
    let stopAfterSecondsWithoutMovement: Double
    
    private var stopTimer: Timer?
    private var stopFunction:(PanAndStopGestureRecognizer) -> ()
    private var lastLocation:CGPoint
    
    init(target:AnyObject, action:Selector, stopAfterSecondsWithoutMovement stopAfterSeconds:Double, stopFunction stopFn: @escaping (PanAndStopGestureRecognizer) -> ()) {
        stopAfterSecondsWithoutMovement = stopAfterSeconds
        stopFunction = stopFn
        lastLocation = CGPoint(x:0, y:0)
        
        super.init(target: target, action: action)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)
        stopTimer?.invalidate()
        
        if state == .began || state == .changed {
            lastLocation = location(in: view!)
            stopTimer = Timer.scheduledTimer(timeInterval: stopAfterSecondsWithoutMovement, target: self, selector: Selector(("callStopFunction")), userInfo: nil, repeats: false)
        }
    }
    
    override func reset() {
        super.reset()
        stopTimer?.invalidate()
    }
    
    func callStopFunction() {
        stopFunction(self)
    }
}
