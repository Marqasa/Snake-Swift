//
//  Enumerations.swift
//  Snake Swift
//
//  Created by Sam Louis Walker-Penn on 09/10/2018.
//  Copyright © 2018 Sam Louis Walker-Penn. All rights reserved.
//

import UIKit

enum Direction: CaseIterable {
    case Up
    case Right
    case Down
    case Left
}

enum BoardSize: Int {
    case Tiny = 25
    case Small = 36
    case Medium = 64
    case Large = 100
}

enum BodyShape {
    case UpRight
    case UpDown
    case UpLeft
    case RightDown
    case RightLeft
    case DownLeft
}

enum TileType {
    case Wall
    case Head(Direction)
    case Body(Direction, BodyShape)
    case Tail(Direction)
    case Fruit
    case Empty
    indirect case Dual(TileType, TileType)
    
    // Returns tile direction if possible
    func direction() -> Direction? {
        switch self {
        case .Head(let direction), .Body(let direction, _), .Tail(let direction), .Dual(.Head(_), .Tail(let direction)):
            return direction
        default:
            return nil
        }
    }
}

extension TileType: Equatable {
    static func == (lhs: TileType, rhs: TileType) -> Bool {
        switch (lhs, rhs) {
        case(.Wall, .Wall): return true
        case(.Head, .Head): return true
        case(.Body, .Body): return true
        case(.Tail, .Tail): return true
        case(.Fruit, .Fruit): return true
        case(.Empty, .Empty): return true
        default:
            return false
        }
    }
}
