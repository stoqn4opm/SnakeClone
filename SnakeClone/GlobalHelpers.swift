//
//  GlobalHelpers.swift
//  SnakeClone
//
//  Created by Stoyan Stoyanov on 30.09.17.
//  Copyright © 2017 Stoyan Stoyanov. All rights reserved.
//

import SpriteKit

enum SnakeDirection: UInt16 {
    case up     = 0x7E
    case down   = 0x7D
    case left 	= 0x7B
    case right 	= 0x7C
}

extension CGSize {
    static var snakeSize: CGSize { return CGSize(width: 50, height: 50) }
}

extension SKSpriteNode {
    static var snakeBodyPart: SKSpriteNode {
        let bodyPart = SKSpriteNode(color: .green, size: .snakeSize)
        return bodyPart
    }
    
    static var snakeNewBodyPart: SKSpriteNode {
        let bodyPart = SKSpriteNode(color: .red, size: .snakeSize)
        return bodyPart
    }
}

extension CGPoint {
    static var normalizedMiddle: CGPoint { return CGPoint(x: 0.5, y: 0.5) }
    
    func offsetBy(_ point: CGPoint) -> CGPoint {
        return CGPoint(x: x + point.x, y: y + point.y)
    }

    var pointToLeft: CGPoint {
        return self.offsetBy(CGPoint(x:-CGSize.snakeSize.width, y: 0))
    }
    
    var pointToRight: CGPoint {
        return self.offsetBy(CGPoint(x:CGSize.snakeSize.width, y: 0))
    }
    
    var pointToUp: CGPoint {
        return self.offsetBy(CGPoint(x:0, y: CGSize.snakeSize.height))
    }
    
    var pointToDown: CGPoint {
        return self.offsetBy(CGPoint(x:0, y: -CGSize.snakeSize.height))
    }
}
