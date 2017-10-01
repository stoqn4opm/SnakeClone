//
//  ViewController.swift
//  SnakeClone
//
//  Created by Stoyan Stoyanov on 30.09.17.
//  Copyright © 2017 Stoyan Stoyanov. All rights reserved.
//

import Cocoa
import SpriteKit
import GameplayKit

class ViewController: NSViewController {

    @IBOutlet var skView: SKView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        if let view = self.skView {
            // Load the SKScene from 'GameScene.sks'
            
            let snakeScene = SnakeGameScene(size: CGSize(width: 500, height: 500))
            snakeScene.scaleMode = .aspectFit
            view.presentScene(snakeScene)
            
            view.ignoresSiblingOrder = true
            view.showsFPS = true
            view.showsNodeCount = true
            
            view.window?.setFrame(NSRect(origin: .zero, size: CGSize(width: 600, height: 600)), display: true)
        }
    }
}

