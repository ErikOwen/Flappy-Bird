//
//  GameOverScene.swift
//  Flappy Bird
//
//  Created by Erik Owen on 4/28/15.
//  Copyright (c) 2015 Erik Owen. All rights reserved.
//

import Foundation
import SpriteKit

class GameOverScene: SKScene {
    
    init(size: CGSize, score:Int) {
        
        super.init(size: size)
        
//        backgroundColor = SKColor.grayColor();
        let bgImage = SKSpriteNode(imageNamed: "game_over_bg.jpg");
        bgImage.position = CGPointMake(self.size.width / 2, self.size.height / 2);
        addChild(bgImage);
        
        let scoreLabel = SKLabelNode(fontNamed: "Chalkduster");
        scoreLabel.text = "Your score was " + String(score) + "!";
        scoreLabel.fontSize = 25;
        scoreLabel.fontColor = SKColor.blackColor();
        scoreLabel.position = CGPoint(x: size.width / 2, y: size.height / 2);
        addChild(scoreLabel);
        
        let playAgainLabel = SKLabelNode(fontNamed: "Chalkduster");
        playAgainLabel.text = "Tap Screen To Play Again";
        playAgainLabel.fontSize = 20;
        playAgainLabel.fontColor = SKColor.greenColor();
        playAgainLabel.position = CGPoint(x: size.width / 2, y: size.height / 4);
        playAgainLabel.name = "restartButton";
        addChild(playAgainLabel);
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event);
        
        let restartGameAction = SKAction.runBlock() {
            let reveal = SKTransition.flipHorizontalWithDuration(0.5);
            let restartGameScene = GameScene(size: self.size);
            self.view?.presentScene(restartGameScene, transition: reveal);
        }
        
        runAction(restartGameAction);
    }

    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}