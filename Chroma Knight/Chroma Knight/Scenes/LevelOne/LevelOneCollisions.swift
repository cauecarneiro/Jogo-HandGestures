//
//  LevelOneCollisions.swift
//  Chroma Knight
//
//  Created by Thiago Parisotto on 26/07/24.
//

import Foundation
import SpriteKit

extension LevelOneScene {
    func didBegin(_ contact: SKPhysicsContact) {
        let contactA = contact.bodyA.categoryBitMask
        let contactB = contact.bodyB.categoryBitMask
        
        //Contato com o chão
        if(contactA == PhysicsCategory.player && contactB == PhysicsCategory.ground) || (contactA == PhysicsCategory.ground && contactB == PhysicsCategory.player) {
            collideWithFloor()
        }
        
        //Contato com o Fire
        if (contactA == PhysicsCategory.player && contactB == PhysicsCategory.fire) || (contactA == PhysicsCategory.fire && contactB == PhysicsCategory.player) {
            player.takeDamage(direction: 0, damage: 3)
        }
        
        //Contato com as paredes
        if(contactA == PhysicsCategory.player && contactB == PhysicsCategory.leftWall || contactB == PhysicsCategory.player && contactA == PhysicsCategory.leftWall ) {
            player.node.physicsBody?.velocity.dx = 0
        }
        
        //contato com as paredes
        if(contactA == PhysicsCategory.player && contactB == PhysicsCategory.rightWall || contactB == PhysicsCategory.player && contactA == PhysicsCategory.rightWall ) {
            player.node.physicsBody?.velocity.dx = 0
        }
    }
    
    
    func collideWithFloor() {
        if player.isJumping {
            actionButton.name = "actionButton"
            actionButton.texture = SKTexture(imageNamed: "actionButton")
            player.collideWithFloor()
//            if(activeTouches.values.contains(leftButton) || activeTouches.values.contains(rightButton)) {
//                player.animateWalk()
//            } else {
//                player.animatePlayer()
//            }
        }
    }
}

struct PhysicsCategory {
    static let none: UInt32 = 0
    static let player: UInt32 = 1 << 0
    static let ground: UInt32 = 1 << 1
    static let rightWall: UInt32 = 1 << 4
    static let leftWall: UInt32 = 1 << 5
    static let fire: UInt32 = 1 << 9  // 16
}

