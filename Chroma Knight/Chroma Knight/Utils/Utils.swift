//
//  Utils.swift
//  Chroma Knight
//
//  Created by Thiago Parisotto on 04/06/24.
//

import Foundation
import SpriteKit

let appFont = "Retro Gaming"
let waitForAnimation = SKAction.wait(forDuration: 0.2)
let fadeOut = SKAction.fadeOut(withDuration: 0.4)

func animateButton(button: SKSpriteNode) {
    button.texture = SKTexture(imageNamed: String((button.name ?? "") + "Pressed"))
}
func deactivateButton(button: SKSpriteNode) {
    button.texture = SKTexture(imageNamed: button.name ?? "")
}



