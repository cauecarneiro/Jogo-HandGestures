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
    //
    var activeTouches: [UITouch: SKSpriteNode] = [:] // Dictionary to track touches and their corresponding buttons
    var pressingJumpAttack: Bool = false
    //Player
    var player: Player
    
    //ground
    var ground: SKSpriteNode
    
    // Pause
    var pauseNode: PauseNode
    
    var rightWall: SKSpriteNode
    var leftWall: SKSpriteNode
    
    var scoreNode: SKLabelNode
    var pauseStatus: Bool = false
    var heartSprites: [SKSpriteNode] =  []
    
    var dificulty = 1
    //    var shopOpen = false
    //
    var comboLabel: SKLabelNode
    
    var arController = ARViewController(cameraFrame: CGRect(x:100, y: 100, width: 100, height: 100), showPreview: true)
    var currentMovement: MovementState = .none
    
    
    override init(size: CGSize) {
        controllerBackground = SKSpriteNode(imageNamed: "controllerBackground")
        controllerBackground.scale(to: CGSize(width: size.width, height: size.height / 3))
        controllerBackground.position = CGPoint(x: size.width / 2, y: size.height / 2 - size.height / 2.7)
        controllerBackground.zPosition = -1
        
        var realSize = size
        if(realSize.width/realSize.height <= 1) {
            realSize = CGSize(width: 852, height: 393)
        }
        background = SKSpriteNode(imageNamed: "levelOneBackground")
        background.scale(to: realSize)
        background.position = CGPoint(x: realSize.width/2, y: realSize.height/2)
        background.alpha = 0.6
        background.zPosition = -2
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
        
        
        player = Player(size: size)
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
        
        comboLabel = SKLabelNode(text: "")
        comboLabel.position = CGPoint(x: size.width/2, y: size.height - 50)
        comboLabel.fontColor = .white
        comboLabel.fontName = appFont
        comboLabel.zPosition = 1
        
        super.init(size: size)
        
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        physicsWorld.contactDelegate = self
        
        backgroundColor = .black
        addChild(scoreNode)
        addChild(player.node)
        //        addChild(leftButton)
        //        addChild(rightButton)
        //        addChild(actionButton)
        addChild(pauseNode)
        addChild(background)
        addChild(comboLabel)
        setupPlatforms()
        
        func setupPlatforms() {
            // Array para guardar todas as plataformas
            var platforms: [SKSpriteNode] = []
            let platformSizeWidth: CGFloat = 255 * 0.50
            let plarformSizeHeight: CGFloat = 53 * 0.50
            
            let paredeWidth: CGFloat = 60 * 0.50
            let paredeHeight: CGFloat = 500 * 0.50
            
            
            // --- Plataformas Horizontais ---
            
            //
            let platform1 = SKSpriteNode(imageNamed: "plataforma")
            platform1.size = CGSize(width: platformSizeWidth, height: plarformSizeHeight)
            platform1.position = CGPoint(x: 0, y: 280)
            platforms.append(platform1)
            
            let platform2 = SKSpriteNode(imageNamed: "plataforma")
            platform2.size = CGSize(width: platformSizeWidth, height: plarformSizeHeight)
            platform2.position = CGPoint(x: platform1.position.x + platformSizeWidth, y: 280)
            platforms.append(platform2)
            
            //
            let platform3 = SKSpriteNode(imageNamed: "plataforma")
            platform3.size = CGSize(width: platformSizeWidth, height: plarformSizeHeight)
            platform3.position = CGPoint(x: 150, y: platform1.position.y - 100)
            platforms.append(platform3)
            
            let platform4 = SKSpriteNode(imageNamed: "plataforma")
            platform4.size = CGSize(width: platformSizeWidth, height: plarformSizeHeight)
            platform4.position = CGPoint(x: platform3.position.x + platformSizeWidth, y: platform1.position.y - 100)
            platforms.append(platform4)
            
            //
            
            let platform5 = SKSpriteNode(imageNamed: "plataforma")
            platform5.size = CGSize(width: platformSizeWidth, height: plarformSizeHeight)
            platform5.position = CGPoint(x: 10, y: platform3.position.y - 100)
            platforms.append(platform5)
            
            let platform6 = SKSpriteNode(imageNamed: "plataforma")
            platform6.size = CGSize(width: platformSizeWidth, height: plarformSizeHeight)
            platform6.position = CGPoint(x: platform5.position.x + platformSizeWidth, y: platform3.position.y - 100)
            platforms.append(platform6)
            
            let platform7 = SKSpriteNode(imageNamed: "plataforma")
            platform7.size = CGSize(width: platformSizeWidth, height: plarformSizeHeight)
            platform7.position = CGPoint(x: platform5.position.x + 2 * platformSizeWidth, y: platform3.position.y - 100)
            platforms.append(platform7)
            
            let platform8 = SKSpriteNode(imageNamed: "plataforma")
            platform8.size = CGSize(width: platformSizeWidth, height: plarformSizeHeight)
            platform8.position = CGPoint(x: platform6.position.x + 2 * platformSizeWidth, y: platform3.position.y - 100)
            platforms.append(platform8)
            
            //
            
            let parede1 = SKSpriteNode(imageNamed: "paredeG")
            parede1.size = CGSize(width: paredeWidth, height: paredeHeight)
            parede1.position = CGPoint(x: platform4.position.x + paredeWidth + 40, y: 290)
            platforms.append(parede1)
            
            let parede2 = SKSpriteNode(imageNamed: "paredeG")
            parede2.size = CGSize(width: paredeWidth, height: paredeHeight)
            parede2.position = CGPoint(x: platform8.position.x + paredeWidth + 40, y: platform3.position.y + 10)
            platforms.append(parede2)
            
            let parede3 = SKSpriteNode(imageNamed: "paredeG")
            parede3.size = CGSize(width: paredeWidth, height: paredeHeight)
            parede3.position = CGPoint(x: parede2.position.x + platformSizeWidth, y: 290)
            platforms.append(parede3)
            
            //
            
            let platform9 = SKSpriteNode(imageNamed: "plataforma")
            platform9.size = CGSize(width: 30, height: plarformSizeHeight)
            platform9.position = CGPoint(x: parede1.position.x + 30, y: platform3.position.y)
            platforms.append(platform9)
            
            
            let platform10 = SKSpriteNode(imageNamed: "plataforma")
            platform10.size = CGSize(width: 30, height: plarformSizeHeight)
            platform10.position = CGPoint(x: parede2.position.x - 30, y: platform3.position.y + 120)
            platforms.append(platform10)
            
            //
            
            let platform11 = SKSpriteNode(imageNamed: "plataforma")
            platform11.size = CGSize(width: platformSizeWidth - 30, height: plarformSizeHeight)
            platform11.position = CGPoint(x: platform8.position.x + 2 * platformSizeWidth - 30, y: platform3.position.y - 100)
            platforms.append(platform11)
            
            //fogo
            
            for i in 0..<25 { // Loop de 0 a 3 para 4 fogos
                // Calcula a posição X para o fogo atual
                // A cada iteração (i=0, i=1, i=2, i=3), adiciona o espaçamento
                let fireX = platform1.position.x + (CGFloat(i) * 60)
                
                let fire = setupAnimatedFire(at: CGPoint(x: fireX, y: 20), size: CGSize(width: 64, height: 64), zPosition: 2)
                addChild(fire)
            }
            
            
            //Menu no jogo
            let menuMini = SKSpriteNode(imageNamed: "menuMini")
            menuMini.size = CGSize(width: 270 * 0.80, height: 520 * 0.80)
            menuMini.position = CGPoint(x: size.width - 100, y: size.height/2)
            menuMini.zPosition = 1
            menuMini.physicsBody = SKPhysicsBody(rectangleOf: menuMini.size)
            menuMini.physicsBody?.isDynamic = false
            menuMini.physicsBody?.categoryBitMask = PhysicsCategory.ground
            menuMini.physicsBody?.collisionBitMask = PhysicsCategory.player
            menuMini.physicsBody?.contactTestBitMask = PhysicsCategory.player
            addChild(menuMini)
            
            
            
            // --- Adiciona a física para todas as plataformas de uma vez ---
            for platform in platforms {
                platform.zPosition = 1
                platform.physicsBody = SKPhysicsBody(rectangleOf: platform.size)
                platform.physicsBody?.isDynamic = false
                platform.physicsBody?.categoryBitMask = PhysicsCategory.ground
                platform.physicsBody?.collisionBitMask = PhysicsCategory.player
                platform.physicsBody?.contactTestBitMask = PhysicsCategory.player
                addChild(platform)
            }
        }
        
        //Fogo
        func setupAnimatedFire(at position: CGPoint, size: CGSize, zPosition: CGFloat) -> SKSpriteNode {
            var fireFrames: [SKTexture] = []
            let numberOfFireFrames = 6 // Supondo que você tenha fire0.png a fire3.png
            
            for i in 1..<numberOfFireFrames {
                let textureName = "fire\(i)" // Substitua se seus assets tiverem outro nome
                let fireTexture = SKTexture(imageNamed: textureName)
                fireFrames.append(fireTexture)
            }
            
            let firstFrame = fireFrames[0]
            let fire = SKSpriteNode(texture: firstFrame)
            fire.position = position
            fire.size = size // Use o tamanho passado como parâmetro
            fire.zPosition = zPosition // Certifique-se que o fogo aparece na frente de coisas como chão
            
            // Cria a ação de animação e repetição
            let animationAction = SKAction.animate(with: fireFrames, timePerFrame: 0.15) // Ajuste timePerFrame para a velocidade da animação
            let repeatAction = SKAction.repeatForever(animationAction)
            fire.run(repeatAction, withKey: "fireAnimation") // Dá uma chave para a ação, se precisar parar/pausar
            
            // --- Configuração do PhysicsBody do Fogo ---
            fire.physicsBody = SKPhysicsBody(rectangleOf: fire.size) // Um retângulo que cobre o sprite de fogo
            fire.physicsBody?.isDynamic = false // O fogo não se move com a física
            fire.physicsBody?.affectedByGravity = false // O fogo não é afetado pela gravidade
            fire.physicsBody?.categoryBitMask = PhysicsCategory.fire // Define a categoria como fogo
            fire.physicsBody?.collisionBitMask = PhysicsCategory.none // O fogo não colide "fisicamente" com nada (não para outros objetos)
            fire.physicsBody?.contactTestBitMask = PhysicsCategory.player // ESSENCIAL: Avisa quando o player entra em contato
            
            // Adiciona um nome ao nó para facilitar a identificação na colisão (opcional, mas bom)
            fire.name = "fireColisao"
            
            
            return fire
        }
        //new
        //        initiateHp()   // Removed this line per instructions
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
        
        arController.view?.removeFromSuperview()
    }
    
    @objc func appDidEnterBackground() {
    }
    
    @objc func appWillEnterForeground() {
        player.node.isPaused = pauseStatus
    }
    
    override func update(_ currentTime: TimeInterval) {
        calculatePlayerMovement()
        
        let handState = arController.currentHandState
        updateHandState(handState)
        
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
        switch arController.currentHandState {
        case .open:
            player.movePlayer(direction: 1, maxWidth: size.width)
        case .closed:
            player.movePlayer(direction: -1, maxWidth: size.width)
        default:
            break
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
        
        
        
        func presentMenuScene() {
            let scene = MenuScene(size: self.size)
            scene.scaleMode = self.scaleMode
            self.view?.presentScene(scene)
        }
    }


enum MovementState {
    case none
    case forward
    case backward
}
