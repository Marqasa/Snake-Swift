//
//  GameView.swift
//  Snake Swift
//
//  Created by Sam Louis Walker-Penn on 12/10/2018.
//  Copyright © 2018 Sam Louis Walker-Penn. All rights reserved.
//

import UIKit

struct GameView {
    let size: Int
    let vectors: Int
    let tileSize: CGFloat
    let yPos: CGFloat
    var gameView: [TileView]
    
    init(size: Int, bounds: CGRect) {
        self.size = size
        self.vectors = Int(sqrt(Double(size)))
        self.gameView = Array(repeating: TileView(), count: size)
        self.tileSize = bounds.width / CGFloat(vectors)
        self.yPos = bounds.height / 5
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
            let i = (x * vectors) + y
            return self[i]
        }
        set {
            let i = (x * vectors) + y
            self[i] = newValue
        }
    }
    
    mutating func makeTileView(_ x: Int, _ y: Int, _ tile: Tile) -> TileView {
        let tileView = TileView(frame: CGRect(x: CGFloat(x) * tileSize, y: (CGFloat(y) * tileSize) + yPos, width: tileSize, height: tileSize))
        tileView.tile = tile
        self[x, y] = tileView
        return tileView
    }
}
