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
        if(contactA == PhysicsCategory.player && contactB == PhysicsCategory.ground) || (contactA == PhysicsCategory.ground && contactB == PhysicsCategory.player) {
            collideWithFloor()
        }
        
        //Fogo
                if (contactA == PhysicsCategory.player && contactB == PhysicsCategory.fire) || (contactA == PhysicsCategory.fire && contactB == PhysicsCategory.player) {
                    player.takeDamage(direction: 0, damage: 3)
                }
        
        if(contactA == PhysicsCategory.fruits && contactB == PhysicsCategory.player || contactB == PhysicsCategory.fruits && contactA == PhysicsCategory.player) {
            
            if(contactA == PhysicsCategory.fruits) {
                if(addHp(hp: dificulty)) {
                    contact.bodyA.node?.removeFromParent()
                }
            } else {
                if(addHp(hp: dificulty)) {
                    contact.bodyB.node?.removeFromParent()
                }
            }
        }
        if(contactA == PhysicsCategory.coins && contactB == PhysicsCategory.player || contactB == PhysicsCategory.coins && contactA == PhysicsCategory.player) {
            increaseScore()
            if(contactA == PhysicsCategory.coins) {
                contact.bodyA.node?.removeFromParent()
            } else {
                contact.bodyB.node?.removeFromParent()
            }
        }
        
        
        if(contactA == PhysicsCategory.player && contactB == PhysicsCategory.leftWall || contactB == PhysicsCategory.player && contactA == PhysicsCategory.leftWall ) {
            player.node.physicsBody?.velocity.dx = 0
        }
        
        if(contactA == PhysicsCategory.player && contactB == PhysicsCategory.rightWall || contactB == PhysicsCategory.player && contactA == PhysicsCategory.rightWall ) {
            player.node.physicsBody?.velocity.dx = 0
        }
    }
    
    
    func collideWithFloor() {
        increaseCombo()
        if player.isJumping {
            actionButton.name = "actionButton"
            actionButton.texture = SKTexture(imageNamed: "actionButton")
            player.collideWithFloor()
            if(activeTouches.values.contains(leftButton) || activeTouches.values.contains(rightButton)) {
                player.animateWalk()
            } else {
                player.animatePlayer()
            }
        }
    }
}

struct PhysicsCategory {
    static let none: UInt32 = 0
    static let player: UInt32 = 1 << 0
    static let ground: UInt32 = 1 << 1
    static let slime: UInt32 = 1 << 2
   // static let ghost: UInt32 = 1 << 3
    static let rightWall: UInt32 = 1 << 4
    static let leftWall: UInt32 = 1 << 5
    static let fruits: UInt32 = 1 << 6
    static let coins: UInt32 = 1 << 7
    static let slimeKing: UInt32 = 1 << 8
    static let fire: UInt32 = 1 << 9  // 16
}

