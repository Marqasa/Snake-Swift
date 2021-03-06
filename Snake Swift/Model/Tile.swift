//
//  TileState.swift
//  Snake Swift
//
//  Created by Sam Louis Walker-Penn on 07/10/2018.
//  Copyright © 2018 Sam Louis Walker-Penn. All rights reserved.
//

import UIKit

// Tile structure:
struct Tile {
    
    // Nested Kind enumeration. Conforms to the Equatable protocol:
    enum Kind: Equatable {
        case wall(UIColor)
        case head(Direction, UIColor)
        case body(Direction, BodyShape, UIColor)
        case tail(Direction, UIColor)
        case fruit(UIColor)
        case empty
        
        // Indirect case allows recursion:
        indirect case dual(Kind, Kind)
        
        // Get/set direction if possible:
        var direction: Direction? {
            get {
                switch self {
                case .head(let direction, _), .body(let direction, _, _), .tail(let direction, _): return direction
                case .dual(.head, .tail(let direction, _)): return direction // .dual case returns tail direction
                default: return nil
                }
            }
            set {
                switch self {
                case .head(_, let color): self = .head(newValue!, color)
                case .body(_, let shape, let color): self = .body(newValue!, shape, color)
                case .tail(_, let color): self = .tail(newValue!, color)
                default: break
                }
            }
        }
        
        // Get/set color if possible:
        var color: UIColor? {
            get {
                switch self {
                case .wall(let color), .head(_, let color), .body(_, _, let color), .tail(_, let color), .fruit(let color): return color
                case .dual(.head, .tail(_, let color)): return color // .dual case returns tail color
                case .dual(.head, .fruit(let color)): return color // .dual case returns fruit color
                default: return nil
                }
            }
            set {
                switch self {
                case .head(let direction, _): self = .head(direction, newValue!)
                case .body(let direction, let shape, _): self = .body(direction, shape, newValue!)
                case .tail(let direction, _): self = .tail(direction, newValue!)
                case .fruit: self = .fruit(newValue!)
                default: break
                }
            }
        }
        
        // Nested BodyShape enumeration:
        enum BodyShape {
            case upRight
            case upDown
            case upLeft
            case rightDown
            case rightLeft
            case downLeft
        }
        
        // Neccessary method to conform to the Equatable protocol:
        static func == (lhs: Kind, rhs: Kind) -> Bool {
            switch (lhs, rhs) {
            case(.wall, .wall): return true
            case(.head, .head): return true
            case(.body, .body): return true
            case(.tail, .tail): return true
            case(.fruit, .fruit): return true
            case(.empty, .empty): return true
            default:
                return false
            }
        }
    }
    
    // Tile properties:
    let col: Int
    let row: Int
    var kind: Kind
    
    init(_ col: Int, _ row: Int, _ kind: Kind) {
        self.col = col
        self.row = row
        self.kind = kind
    }
    
    init() {
        self.init(0, 0, .empty)
    }
}
