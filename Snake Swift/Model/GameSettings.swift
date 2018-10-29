//
//  GameSettings.swift
//  Snake Swift
//
//  Created by Sam Louis Walker-Penn on 19/10/2018.
//  Copyright © 2018 Sam Louis Walker-Penn. All rights reserved.
//

import Foundation

struct GameSettings {
    var speed = 0.2
    var boardSize = BoardSize.large
    var watchMode = false
    
    enum BoardSize: Int {
        case tiny = 25
        case small = 36
        case medium = 64
        case large = 100
    }
}
