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
    
    // Subscript to access gameView[i]
    subscript(i: Int) -> TileView? {
        get { return gameView.indices.contains(i) ? gameView[i] : nil }
        set {
            if newValue != nil && gameView.indices.contains(i) {
                gameView[i] = newValue!
            }
        }
    }
    
    // Subscript to access gameView[i] using x and y values
    subscript(x: Int, y: Int) -> TileView? {
        get {
            let i = (x * size) + y
            return self[i]
        }
        set {
            let i = (x * size) + y
            self[i] = newValue
        }
    }
}
