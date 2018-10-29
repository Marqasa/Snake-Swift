//
//  GameState.swift
//  Snake Swift
//
//  Created by Sam Louis Walker-Penn on 07/10/2018.
//  Copyright © 2018 Sam Louis Walker-Penn. All rights reserved.
//

import UIKit

class GameState {
    
    // Stored properties
    let size: Int
    let col: Int
    let row = 1
    var board: [Tile]
    var snake = [Int]()
    var needsDisplay = Set<Int>()
    var emptyTiles = Set<Int>()
    var fruitID: Int?
    var fruitlessMoves = 0
    
    // Computed properties
    var headID: Int { return snake[0] }
    var tailID: Int { return snake[snake.endIndex - 1] }
    var head: Tile { return board[headID] }
    var tail: Tile { return board[tailID] }
    var fruit: Tile? { return fruitID != nil ? board[fruitID!] : nil }
    
    var headDirection: Direction {
        get { return head.kind.direction! }
        set { board[headID].kind.direction = newValue }
    }
    var headColor: UIColor {
        get { return head.kind.color! }
        set { board[headID].kind.color = newValue }
    }
    var tailDirection: Direction {
        get { return tail.kind.direction! }
        set { board[tailID].kind.direction = newValue }
    }
    var tailColor: UIColor {
        get { return tail.kind.color! }
        set { board[tailID].kind.color = newValue }
    }
    
    // Getter returns head Tile.Kind. Setter sets head Tile.Kind only if newValue is a .head case
    var headKind: Tile.Kind {
        get { return head.kind }
        set {
            switch newValue {
            case .head: board[headID].kind = newValue
            default: break
            }
        }
    }
    var tailKind: Tile.Kind {
        get { return tail.kind }
        set {
            switch newValue {
            case .tail: board[tailID].kind = newValue
            default: break
            }
        }
    }
    
    // Fruit direction relative to head:
    var fruitDirection: Direction? {
        if let fruit = fruit {
            if fruit.row < head.row && fruit.col == head.col { return .up }
            if fruit.row < head.row && fruit.col > head.col { return .upRight }
            if fruit.row == head.row && fruit.col > head.col { return .right }
            if fruit.row > head.row && fruit.col > head.col { return .downRight }
            if fruit.row > head.row && fruit.col == head.col { return .down }
            if fruit.row > head.row && fruit.col < head.col { return .downLeft }
            if fruit.row == head.row && fruit.col < head.col { return .left }
            if fruit.row < head.row && fruit.col < head.col { return .upLeft }
        }
        return nil
    }
    
    // Fruit distance from head:
    var fruitDistance: Int? {
        if fruit != nil {
            let rowDistance = abs(fruit!.row - head.row)
            let colDistance = abs(fruit!.col - head.col)
            return rowDistance + colDistance
        } else { return nil }
    }
    
    // Result of update function:
    enum Result {
        case gameWon
        case fruitEaten
        case ok
        case gameOver
    }
    
    // Subscript to access board[i]
    subscript(i: Int) -> Tile? {
        get { return board.indices.contains(i) ? board[i] : nil }
        set { if newValue != nil && board.indices.contains(i) { board[i] = newValue! } }
    }
    
    // Subscript to access board[i] using x and y values
    subscript(x: Int, y: Int) -> Tile? {
        get {
            let i = (x * col) + y
            return self[i]
        }
        set {
            let i = (x * col) + y
            self[i] = newValue
        }
    }
    
    init(size: Int) {
        self.size = size
        self.col = Int(sqrt(Double(size)))
        self.board = []
        
        // Fill the board with tiles
        for x in 0..<col {
            for y in 0..<col {
                
                // Make a new tile and add it the the board
                makeTile(x, y)
            }
        }
        
        // Add the snake
        addSnake()
        
        // Add a new fruit
        newFruit()
    }
    
    init(fromState state: GameState) {
        self.size = state.size
        self.col = state.col
        self.board = state.board
        self.snake = state.snake
        self.needsDisplay = state.needsDisplay
        self.emptyTiles = state.emptyTiles
        self.fruitID = state.fruitID
        self.fruitlessMoves = state.fruitlessMoves
    }
    
    func makeTile(_ x: Int, _ y: Int) {
        func getKind() -> Tile.Kind {
            if y == 0 || x == 0 || x == col - 1 || y == col - 1 {
                return Tile.Kind.wall(UIColor.black)
            } else {
                emptyTiles.insert((x * col) + y)
                return Tile.Kind.empty
            }
        }
        board.append(Tile(x, y, getKind()))
    }
    
