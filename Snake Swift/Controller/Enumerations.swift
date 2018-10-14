//
//  Enumerations.swift
//  Snake Swift
//
//  Created by Sam Louis Walker-Penn on 09/10/2018.
//  Copyright © 2018 Sam Louis Walker-Penn. All rights reserved.
//

import UIKit

enum Direction: CaseIterable {
    case up
    case right
    case down
    case left
}

enum BoardSize: Int {
    case tiny = 25
    case small = 36
    case medium = 64
    case large = 100
}
