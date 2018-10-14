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
        
        // Nested BodyShape enumeration:
        enum BodyShape {
            case upRight
            case upDown
            case upLeft
            case rightDown
            case rightLeft
            case downLeft
        }
        
        // Returns tile direction if available:
        func direction() -> Direction? {
            switch self {
            case .head(let direction, _), .body(let direction, _, _), .tail(let direction, _):
                return direction
            case .dual(.head, .tail(let direction, _)): // .dual case returns tail direction
                return direction
            default:
                return nil
            }
        }
        
        // Returns tile color if available:
        func color() -> UIColor? {
            switch self {
            case .wall(let color), .head(_, let color), .body(_, _, let color), .tail(_, let color), .fruit(let color):
                return color
            case .dual(.head, .tail(_, let color)): // .dual case returns tail color
                return color
            case .dual(.head, .fruit(let color)): // .dual case returns fruit color
                return color
            default:
                return nil
            }
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
    var kind = Kind.empty
    var col = 0, row = 0
}
