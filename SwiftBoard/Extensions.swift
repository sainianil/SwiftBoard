//
//  Extensions.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-11-24.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import UIKit

extension Int {
    func toIndexPath() -> IndexPath {
        return IndexPath(item: self, section: 0)
    }
}
