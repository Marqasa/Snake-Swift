//
//  PathList.swift
//  Snake Swift
//
//  Created by Sam Louis Walker-Penn on 03/11/2018.
//  Copyright © 2018 Sam Louis Walker-Penn. All rights reserved.
//

import Foundation

class PathList {
    var first: Path?
    var isEmpty: Bool { return first == nil }
    
    // Insert path in order of absolute fruit distance
    func insertInOrder(path: Path) {
        if first == nil || first?.absFruitDistance ?? 0 >= path.absFruitDistance {
            first = Path(state: path.state, route: path.route, next: first)
            return
        }

        var current = first

        while current?.next != nil && current?.next?.absFruitDistance ?? 0 < path.absFruitDistance {
            current = current?.next
        }

        current?.next = Path(state: path.state, route: path.route, next: current?.next)
    }
    
    // Delete path by ID
    func delete(id: Int) {
        if first?.id == id {
            first = first?.next
            return
        }

        var prev: Path?
        var current = first

        while current?.next != nil && current?.id != id {
            prev = current
            current = current?.next
        }

        prev?.next = current?.next
    }
    
    // Insert path at the end of the list
    func insert(path: Path) {
        if first == nil {
            first = path
            return
        }
        
        var current = first
        
        while current?.next != nil {
            current = current?.next
        }
        
        current?.next = path
    }
}
