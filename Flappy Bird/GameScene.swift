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

extension CGFloat {
    func degrees_to_radians() -> CGFloat {
        return CGFloat(M_PI) * self / 180.0;
    }
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    /*Flappy Bird Sprite*/
    var bird: SKSpriteNode!;
    
    /*Background*/
    var background: SKNode!;
    let background_speed = 100.0;
    
    /*Time Values*/
    var delta = NSTimeInterval(0);
    var last_update_time = NSTimeInterval(0);
    
    let pipe_origin_x: CGFloat = 382.0;
    
    /*Floor Height*/
    let floor_distance: CGFloat = 72.0;
    
    /*Physics categories*/
    let FSBoundaryCategory: UInt32 = 1 << 0;
    let FSPlayerCategory: UInt32 = 1 << 1;
    let FSPipeCategory: UInt32 = 1 << 2;
    let FSGapCategory: UInt32 = 1 << 3;
    
    /*Instructions*/
    var instructions: SKSpriteNode!
    
    /*Different game states*/
    enum FSGameState: Int {
        case FSGameStateStarting
        case FSGameStatePlaying
        case FSGameStateEnded
    }
    
    /*Current game state*/
    var state:FSGameState = .FSGameStateStarting;
    
    override func didMoveToView(view: SKView) {
        initWorld();
        initBackground();
        initBird();
        initHUD();
        
        runAction(SKAction.repeatActionForever((SKAction.sequence([SKAction.waitForDuration(2.0), SKAction.runBlock{self.initPipes()}]))));
    }
    
    func initWorld() {
        physicsWorld.contactDelegate = self;
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -5.0);
        physicsBody = SKPhysicsBody(edgeLoopFromRect: CGRect(x: 0.0, y: floor_distance, width: size.width, height: size.height - floor_distance));
        
