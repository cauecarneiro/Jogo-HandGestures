//
//  LevelOneTouches.swift
//  Chroma Knight
//

import Foundation
import SpriteKit

extension LevelOneScene {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let touchedNode = atPoint(location)
            if let name = touchedNode.name {
                switch name {
                case "pauseButton":
                    pauseNode.pauseButtonPressed()
                    togglePause()
                case "resumeButton":
                    pauseNode.resumeButtonPressed()
                    togglePause()
                case "homeButton":
                    pauseNode.homeButtonPressed(scene: self)
                default:
                    break
                }
            }
        }
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if let button = activeTouches[touch] {
                deactivateButton(button: button)
                activeTouches[touch] = nil
                player.animatePlayer()
                
            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if let button = activeTouches[touch] {
                deactivateButton(button: button)
                activeTouches[touch] = nil
                player.animatePlayer()
            }
        }
    }
}

