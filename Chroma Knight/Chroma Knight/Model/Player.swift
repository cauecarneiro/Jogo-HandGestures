//
//  Player.swift
//  Chroma Knight
//
//  Created by Thiago Parisotto on 18/06/24.
//

import Foundation
import SpriteKit
import SwiftUI
import HandGesturesClassifier

class Player {
    var node: SKSpriteNode
    var movementSpeed: CGFloat
    
    //jump
    var isJumping: Bool = false
    var jumpForce: CGFloat = 56.0
    

    //textures
    var textures: [SKTexture] = []
    var walkingTextures: [SKTexture] = []
        
    
    var hp: Int = 3
    var maxHP: Int = 3
    var damageCD = false
    
    init(size: CGSize) {
        self.movementSpeed = 2.0
        self.node = SKSpriteNode(imageNamed: "player0")
        node.size = CGSize(width: 809/20, height: 1024/20)
        node.position = CGPoint(x: 0, y: 280 + node.size.height)
        node.zPosition = 1
        node.name = "player"
        
        node.physicsBody = SKPhysicsBody(rectangleOf: node.size)
        node.physicsBody?.allowsRotation = false
        node.physicsBody?.restitution = 0.0
        node.physicsBody?.friction = 1.0
        node.physicsBody?.categoryBitMask = PhysicsCategory.player
//        node.physicsBody?.collisionBitMask = PhysicsCategory.ground | PhysicsCategory.slime
//        node.physicsBody?.contactTestBitMask = PhysicsCategory.ground | PhysicsCategory.slime
        
        
        self.textures.append(SKTexture(imageNamed: "player0"))
        self.textures.append(SKTexture(imageNamed: "player1"))
        self.walkingTextures.append(SKTexture(imageNamed: "playerWlk0"))
        self.walkingTextures.append(SKTexture(imageNamed: "playerWlk1"))
        self.walkingTextures.append(SKTexture(imageNamed: "playerWlk2"))
        
        animatePlayer()
    }
    

    func incHp(hp: Int) {
        self.hp += hp
    }
    
    
    func animatePlayer() {
        guard !isJumping, !damageCD else { return }
        // If already idling, do nothing to avoid restarting the animation every frame
        if node.action(forKey: "idle") != nil { return }
        // Stop walking animation if it's running
        node.removeAction(forKey: "walk")

        node.size = CGSize(width: 809/15, height: 1024/15)
        let action = SKAction.repeatForever(
            SKAction.animate(
                with: textures,
                timePerFrame: 1/TimeInterval(textures.count),
                resize: false,
                restore: false
            )
        )
        node.run(action, withKey: "idle")
    }
    func animateWalk() {
        guard !isJumping, !damageCD else { return }
        // If already walking, do nothing to avoid restarting the animation every frame
        if node.action(forKey: "walk") != nil { return }
        // Stop idle animation if it's running
        node.removeAction(forKey: "idle")

        node.size = CGSize(width: 809/15, height: 1024/15)
        let action = SKAction.repeatForever(
            SKAction.animate(
                with: walkingTextures,
                timePerFrame: 1/TimeInterval(walkingTextures.count),
                resize: false,
                restore: false
            )
        )
        node.run(action, withKey: "walk")
    }
    func movePlayer(direction: CGFloat, maxWidth: CGFloat) {
        if direction == 0 {
            animatePlayer()
            return
        }
        
        if(node.position.x <= (maxWidth - node.size.width/2) && direction == 1 || node.position.x >= (node.size.width/2) && direction == -1) {
            node.position.x += movementSpeed * direction
            node.xScale = direction
        }
        
        animateWalk()
    }
    func playerJump() {
        if(!isJumping) {
            if(!damageCD) {
                // Stop any ongoing idle/walk animations
                node.removeAction(forKey: "idle")
                node.removeAction(forKey: "walk")

                node.size = CGSize(width: 809/10, height: 1024/10)
                node.texture = SKTexture(imageNamed: "playerJumping")
            }
            isJumping = true
            impulsePlayer(vector: CGVector(dx: 0, dy: jumpForce))
        }
    }
    
    func impulsePlayer(vector: CGVector) {
        node.removeAction(forKey: "idle")
        node.removeAction(forKey: "walk")
        node.physicsBody?.velocity = CGVector.zero
        node.physicsBody?.applyImpulse(vector)
    }

    func collideWithFloor() {
        isJumping = false
        animatePlayer()
    }
    
    func takeDamage(direction: CGFloat, damage: Int) {
        if(!damageCD) {
            hp -= damage
            
            // Adiciona a verificação de Game Over
            if let scene = node.scene as? LevelOneScene {
                scene.loseHp(dmg: damage)
                if scene.checkGameOver() {
                    scene.gameOver()
                    return // Encerra a função se o jogo acabou
                }
            }
            
            node.removeAction(forKey: "idle")
            node.removeAction(forKey: "walk")
            node.size = CGSize(width: 809/15, height: 1024/15)
            node.texture = SKTexture(imageNamed: "playerDmg")
            node.physicsBody?.velocity = CGVector.zero
            node.zPosition = 3
            if(isJumping) {
                node.physicsBody?.applyImpulse(CGVector(dx: 30 * direction, dy: jumpForce))
            } else {
                node.physicsBody?.applyImpulse(CGVector(dx: 20 * direction, dy: 25))
            }
            damageCD = true
            let waitAction = SKAction.wait(forDuration: 1.05)
            let runAction = SKAction.run {
                self.damageCD = false
            }
            node.run(SKAction.sequence([waitAction, SKAction.run {
                self.animatePlayer()
            }]), withKey: "animate")
            let sequence = SKAction.sequence([waitAction, runAction])
            self.node.run(sequence, withKey: "damage")
        }
    }

}

