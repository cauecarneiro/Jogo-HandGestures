//
//  MenuScene.swift
//  Chroma Knight
//
//  Created by Thiago Parisotto on 28/05/24.
//

import Foundation
import SpriteKit

class MenuScene: SKScene {
    var background: SKSpriteNode
    var titleLabel: SKLabelNode
    var titleShadow: SKLabelNode
    
    var playLabel: SKLabelNode
    var playButton: SKSpriteNode
    var levelOne: LevelOneScene?
    
    override init(size: CGSize) {
    
        var realSize = size
        if(realSize.width/realSize.height <= 1) {
            realSize = CGSize(width: 852, height: 393)
        }
        
        
        background = SKSpriteNode(imageNamed: "menuBackground")
        background.scale(to: realSize)
        background.position = CGPoint(x: realSize.width/2, y: realSize.height/2)
        background.zPosition = -1
        background.alpha = 0.7
        background.name = "background"
        
        titleLabel = SKLabelNode(text: "Braga Adventures")
        titleLabel.fontSize = 48
        titleLabel.fontName = "Retro Gaming"
        titleLabel.fontColor = .main
        titleLabel.position = CGPoint(x: realSize.width/2, y: realSize.height/1.3)
        
        titleShadow = SKLabelNode(text: "Braga Adventures")
        titleShadow.fontSize = 48
        titleShadow.fontName = "Retro Gaming"
        titleShadow.fontColor = .black
        titleShadow.position = CGPoint(x: titleLabel.position.x + 3, y: titleLabel.position.y - 5)
               
        playButton = SKSpriteNode(imageNamed: "playButton")
        playButton.scale(to: CGSize(width: 200, height: 50))
        playButton.position = CGPoint(x: realSize.width/2, y: realSize.height/10)
        playButton.zPosition = 0
        playButton.name = "playButton"
                
        playLabel = SKLabelNode(text: "Start Game")
        playLabel.fontColor = .black
        playLabel.fontSize = 24
        playLabel.fontName = "Retro Gaming"
        playLabel.position = CGPoint(x: playButton.position.x, y: playButton.position.y)
        playLabel.name = "playButton"
        
        
        super.init(size: realSize)
        SoundManager.soundTrack.playSoundtrack()
        addChild(background)
        addChild(playButton)
        addChild(titleShadow)
        addChild(titleLabel)
        addChild(playLabel)
    }
    

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
       
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let touchedNode = atPoint(location)
            if let name = touchedNode.name {
                if(name.contains("Button") ) {
                    vibrate(with: .light)
                    SoundManager.shared.playButtonSound()
                }
                if(name.contains("Toggle")) {
                    vibrate(with: .light)
                    SoundManager.shared.playToggleSound()
                }
                
                switch name {
                case "playButton":
                    let levelOneScene = LevelOneScene(size: self.size)
                    levelOneScene.scaleMode = self.scaleMode
                    animateButton(button: playButton)
                    playLabel.position.y -= 10
                    transitionToNextScene(scene: levelOneScene)
                default:
                    break
                }
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        
    }
    
    func transitionToNextScene(scene: SKScene) {
        self.run(waitForAnimation) {
            self.view?.presentScene(scene)
        }
    }
}
