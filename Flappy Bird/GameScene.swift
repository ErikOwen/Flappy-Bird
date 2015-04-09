//
//  GameScene.swift
//  Flappy Bird
//
//  Created by Erik Owen on 4/08/15.
//  Copyright (c) 2015 Erik Owen. All rights reserved.
//


import SpriteKit

// Math Helpers
extension Float {
    static func clamp(min: CGFloat, max: CGFloat, value: CGFloat) -> CGFloat {
        if(value > max) {
            return max
        } else if(value < min) {
            return min
        } else {
            return value
        }
    }
    
    static func range(min: CGFloat, max: CGFloat) -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF) * (max - min) + min
    }
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // Background
    var background: SKNode!;
    let background_speed = 100.0;
    
    // Time Values
    var delta = NSTimeInterval(0);
    var last_update_time = NSTimeInterval(0);
    
    
    // MARK: - SKScene Initializacion
    override func didMoveToView(view: SKView) {
        initBackground();
    }
    
    // MARK: - Init Physics
    func initWorld() {
        
    }
    
    // MARK: - Init Bird
    func initBird() {
        
    }
    
    // MARK: - Background Functions
    func initBackground() {
        background = SKNode();
        addChild(background);
        
        for i in 0...2 {
            let tile = SKSpriteNode(imageNamed: "bg")
            tile.anchorPoint = CGPointZero
            tile.position = CGPoint(x: CGFloat(i) * 640.0, y: 0.0)
            tile.name = "bg"
            tile.zPosition = 10
            background.addChild(tile)
        }
    }
    
    func moveBackground() {
        let posX = -background_speed * delta;
        background.position = CGPoint(x: background.position.x + CGFloat(posX), y: 0.0);
        
        background.enumerateChildNodesWithName("bg") { (node, stop) in
            let background_screen_position = self.background.convertPoint(node.position, toNode: self);
            
            if background_screen_position.x <= -node.frame.size.width {
                node.position = CGPoint(x: node.position.x + (node.frame.size.width * 2), y: node.position.y);
            }
            
        }
    }
    
    // MARK: - Pipes Functions
    func initPipes() {

    }
    
    func getPipeWithSize(size: CGSize, side: Bool) -> SKSpriteNode {
        // This function needs to return a SKSpriteNode otherwise a error will appear
        // to prevent the error while we add the new content just return an empty pipe for now
        let pipe:SKSpriteNode = SKSpriteNode()
        return pipe
    }
    
    // MARK: - Game Over helpers
    func gameOver() {
        
    }
    
    func restartGame() {
        
    }
    
    // MARK: - SKPhysicsContactDelegate
    func didBeginContact(contact: SKPhysicsContact!) {
        
    }
    
    // MARK: - Touch Events
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        /* Called when a touch begins */
    }
    
    // MARK: - Frames Per Second
    override func update(currentTime: CFTimeInterval) {
        delta = (last_update_time == 0.0) ? 0.0 : currentTime - last_update_time;
        last_update_time = currentTime;

        moveBackground();
    }
}
