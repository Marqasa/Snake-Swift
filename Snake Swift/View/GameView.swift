//
//  GameView.swift
//  Snake Swift
//
//  Created by Sam Louis Walker-Penn on 12/10/2018.
//  Copyright © 2018 Sam Louis Walker-Penn. All rights reserved.
//

import Foundation

struct GameView {
    let size: Int
    var gameView: [TileView]
    
    init(size: Int) {
        self.size = size
        self.gameView = Array(repeating: TileView(), count: size * size)
    }
    
    subscript(i: Int) -> TileView {
        get {
            return gameView[i]
        }
        set {
            gameView[i] = newValue
        }
    }
    
    subscript(x: Int, y: Int) -> TileView {
        get {
            let id = (x * size) + y
            return gameView[id]
        }
        set {
            let id = (x * size) + y
            gameView[id] = newValue
        }
    }
}
