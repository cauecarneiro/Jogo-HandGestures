//
//  Player.swift
//  Chroma Knight
//
//  Created by Thiago Parisotto on 18/06/24.
//

import Foundation
import SpriteKit
import HandGesturesClassifier


class Player {
    var node: SKSpriteNode
    var movementSpeed: CGFloat
    
    //jump
    var isJumping: Bool = false
    var jumpForce: CGFloat = 20.0
    
    //textures
    var textures: [SKTexture] = []
    var walkingTextures: [SKTexture] = []
        
    
    var hp: Int = 3
    var maxHP: Int = 3
    var damageCD = false
    enum AnimationState {
        case idle, walking, jumping, damaged
    }
    private var animationState: AnimationState = .idle
    
    init(size: CGSize) {
        self.movementSpeed = 2.0
        self.node = SKSpriteNode(imageNamed: "player0")
        node.size = CGSize(width: 809/30, height: 1024/30)
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
        self.walkingTextures.append(SKTexture(imageNamed: "playerWLK0"))
        self.walkingTextures.append(SKTexture(imageNamed: "playerWLK1"))
        self.walkingTextures.append(SKTexture(imageNamed: "playerWLK2"))
        
        animatePlayer()
    }
    

    func incHp(hp: Int) {
        self.hp += hp
    }
    
    
    func animatePlayer() {
        if !isJumping && !damageCD {
            if animationState != .idle {
                animationState = .idle
                node.size = CGSize(width: 809/30, height: 1024/30)
                node.removeAction(forKey: "walk")
                node.run(
                    SKAction.repeatForever(
                        SKAction.animate(
                            with: textures,
                            timePerFrame: 1/TimeInterval(textures.count),
                            resize: false,
                            restore: false
                        )
                    ),
                    withKey: "stand"
                )
            }
        }
    }
    
    
    func animateWalk() {
        if !isJumping && !damageCD {
            if animationState != .walking {
                animationState = .walking
                node.size = CGSize(width: 927/30, height: 1024/30)
                node.removeAction(forKey: "stand")
                node.run(
                    SKAction.repeatForever(
                        SKAction.animate(
                            with: walkingTextures,
                            timePerFrame: 1/TimeInterval(walkingTextures.count),
                            resize: false,
                            restore: false
                        )
                    ),
                    withKey: "walk"
                )
            }
        }
    }
    
    
    func movePlayer(direction: CGFloat, maxWidth: CGFloat) {
        // If there is no movement input, ensure idle animation
        if direction == 0 {
            print(direction)
            animatePlayer()
            return
        }

        let canMoveRight = direction == 1 && node.position.x <= (maxWidth - node.size.width/2)
        let canMoveLeft = direction == -1 && node.position.x >= (node.size.width/2)

        if canMoveRight || canMoveLeft {
            node.position.x += movementSpeed * direction
            node.xScale = direction
            animateWalk()
        } else {
            // Not moving (either input tries to move past bounds)
            animatePlayer()
        }
    }
    
    
    func playerJump() {
        if !isJumping {
            if !damageCD {
                node.size = CGSize(width: 809/30, height: 1024/30)
                node.texture = SKTexture(imageNamed: "playerJumping")
            }
            isJumping = true
            animationState = .jumping
            impulsePlayer(vector: CGVector(dx: 0, dy: jumpForce))
        }
    }
    
    
    func impulsePlayer(vector: CGVector) {
        node.removeAction(forKey: "animation")
        node.physicsBody?.velocity = CGVector.zero
        node.physicsBody?.applyImpulse(vector)
    }

    
    func collideWithFloor() {
        isJumping = false
        // Resume idle if not damaged
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
            
            animationState = .damaged
            node.removeAction(forKey: "animation")
            node.size = CGSize(width: 809/30, height: 1024/30)
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
