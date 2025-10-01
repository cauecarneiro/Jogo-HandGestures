//
//  PauseNode.swift
//  Chroma Knight
//
//  Created by Thiago Parisotto on 09/06/24.
//

import Foundation
import SpriteKit

class PauseNode: SKNode {
    var pauseButton: SKSpriteNode
    var resumeButton: SKSpriteNode
    var homeButton: SKSpriteNode
    var blackBackground: SKSpriteNode
    
    init(size: CGSize) {
        
        pauseButton = SKSpriteNode(imageNamed: "PauseButton")
        pauseButton.scale(to: CGSize(width: 48, height: 48))
        pauseButton.position = CGPoint(x: size.width - 70, y: size.height - 70)
        pauseButton.name = "pauseButton"
        pauseButton.zPosition = 1
        
        let pairOffset: CGFloat = 110
        resumeButton = SKSpriteNode(imageNamed: "resumeButton")
        resumeButton.scale(to: CGSize(width: 120, height: 120))
        resumeButton.position = CGPoint(x: size.width/2 + pairOffset, y: size.height/2)
        resumeButton.zPosition = 1
        resumeButton.name = "resumeButton"
        
        homeButton = SKSpriteNode(imageNamed: "homeButton")
        homeButton.scale(to: CGSize(width: 120, height: 120))
        homeButton.position = CGPoint(x: size.width/2 - pairOffset, y: size.height/2)
        homeButton.zPosition = 1
        homeButton.name = "homeButton"
        
        
        blackBackground = SKSpriteNode(color: .black, size: size)
        blackBackground.position = CGPoint(x: size.width/2, y: size.height/2)
        blackBackground.zPosition = 0
        blackBackground.alpha = 0.3
        
        super.init()
        
        self.addChild(pauseButton)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    
    func pauseButtonPressed() {
        self.pauseButton.texture = SKTexture(imageNamed: "PauseButtonPressed")
        pauseButton.run(waitForAnimation) {
            UserConfig.shared.changePause()
            self.pauseButton.texture = SKTexture(imageNamed: "PauseButton")
            self.resumeButton.texture = SKTexture(imageNamed: "resumeButton")
            if(UserConfig.shared.userPause) {
                self.addChild(self.resumeButton)
                self.addChild(self.homeButton)
                self.addChild(self.blackBackground)
            } else {
                self.blackBackground.removeFromParent()
                self.resumeButton.removeFromParent()
                self.homeButton.removeFromParent()
            }
        }
    }
   
    func homeButtonPressed(scene: SKScene) {
        animateButton(button: homeButton)
        let sequence = SKAction.sequence([waitForAnimation, fadeOut])
        scene.run(sequence) {
            UserConfig.shared.changePause()
            let menuScene = MenuScene(size: scene.size)
            menuScene.scaleMode = scene.scaleMode
            scene.view?.presentScene(menuScene)
        }
    }
    
}
