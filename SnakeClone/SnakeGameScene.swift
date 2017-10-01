//
//  SnakeGameScene.swift
//  SnakeClone
//
//  Created by Stoyan Stoyanov on 30.09.17.
//  Copyright © 2017 Stoyan Stoyanov. All rights reserved.
//

import SpriteKit

//MARK: Scene Preparation

class SnakeGameScene: SKScene {
    
    fileprivate var currentDirection: SnakeDirection = .right
    fileprivate var snakeBody: [SKSpriteNode] = [.snakeBodyPart, .snakeBodyPart, .snakeBodyPart, .snakeBodyPart]
    fileprivate var snakeBodyPartsPositions: [CGPoint] = [.zero]
    
    fileprivate var oldUpdateTime: TimeInterval = 0
    
    fileprivate var _possiblePositionsForNewBodyParts: [CGPoint]?
    
    override func sceneDidLoad() {
        super.sceneDidLoad()
        prepareScene()
    }
    
    func prepareScene() {
        self.anchorPoint = .normalizedMiddle
        let snakeBodyPartsContainer = SKNode()
        snakeBodyPartsContainer.name = "snakeBodyPartsContainer"
        addChild(snakeBodyPartsContainer)
        for bodyPart in snakeBody {
            snakeBodyPartsContainer.addChild(bodyPart)
        }
        
        let newBodyPartsContainer = SKNode()
        newBodyPartsContainer.name = "newBodyPartsContainer"
        addChild(newBodyPartsContainer)
    }
}

//MARK: Main Loop

extension SnakeGameScene {
    
    override func update(_ currentTime: TimeInterval) {
        let delta: TimeInterval = 0.5
        if currentTime - oldUpdateTime > delta {
            oldUpdateTime = currentTime
            killSnakeIfNeeded()
            growSnakeIfNeeded()
            moveSnake()
            updatePositionsOfBodyParts()
            putNewBodyPartIfNeeded()
        }
    }
}

//MARK: - Grow Snake

extension SnakeGameScene {
    func growSnakeIfNeeded() {
        guard let snake = childNode(withName: "snakeBodyPartsContainer") else { return }
        guard let positionOfHead  = snakeBodyPartsPositions.first else { return }
        guard let collectablePart = childNode(withName: "//newBodyPart") else { return }
        
        
        let delta = CGPoint(x: abs(positionOfHead.x - collectablePart.position.x), y: abs(positionOfHead.y - collectablePart.position.y))
        if delta.x < CGSize.snakeSize.width / 2 {
            if delta.y < CGSize.snakeSize.height / 2 {
                let partForAppending: SKSpriteNode = .snakeBodyPart
                snake.addChild(partForAppending)
                snakeBody.append(partForAppending)
                collectablePart.removeFromParent()
            }
        }
    }
}

//MARK: - New Body Parts

extension SnakeGameScene {
    
    fileprivate func putNewBodyPartIfNeeded() {
        guard childNode(withName: "//newBodyPart") == nil else { return }
        putNewBodyParts()
    }
    
    private func putNewBodyParts() {
        
        guard let container = childNode(withName: "newBodyPartsContainer") else { return }
        
        let possiblePositions = positionsForNewBodyParts
        let randPositionIndex = arc4random_uniform(UInt32(possiblePositions.count))
        let randPosition = possiblePositions[Int(randPositionIndex)]
        
        let newBodyPart: SKSpriteNode = .snakeNewBodyPart
        newBodyPart.name = "newBodyPart"
        newBodyPart.position = randPosition
        container.addChild(newBodyPart)
    }
    
    fileprivate var positionsForNewBodyParts: [CGPoint] {
        
        if let alreadyCalculatedPositions = _possiblePositionsForNewBodyParts {
            return alreadyCalculatedPositions
        }
        
        var positions: [CGPoint] = []
        
        var xCoord: CGFloat = 0
        var yCoord: CGFloat = 0
        
        let lowerRightCorner = CGPoint(x: -size.width / 2, y: -size.height / 2)
        
        while lowerRightCorner.x + xCoord < size.width / 2 {
            
            while lowerRightCorner.y + yCoord < size.height / 2 {
                positions.append(CGPoint(x: lowerRightCorner.x + xCoord, y: lowerRightCorner.y + yCoord))
                yCoord += CGSize.snakeSize.height
            }
            yCoord = 0
            xCoord += CGSize.snakeSize.width
        }
        
        _possiblePositionsForNewBodyParts = positions
        return positions
    }
}

//MARK: - Game Over

extension SnakeGameScene {
    
    fileprivate func killSnakeIfNeeded() {
        if isSnakeRunOverItself || snakeReachedScreenBounds {
            removeSnakeFromScreen()
        }
    }
    
    private func removeSnakeFromScreen() {
        guard let snake = childNode(withName: "snakeBodyPartsContainer") else { return }
        snake.removeFromParent()
        snakeBody.removeAll()
    }
    
    private var isSnakeRunOverItself: Bool {
        for position in snakeBodyPartsPositions {
            let filteredPositions = snakeBodyPartsPositions.filter({ (examinedPoint) -> Bool in
                return examinedPoint.x == position.x && examinedPoint.y == position.y
            })
            
            if filteredPositions.count > 1 {
                return true
            }
        }
        return false
    }
    
    private var snakeReachedScreenBounds : Bool {
        guard let positionOfHead = snakeBodyPartsPositions.first else { return true }
        
        let leftBound   = -size.width / 2 // because anchor point is in center, same for the rest bounds
        if positionOfHead.x <= leftBound    { return true }
        
        let rightBound  = +size.width / 2
        if positionOfHead.x >= rightBound   { return true }
        
        let topBound    = +size.height / 2
        if positionOfHead.y >= topBound     { return true }
        
        let bottomBound = -size.height / 2
        if positionOfHead.y <= bottomBound  { return true }
        
        return false
    }
}

//MARK: - Player's Input

extension SnakeGameScene {
    
    override func keyDown(with event: NSEvent) {
        switch event.keyCode {
        case SnakeDirection.up.rawValue:    currentDirection = currentDirection != .down    ? .up    : .down
        case SnakeDirection.down.rawValue:  currentDirection = currentDirection != .up      ? .down  : .up
        case SnakeDirection.left.rawValue:  currentDirection = currentDirection != .right   ? .left  : .right
        case SnakeDirection.right.rawValue: currentDirection = currentDirection != .left    ? .right : .left
        default: break
        }
    }
}

//MARK: Snake Movement
extension SnakeGameScene {
    
    fileprivate func updatePositionsOfBodyParts() {
        for i in 0..<snakeBodyPartsPositions.count {
            if i < snakeBody.count {
                let bodyPart = snakeBody[i]
                bodyPart.position = snakeBodyPartsPositions[i]
            } else { snakeBodyPartsPositions.removeLast() }
        }
    }
    
    fileprivate func moveSnake() {
        guard let headPosition = snakeBodyPartsPositions.first else { return }
        switch currentDirection {
        case .up:
            snakeBodyPartsPositions.insert(headPosition.pointToUp, at: 0)
        case .down:
            snakeBodyPartsPositions.insert(headPosition.pointToDown, at: 0)
        case .left:
            snakeBodyPartsPositions.insert(headPosition.pointToLeft, at: 0)
        case .right:
            snakeBodyPartsPositions.insert(headPosition.pointToRight, at: 0)
        }
    }
}
