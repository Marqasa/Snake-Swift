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

enum BodyShape {
    case upRight
    case upDown
    case upLeft
    case rightDown
    case rightLeft
    case downLeft
}

enum TileType {
    case wall(UIColor)
    case head(Direction, UIColor)
    case body(Direction, BodyShape, UIColor)
    case tail(Direction, UIColor)
    case fruit(UIColor)
    case empty
    indirect case dual(TileType, TileType)
    
    // Returns tile direction if possible
    func direction() -> Direction? {
        switch self {
        case .head(let direction, _), .body(let direction, _, _), .tail(let direction, _), .dual(.head(_), .tail(let direction, _)):
            return direction
        default:
            return nil
        }
    }
    
    // Returns tile color if possible
    func color() -> UIColor? {
        switch self {
        case .head(_, let color), .body(_, _, let color), .tail(_, let color), .dual(.head(_, _), .tail(_, let color)):
            return color
        default:
            return nil
        }
    }
}

extension TileType: Equatable {
    static func == (lhs: TileType, rhs: TileType) -> Bool {
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