    // Update game state (move/grow the snake)
    func update() -> Result {
        fruitlessMoves += 1
        var result: Result = .ok
        
        // Update old and new tile properties:
        func updateTileProperties(from oldID: Int, to newID: Int) {
            
            // Check oldID tile kind:
            switch board[oldID].kind {
                
            case let .head(headDirection, headColor):
                
                // Combine oldID with newID using .dual tile kinds where necessary:
                switch board[newID].kind {
                    
                case let .tail(tailDirection, tailColor):
                    board[newID].kind = .dual(.head(headDirection, headColor), .tail(tailDirection, tailColor))
                case let .fruit(fruitColor):
                    board[newID].kind = .dual(.head(headDirection, fruitColor), .fruit(fruitColor))
                case .wall, .body:
                    //TODO: Dual case could be used for crash graphics
                    result = .gameOver
                default:
                    board[newID].kind = .head(headDirection, headColor)
                    emptyTiles.remove(newID)
                }
                
            case .body:
                
                // Set newID to .body with bodyShape. Keep direction and color the same.
                let color = board[newID].kind.color!
                switch board[newID].kind.direction! {
                case .up:
                    if oldID == newID + col {
                        board[newID].kind = .body(.up, .upRight, color)
                    } else if oldID == newID + row {
                        board[newID].kind = .body(.up, .upDown, color)
                    } else {
                        board[newID].kind = .body(.up, .upLeft, color)
                    }
                case .right:
                    if oldID == newID - row {
                        board[newID].kind = .body(.right, .upRight, color)
                    } else if oldID == newID - col {
                        board[newID].kind = .body(.right, .rightLeft, color)
                    } else {
                        board[newID].kind = .body(.right, .rightDown, color)
                    }
                case .down:
                    if oldID == newID + col {
                        board[newID].kind = .body(.down, .rightDown, color)
                    } else if oldID == newID - col {
                        board[newID].kind = .body(.down, .downLeft, color)
                    } else {
                        board[newID].kind = .body(.down, .upDown, color)
                    }
                case .left:
                    if oldID == newID + row {
                        board[newID].kind = .body(.left, .downLeft, color)
                    } else if oldID == newID + col {
                        board[newID].kind = .body(.left, .rightLeft, color)
                    } else {
                        board[newID].kind = .body(.left, .upLeft, color)
                    }
                default: fatalError("Direction invalid.")
                }
                
            case .tail:
                
                switch headKind {
                    
                // If the snake ate a piece of fruit, grow the snake:
                case let .dual(.head(headDirection, headColor), .fruit):
                    headKind = .head(headDirection, headColor)
                    snake.append(oldID)
                    fruitID = nil
                    fruitlessMoves = 0
                    
                    if emptyTiles.isEmpty {
                        result = .gameWon
                    } else {
                        result = .fruitEaten
                    }
                    
                // Else move the tail:
                default:
                    let direction = board[newID].kind.direction!
                    let color = board[newID].kind.color!
                    board[newID].kind = .tail(direction, color)
                    board[oldID].kind = .empty
                    emptyTiles.insert(oldID)
                }
                
            case let .dual(.head(headDirection, headColor), .tail):
                let tailDirection = board[newID].kind.direction!
                let tailColor = board[newID].kind.color!
                board[newID].kind = .tail(tailDirection, tailColor)
                board[oldID].kind = .head(headDirection, headColor)
            default: break
            }
            needsDisplay.insert(oldID)
            needsDisplay.insert(newID)
        }
        
        // Move the snake and update properties for all affected tiles:
        for (i, tileID) in snake.enumerated() {
            
            // Update snake[i] based on its direction:
            switch board[tileID].kind.direction! {
            case .up:       snake[i] -= row
            case .right:    snake[i] += col
            case .down:     snake[i] += row
            case .left:     snake[i] -= col
            default:        fatalError("Direction invalid.")
            }
            
            // Update properties for old and new tiles:
            updateTileProperties(from: tileID, to: snake[i])
        }
        return result
    }
    
    // Add the snake
    private func addSnake() {
        let headID = (col * 3) + row
        snake.append(headID)
        board[headID].kind = .head(.right, UIColor.red)
        emptyTiles.remove(headID)
        
        let bodyID = headID - col
        snake.append(bodyID)
        board[bodyID].kind = .body(.right, .rightLeft, UIColor.red)
        emptyTiles.remove(bodyID)
        
        let tailID = bodyID - col
        snake.append(tailID)
        board[tailID].kind = .tail(.right, UIColor.red)
        emptyTiles.remove(tailID)
    }
    
    // Add a new fruit to the board and return its ID
    func newFruit() {
        
        // Only add a new fruit if there is still space on the board
        if !emptyTiles.isEmpty {
            
            // Choose an empty tile at random and spawn the fruit there
            fruitID = emptyTiles.randomElement()
            let hue = CGFloat(arc4random_uniform(100)) / 100
            let color = UIColor(hue: hue, saturation: 0.5, brightness: 0.9, alpha: 1)
            board[fruitID!].kind = .fruit(color)
            emptyTiles.remove(fruitID!)
            needsDisplay.insert(fruitID!)
            
        } else {
            fruitID = nil
        }
    }
    
    // Shrink the snake down to 3 segments and spawn a new fruit
    func restart() {
        for (i, tileID) in snake.enumerated() {
            if i == 2 {
                let direction = board[tileID].kind.direction!
                let color = board[tileID].kind.color!
                board[tileID].kind = .tail(direction, color)
            } else if i > 2 {
                board[tileID].kind = .empty
                emptyTiles.insert(tileID)
            }
            needsDisplay.insert(tileID)
        }
        snake.removeSubrange(3..<snake.endIndex)
        newFruit()
    }
}
