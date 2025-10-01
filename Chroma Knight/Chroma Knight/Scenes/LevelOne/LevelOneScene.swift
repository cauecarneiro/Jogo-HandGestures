import Foundation
import SpriteKit
import UIKit
import HandPose
class LevelOneScene: SKScene, SKPhysicsContactDelegate {
    
    // Backgrounds
    var controllerBackground: SKSpriteNode
    var background: SKSpriteNode
    // Controller
//    var leftButton: SKSpriteNode
//    var rightButton: SKSpriteNode
//    var actionButton: SKSpriteNode
    
    var activeTouches: [UITouch: SKSpriteNode] = [:] // Dictionary to track touches and their corresponding buttons
    var pressingJumpAttack: Bool = false
    //Player
    var player: Player
    
    var merchant: Merchant?
    //ground
    var ground: SKSpriteNode
    
    // Pause
    var pauseNode: PauseNode
    
    var rightWall: SKSpriteNode
    var leftWall: SKSpriteNode
    
    var scoreNode: SKLabelNode
    var pauseStatus: Bool = false
    var heartSprites: [SKSpriteNode] =  []
    
//    var dificulty = 1
//    var shopOpen = false
//    
//    var comboLabel: SKLabelNode
    
    var arController = ARViewController(cameraFrame: CGRect(x:100, y: 100, width: 100, height: 100), showPreview: true)
    
    
    override init(size: CGSize) {
        controllerBackground = SKSpriteNode(imageNamed: "controllerBackground")
        controllerBackground.scale(to: CGSize(width: size.width, height: size.height / 3))
        controllerBackground.position = CGPoint(x: size.width / 2, y: size.height / 2 - size.height / 2.7)
        controllerBackground.zPosition = -1
        
        background = SKSpriteNode(imageNamed: "levelOneBackground")
        background.scale(to: CGSize(width: size.width, height: size.height / 1.2))
        background.position = CGPoint(x: size.width / 2, y: size.height / 2 + size.height / 5)
        background.zPosition = -2
        
        pauseNode = PauseNode(size: size)
        pauseNode.zPosition = 5
        
//        let buttonsX = 100.0
//        let buttonsSize: CGFloat = 100
//        let buttonsHeight = size.height / 3 - buttonsSize / 1.5
//        leftButton = SKSpriteNode(imageNamed: "leftButton")
//        leftButton.scale(to: CGSize(width: buttonsSize, height: buttonsSize))
//        leftButton.position = CGPoint(x: buttonsX, y: buttonsHeight)
//        leftButton.zPosition = 2
//        leftButton.name = "leftButton"
//        
//        rightButton = SKSpriteNode(imageNamed: "rightButton")
//        rightButton.scale(to: CGSize(width: buttonsSize, height: buttonsSize))
//        rightButton.position = CGPoint(x: buttonsX + buttonsSize * 1.5, y: buttonsHeight)
//        rightButton.zPosition = 2
//        rightButton.name = "rightButton"
        
//        actionButton = SKSpriteNode(imageNamed: "actionButton")
//        actionButton.scale(to: CGSize(width: buttonsSize, height: buttonsSize))
//        actionButton.position = CGPoint(x: size.width - buttonsX * 1.1, y: buttonsHeight)
//        actionButton.zPosition = 2
//        actionButton.name = "actionButton"
        
        
        player = Player(size: size, sword: Sword(damage: 1, size: size, type: .basic))
        ground = SKSpriteNode(color: .clear, size: CGSize(width: size.width * 2, height: 10))
        ground.position = CGPoint(x: size.width/2, y: player.node.position.y - player.node.size.height/1.8)
        ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
        ground.physicsBody?.isDynamic = false
        ground.physicsBody?.categoryBitMask = PhysicsCategory.ground
        ground.physicsBody?.collisionBitMask = PhysicsCategory.player
        ground.physicsBody?.contactTestBitMask = PhysicsCategory.player
        
        rightWall = SKSpriteNode(color: .clear, size: CGSize(width: 10, height: size.height))
        rightWall.position = CGPoint(x: size.width, y: size.height/2)
        rightWall.physicsBody = SKPhysicsBody(rectangleOf: rightWall.size)
        rightWall.physicsBody?.isDynamic = false
        rightWall.physicsBody?.isResting = true
        rightWall.physicsBody?.categoryBitMask = PhysicsCategory.rightWall
        rightWall.physicsBody?.collisionBitMask = PhysicsCategory.player
        rightWall.physicsBody?.contactTestBitMask = PhysicsCategory.player
        
        leftWall = SKSpriteNode(color: .clear, size: CGSize(width: 10, height: size.height))
        leftWall.position = CGPoint(x: 0, y: size.height/2)
        leftWall.physicsBody = SKPhysicsBody(rectangleOf: leftWall.size)
        leftWall.physicsBody?.isDynamic = false
        leftWall.physicsBody?.categoryBitMask = PhysicsCategory.leftWall
        leftWall.physicsBody?.collisionBitMask = PhysicsCategory.player
        leftWall.physicsBody?.contactTestBitMask = PhysicsCategory.player
        
        //new
        scoreNode = SKLabelNode(text: "\(player.points)")
        scoreNode.position = CGPoint(x: 50, y: size.height - 50)
        scoreNode.fontColor = .white
        scoreNode.fontName = appFont
        scoreNode.zPosition = 1
        
//        comboLabel = SKLabelNode(text: "")
//        comboLabel.position = CGPoint(x: size.width/2, y: size.height - 50)
//        comboLabel.fontColor = .white
//        comboLabel.fontName = appFont
//        comboLabel.zPosition = 1
        
        super.init(size: size)
        
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        physicsWorld.contactDelegate = self
        
        backgroundColor = .black
        addChild(ground)
        addChild(leftWall)
        addChild(rightWall)
        addChild(scoreNode)
        addChild(player.node)
//        addChild(leftButton)
//        addChild(rightButton)
//        addChild(actionButton)
        addChild(pauseNode)
        addChild(controllerBackground)
        addChild(background)
//        addChild(comboLabel)
        
        //new
        initiateHp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func didMove(to view: SKView) {
        self.isUserInteractionEnabled = true
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        if let cameraFrame = self.arController.view {
            cameraFrame.backgroundColor = .clear
            cameraFrame.frame = view.bounds
            view.addSubview(cameraFrame)
            
            view.superview?.sendSubviewToBack(view)
        }
    }
    
    override func willMove(from view: SKView) {
        super.willMove(from: view)
        // Remove observers when the scene is no longer in the view hierarchy
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    @objc func appDidEnterBackground() {
    }
    
    @objc func appWillEnterForeground() {
        player.node.isPaused = pauseStatus
    }
    
    override func update(_ currentTime: TimeInterval) {
        calculatePlayerMovement()
        checkMerchantCollision()
    }
    
    func initiateHp() {
        for i in 0..<Int(player.hp) {
            let hpHeart = SKSpriteNode(imageNamed: "heart")
            hpHeart.size = CGSize(width: 30, height: 30)
            hpHeart.position = CGPoint(x: 50 * (i + 1) + 5*i, y: Int(size.height) - 80)
            hpHeart.zPosition = 3
            addChild(hpHeart)
            heartSprites.append(hpHeart)
        }
    }
    
    func loseHp(dmg: Int) {
        vibrate(with: .heavy)
        for _ in 0..<dmg {
            if(heartSprites.count >= 1) {
                heartSprites[heartSprites.count - 1].removeFromParent()
                heartSprites.removeLast()
            }
        }
    }
    func addHp(hp: Int) -> Bool{
        if(player.hp < player.maxHP) {
            var healingAmount = hp
            if (hp + player.hp > player.maxHP) {
                healingAmount = player.maxHP - player.hp
            }
            player.incHp(hp: healingAmount)
            for i in heartSprites.count..<player.hp {
                let hpHeart = SKSpriteNode(imageNamed: "heart")
                hpHeart.size = CGSize(width: 30, height: 30)
                hpHeart.position = CGPoint(x: 50 * (i + 1) + 5*i, y: Int(size.height) - 80)
                addChild(hpHeart)
                heartSprites.append(hpHeart)
            }
            return true
        }
        return false
    }
    
    
    func checkGameOver() -> Bool {
        if(player.hp <= 0) {
            return true
        }
        return false
    }
    
    func gameOver() {
        self.isPaused.toggle()
        presentMenuScene()
    }
    
    //new
    func togglePause() {
        pauseStatus.toggle()
        
        if(pauseStatus) {
            self.physicsWorld.gravity = CGVector.zero
            self.physicsWorld.speed = 0
        } else {
            self.isPaused = false
            self.physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
            self.physicsWorld.speed = 1.0
        }
        
        player.node.isPaused = pauseStatus
    }
    
    
    
    func calculatePlayerMovement() {
//        if(activeTouches.values.contains(leftButton)) {
//            player.movePlayer(direction: -1, maxWidth: size.width)
//        }
//        if(activeTouches.values.contains(rightButton)) {
//            
//            player.movePlayer(direction: 1, maxWidth: size.width)
//            
//        }
        
        if(arController.currentHandState == .closed) {
            player.movePlayer(direction: -1, maxWidth: size.width)
        }
        
        if(arController.currentHandState == .open) {
            player.movePlayer(direction: 1, maxWidth: size.width)
        }
    }
    
    
    func increaseScore() {
        player.increaseScore(points: dificulty)
        scoreNode.text = "\(player.points)"
    }
    func increaseCombo() {
        if(player.combo == 0) {
            comboLabel.text = ""
        } else {
            comboLabel.text = "\(player.combo)"
        }
        comboLabel.fontColor = .white
    }
    func openShop() {
        shopOpen = true
        let newSword = arc4random_uniform(3)
        var type = SwordType.basic
        switch newSword {
        case 0:
            type = .katana
        case 1:
            type = .void
        case 2:
            type = .dagger
        default:
            type = .void
            
        }
        
        player.changeSword(sword: Sword(damage: 2, size: size, type: type), size: size)
        closeShop()
    }
    
    func closeShop() {
        let action = SKAction.run {
            self.merchant?.node.removeFromParent()
            self.merchant = nil
        }
        self.shopOpen = false
        merchant?.node.run(SKAction.sequence([SKAction.fadeOut(withDuration: 0.5), action]))
    }
    
    
    func presentMenuScene() {
        let scene = MenuScene(size: self.size)
        scene.scaleMode = self.scaleMode
        self.view?.presentScene(scene)
    }
    
}

