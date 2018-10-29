//
//  GameView.swift
//  Snake Swift
//
//  Created by Sam Louis Walker-Penn on 12/10/2018.
//  Copyright © 2018 Sam Louis Walker-Penn. All rights reserved.
//

import UIKit

class GameView: UIView {
    private let vectors: Int
    private let tileSize: CGFloat
    private let yPos: CGFloat
    var gameView = [TileView]()
    
    init(bounds: CGRect, state: GameState) {
        vectors = state.col
        tileSize = bounds.width / CGFloat(vectors)
        yPos = bounds.height / 5
        super.init(frame: CGRect(x: 0, y: yPos, width: bounds.width, height: bounds.width))
        for tile in state.board {
            makeTileView(tile)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    
    func makeTileView(_ tile: Tile) {
        let tileView = TileView(frame: CGRect(x: CGFloat(tile.col) * tileSize, y: CGFloat(tile.row) * tileSize,
                                              width: tileSize, height: tileSize))
        tileView.tile = tile
        gameView.append(tileView)
        self.addSubview(tileView)
    }
}
