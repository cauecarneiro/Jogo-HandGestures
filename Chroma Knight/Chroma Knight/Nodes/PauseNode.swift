//
//  PauseNode.swift
//  Chroma Knight
//
//  Created by Thiago Parisotto on 09/06/24.
//

import Foundation
import SpriteKit

class PauseNode: SKNode {
    var pauseButton: SKShapeNode
    var resumeButton: SKSpriteNode
    var homeButton: SKSpriteNode
    var blackBackground: SKSpriteNode
    
    init(size: CGSize) {
        
        let diameter: CGFloat = 48
        let circle = SKShapeNode(circleOfRadius: diameter / 2)
        circle.fillColor = SKColor(white: 1.0, alpha: 0.15) // leve transparência
        circle.strokeColor = SKColor(white: 1.0, alpha: 0.3)
        circle.lineWidth = 2
        circle.position = CGPoint(x: size.width - 70, y: size.height - 70)
        circle.name = "pauseButton"
        circle.zPosition = 1
        
        // Barras do ícone de pause
        let barWidth = diameter * 0.16
        let barHeight = diameter * 0.5
        let cornerRadius = barWidth * 0.6
        
        let leftBar = SKShapeNode(rectOf: CGSize(width: barWidth, height: barHeight), cornerRadius: cornerRadius)
        leftBar.fillColor = SKColor(white: 1.0, alpha: 0.9)
        leftBar.strokeColor = .clear
        leftBar.position = CGPoint(x: -barWidth, y: 0)
        
        let rightBar = SKShapeNode(rectOf: CGSize(width: barWidth, height: barHeight), cornerRadius: cornerRadius)
        rightBar.fillColor = SKColor(white: 1.0, alpha: 0.9)
        rightBar.strokeColor = .clear
        rightBar.position = CGPoint(x: barWidth, y: 0)
        
        circle.addChild(leftBar)
        circle.addChild(rightBar)
        
        pauseButton = circle
        
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
        self.pauseButton.run(SKAction.sequence([
            SKAction.scale(to: 0.9, duration: 0.06),
            SKAction.scale(to: 1.0, duration: 0.10)
        ]))
        
        pauseButton.run(waitForAnimation) {
            UserConfig.shared.changePause()
            if UserConfig.shared.userPause {
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
   
    func resumeButtonPressed() {
        // Show pressed state for resume button and then unpause UI overlay
        self.resumeButton.texture = SKTexture(imageNamed: "resumeButtonPressed")
        resumeButton.run(waitForAnimation) {
            UserConfig.shared.changePause()
            self.resumeButton.texture = SKTexture(imageNamed: "resumeButton")
            // Remove pause overlay elements
            self.blackBackground.removeFromParent()
            self.resumeButton.removeFromParent()
            self.homeButton.removeFromParent()
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