        physicsBody?.categoryBitMask = FSBoundaryCategory;
        physicsBody?.collisionBitMask = FSPlayerCategory;
    }
    
    func initBird() {
        bird = SKSpriteNode(imageNamed: "turtle1");
        bird.position = CGPoint(x: 100.0, y: CGRectGetMidY(frame));
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.width / 2.5);
        bird.physicsBody?.categoryBitMask = FSPlayerCategory;
        bird.physicsBody?.contactTestBitMask = FSPipeCategory | FSGapCategory | FSBoundaryCategory;
        bird.physicsBody?.collisionBitMask = FSPipeCategory | FSBoundaryCategory;
        bird.physicsBody?.affectedByGravity = false;
        bird.physicsBody?.allowsRotation = false;
        bird.physicsBody?.restitution = 0.0;
        bird.zPosition = 50;
        
        self.addChild(bird);
        
        let texture1 = SKTexture(imageNamed: "turtle1");
        let texture2 = SKTexture(imageNamed: "turtle2");
        let textures = [texture1, texture2];
        
        bird.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(textures, timePerFrame: 0.1)));
    }
    
    func initBackground() {
        background = SKNode();
        addChild(background);
        
        for i in 0...2 {
            let tile = SKSpriteNode(imageNamed: "bg");
            tile.anchorPoint = CGPointZero
            tile.position = CGPoint(x: CGFloat(i) * 640.0, y: 0.0)
            tile.name = "bg"
            tile.zPosition = 10
            background.addChild(tile)
        }
    }
    
    func initHUD() {
        instructions = SKSpriteNode(imageNamed: "TapToStart");
        instructions.position = CGPoint(x: CGRectGetMidX(frame), y: CGRectGetMidY(frame));
        instructions.zPosition = 50;
        
        addChild(instructions);
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
    
    func initPipes() {
        let screenSize: CGRect = UIScreen.mainScreen().bounds;
        let isWideScreen: Bool = (screenSize.height > 480);
        let bottom = getPipeWithSize(CGSize(width: 62, height: Float.range(40, max: isWideScreen ? 360 : 280)), side: false);
        bottom.position = convertPoint(CGPoint(x: pipe_origin_x, y: CGRectGetMinY(frame) + bottom.size.height / 2 + floor_distance), toNode: background);
        bottom.physicsBody = SKPhysicsBody(rectangleOfSize: bottom.size);
        bottom.physicsBody?.categoryBitMask = FSPipeCategory;
        bottom.physicsBody?.contactTestBitMask = FSPlayerCategory;
        bottom.physicsBody?.collisionBitMask = FSPlayerCategory;
        bottom.physicsBody?.dynamic = false;
        bottom.zPosition = 20;
        background.addChild(bottom);
        
        let threshold = SKSpriteNode(color: UIColor.clearColor(), size: CGSize(width: 10, height: 100));
        threshold.position = convertPoint(CGPoint(x: pipe_origin_x, y: floor_distance + bottom.size.height + threshold.size.height / 2), toNode: background);
        threshold.physicsBody = SKPhysicsBody(rectangleOfSize: threshold.size);
        threshold.physicsBody?.categoryBitMask = FSGapCategory;
        threshold.physicsBody?.contactTestBitMask = FSPlayerCategory;
        threshold.physicsBody?.collisionBitMask = 0;
        threshold.physicsBody?.dynamic = false;
        threshold.zPosition = 20;
        background.addChild(threshold);
        
        let topSize = size.height - bottom.size.height - threshold.size.height - floor_distance;
        
        let top = getPipeWithSize(CGSize(width: 62, height: topSize), side: true);
        top.position = convertPoint(CGPoint(x: pipe_origin_x, y: CGRectGetMaxY(frame) - top.size.height / 2), toNode: background);
        top.physicsBody = SKPhysicsBody(rectangleOfSize: top.size);
        top.physicsBody?.categoryBitMask = FSPipeCategory;
        top.physicsBody?.contactTestBitMask = FSPlayerCategory;
        top.physicsBody?.collisionBitMask = FSPlayerCategory;
        top.physicsBody?.dynamic = false;
        top.zPosition = 20;
        background.addChild(top);
        
    }
    
    func getPipeWithSize(size: CGSize, side: Bool) -> SKSpriteNode {
        let textureSize = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height);
        let backgroundCGImage = UIImage(named: "pipe")!.CGImage;
        
        UIGraphicsBeginImageContext(size);
        let context = UIGraphicsGetCurrentContext();
        CGContextDrawTiledImage(context, textureSize, backgroundCGImage);
        let tiledBackground = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        let backgroundTexture = SKTexture(CGImage: tiledBackground.CGImage);
        let pipe = SKSpriteNode(texture: backgroundTexture);
        pipe.zPosition = 1;
        
        let cap = SKSpriteNode(imageNamed: "bottom");
        cap.position = CGPoint(x: 0.0, y: side ? -pipe.size.height / 2 + cap.size.height / 2 : pipe.size.height / 2 - cap.size.height / 2);
        cap.zPosition = 5;
        pipe.addChild(cap);
        
        if(side == true) {
            let angle:CGFloat = 180.0;
            cap.zRotation = angle.degrees_to_radians();
        }
        
        return pipe;
    }
    
    func gameOver() {
        state = .FSGameStateEnded;
        
        bird.physicsBody?.categoryBitMask = 0;
        bird.physicsBody?.collisionBitMask = FSBoundaryCategory;
    }
    
    func restartGame() {
        
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        let collision: UInt32 = (contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask);
        
        if(collision == (FSPlayerCategory | FSBoundaryCategory)) {

            /*Only ends game if bird hits bottom floor*/
            if(bird.position.y < 150) {
                gameOver();
            }
        }
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        if(state == .FSGameStateStarting) {
            state = .FSGameStatePlaying;
            instructions.hidden = true;
            
            bird.physicsBody?.affectedByGravity = true;
            bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 25));
        }
        else if(state == .FSGameStatePlaying) {
            bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 25));
            runAction(SKAction.playSoundFileNamed("swoosh.wav", waitForCompletion: false))
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        delta = (last_update_time == 0.0) ? 0.0 : currentTime - last_update_time;
        last_update_time = currentTime;

        moveBackground();
        
        let velocity_x = bird.physicsBody?.velocity.dx;
        let velocity_y = bird.physicsBody?.velocity.dy;
        
        if bird.physicsBody?.velocity.dy > 280 {
            bird.physicsBody?.velocity = CGVector(dx: velocity_x!, dy: 280);
        }
        
        bird.zRotation = Float.clamp(-1, max: 0.0, value: velocity_y! * (velocity_y < 0 ? 0.003 : 0.001));
    }
}
