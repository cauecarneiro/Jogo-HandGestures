import Foundation
import SpriteKit
import UIKit
import HandGesturesClassifier
import EmotionClassification


class LevelOneScene: SKScene, SKPhysicsContactDelegate {
    
    // Variável para guardar a plataforma que vai reaparecer
    var plataformaReaparece: SKSpriteNode?
    var plataformaJaReapareceu = false // Controle para reaparecer apenas uma vez
    var paredeJaSubiu = false
    var paredeJaDesceu = false
    
    
    // Backgrounds
    var controllerBackground: SKSpriteNode
    var background: SKSpriteNode
    
    private var audioAnalyzer: AudioAnalyzer!
    private var audioViewModel: AudioViewModel!
    
    var activeTouches: [UITouch: SKSpriteNode] = [:] // Dictionary to track touches and their corresponding buttons
    //Player
    var player: Player
    
    //ground
    var ground: SKSpriteNode
    
    // Pause
    var pauseNode: PauseNode
    
    var rightWall: SKSpriteNode
    var leftWall: SKSpriteNode
    
    var pauseStatus: Bool = false
    var heartSprites: [SKSpriteNode] =  []

    var gestureDirection: CGFloat = 0 // -1 = para trás, 0 = parado, 1 = para frente
    
    private let voiceLevelLabel: SKLabelNode
    private var voiceTimer: Timer!
    var arController = ARViewController(cameraFrame: CGRect(x: 668, y: 12, width: 210 * 0.80, height: 100), isCameraHidden: false)
    var currentMovement: MovementState = .none
    override init(size: CGSize) {
        controllerBackground = SKSpriteNode(imageNamed: "controllerBackground")
        controllerBackground.scale(to: CGSize(width: size.width, height: size.height / 3))
        controllerBackground.position = CGPoint(x: size.width / 2, y: size.height / 2 - size.height / 2.7)
        controllerBackground.zPosition = -1
        audioViewModel = AudioViewModel()
        audioViewModel.startAnalysis()
        

        voiceLevelLabel = SKLabelNode(text: "Nível da voz: 0.0")
        voiceLevelLabel.fontName = "Avenir-Heavy"
        voiceLevelLabel.fontSize = 22
        voiceLevelLabel.fontColor = .white
        voiceLevelLabel.horizontalAlignmentMode = .left
        voiceLevelLabel.verticalAlignmentMode = .top
        voiceLevelLabel.position = CGPoint(x: 16, y: size.height - 16)
        voiceLevelLabel.zPosition = 10
        
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
        
        
        super.init(size: size)
        
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        physicsWorld.contactDelegate = self
        
        backgroundColor = .black
        
        addChild(player.node)
        addChild(pauseNode)
        addChild(background)
        addChild(voiceLevelLabel)
        
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
            platform3.position = CGPoint(x: 160, y: platform1.position.y - 100)
            platforms.append(platform3)
            
            let platform4 = SKSpriteNode(imageNamed: "plataforma")
            platform4.size = CGSize(width: platformSizeWidth, height: plarformSizeHeight)
            platform4.position = CGPoint(x: platform3.position.x + platformSizeWidth, y: platform1.position.y - 100)
            platform4.name = "plataformaArmadilha"
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
            platform7.name = "plataformaArmadilha"
            platforms.append(platform7)
            self.plataformaReaparece = platform7
            
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
            parede2.name = "paredeQueSobe"
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
            
            
            let porta = SKSpriteNode(imageNamed: "porta")
            
            porta.size = CGSize(width: 50, height: 60)
            porta.position = CGPoint(x: platform11.position.x + 15, y: platform11.position.y + 40)
            porta.zPosition = 1
            porta.physicsBody = SKPhysicsBody(rectangleOf: porta.size)
            porta.physicsBody?.isDynamic = false
            porta.physicsBody?.categoryBitMask = PhysicsCategory.porta // Define a categoria como fogo
            porta.physicsBody?.collisionBitMask = PhysicsCategory.player // O fogo não colide "fisicamente" com nada (não para outros objetos)
            porta.physicsBody?.contactTestBitMask = PhysicsCategory.player // ESSENCIAL: Avisa quando o player entra em contato
            
            addChild(porta)
            
            
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
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
            
        voiceTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            DispatchQueue.main.async {
                let level = self.audioViewModel.rmsLevel
                self.voiceLevelLabel.text = String(format: "Nível da voz: %.2f", level)
                
                if level == 1.0 {
                    self.player.playerJump()
                }
            }
        }
        
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
        voiceTimer?.invalidate()
        voiceTimer = nil
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
        let handState = arController.gesture
        updateHandState(handState)
            // --- Início do código da armadilha ---

            // Defina o centro da área onde a armadilha será acionada
            let posicaoXArmadilha: CGFloat = 180.0 // Altere para a coordenada X desejada
            let posicaoYArmadilha: CGFloat = 320.0  // Altere para a coordenada Y desejada

            // Margens para criar uma "caixa" de ativação ao redor do ponto central
            let margemX: CGFloat = 5.0
            let margemY: CGFloat = 5.0  // Margem para o eixo Y para compensar os valores "quebrados"

            // Verifica se a posição do jogador está dentro da "caixa" de ativação da armadilha
            print("X: \(player.node.position.x), Y: \(player.node.position.y)")
            if player.node.position.x >= posicaoXArmadilha - margemX &&
               player.node.position.x <= posicaoXArmadilha + margemX &&
               player.node.position.y >= posicaoYArmadilha - margemY &&
               player.node.position.y <= posicaoYArmadilha + margemY {

                self.enumerateChildNodes(withName: "plataformaArmadilha") { (node, stop) in
                            // Garante que a ação de remoção seja executada apenas uma vez por plataforma
                            if node.physicsBody != nil {
                                node.physicsBody = nil // Remove a física para o jogador cair imediatamente

                                // Cria uma ação para a plataforma desaparecer (efeito visual)
                                let fadeOutAction = SKAction.fadeOut(withDuration: 0.1)
                                let removeAction = SKAction.removeFromParent()
                                let sequence = SKAction.sequence([fadeOutAction, removeAction])

                                node.run(sequence)
                            }
                    }
            }
            // --- Fim do código da armadilha ---
            
            // --- Início do código para SUBIR A PAREDE ---

                // Defina a posição que o jogador precisa alcançar para a parede subir
                let posicaoXSubirParede: CGFloat = 425 // Altere para a coordenada X desejada
                let posicaoYSubirParede: CGFloat = 338 // Altere para a coordenada Y desejada
                let margemParede: CGFloat = 40.0

                // Verifica se a parede já subiu e se o jogador alcançou a posição X
                if !paredeJaSubiu &&
                    player.node.position.x >= posicaoXSubirParede - margemParede &&
                    player.node.position.x <= posicaoXSubirParede + margemParede &&
                    player.node.position.y >= posicaoYSubirParede - margemParede &&
                    player.node.position.y <= posicaoYSubirParede + margemParede {
                    
                    // Procura pela parede com o nome que definimos
                    if let parede = self.childNode(withName: "paredeQueSobe") {
                        
                        // Define para onde a parede vai se mover (para cima) e a velocidade
                        let alturaSubida: CGFloat = 100.0 // O quanto a parede vai subir no eixo Y
                        let duracao: TimeInterval = 0.5  // Quanto tempo a animação vai levar

                        // Cria a ação de movimento
                        let moveUpAction = SKAction.moveBy(x: 0, y: alturaSubida, duration: duracao)
                        
                        // Executa a ação na parede
                        parede.run(moveUpAction)
                        
                        // Marca que a parede já subiu para não executar de novo
                        paredeJaSubiu = true
                    }
                }
            
            // --- LÓGICA PARA DESCER A PAREDE ---
                // Defina a nova "caixa" de ativação para a parede descer
                let posicaoXDescerParede: CGFloat = 425.0 // Altere para a coordenada X desejada
                let posicaoYDescerParede: CGFloat = 118.0 // Altere para a coordenada Y desejada
                let margemDescer: CGFloat = 20.0

                // Verifica se a parede JÁ SUBIU, se AINDA NÃO DESCEU, e se o jogador está na nova posição
                if paredeJaSubiu && !paredeJaDesceu &&
                   player.node.position.x >= posicaoXDescerParede - margemDescer &&
                   player.node.position.x <= posicaoXDescerParede + margemDescer &&
                   player.node.position.y >= posicaoYDescerParede - margemDescer &&
                   player.node.position.y <= posicaoYDescerParede + margemDescer {
                    
                    if let parede = self.childNode(withName: "paredeQueSobe") {
                        let duracao: TimeInterval = 0.2
                        // Cria a ação de movimento para baixo (usando o valor negativo da subida)
                        let moveDownAction = SKAction.moveBy(x: 0, y: -100, duration: duracao)
                        
                        parede.run(moveDownAction)
                        paredeJaDesceu = true // Marca que a parede já desceu para não executar de novo
                    }
                }
                // --- Fim do código para movimentar a parede ---
            
            
            // --- Início do código para REAPARECER a plataforma ---
                
                // Defina a posição que o jogador precisa alcançar para a plataforma voltar
                let posicaoXReaparecer: CGFloat = 26.0 // Altere para a coordenada X desejada
                let posicaoYReaparecer: CGFloat = 120.0 // Altere para a coordenada Y desejada
                let margemReaparecer: CGFloat = 10.0

                // Verifica se a plataforma pode reaparecer e se o jogador está na posição
                if !plataformaJaReapareceu &&
                   player.node.position.x >= posicaoXReaparecer - margemReaparecer + 50 &&
                   player.node.position.x <= posicaoXReaparecer + margemReaparecer + 50 &&
                   player.node.position.y >= posicaoYReaparecer - margemReaparecer &&
                   player.node.position.y <= posicaoYReaparecer + margemReaparecer {
                    
                    // Verifica se temos uma plataforma guardada para recriar
                    if let plataformaOriginal = self.plataformaReaparece {
                        
                        // Cria uma nova plataforma com as mesmas propriedades da original
                        let novaPlataforma = SKSpriteNode(imageNamed: "plataforma")
                        novaPlataforma.size = plataformaOriginal.size
                        novaPlataforma.position = plataformaOriginal.position
                        novaPlataforma.zPosition = plataformaOriginal.zPosition
                        
                        // Devolve a física à nova plataforma
                        novaPlataforma.physicsBody = SKPhysicsBody(rectangleOf: novaPlataforma.size)
                        novaPlataforma.physicsBody?.isDynamic = false
                        novaPlataforma.physicsBody?.categoryBitMask = PhysicsCategory.ground
                        novaPlataforma.physicsBody?.collisionBitMask = PhysicsCategory.player
                        novaPlataforma.physicsBody?.contactTestBitMask = PhysicsCategory.player
                        
                        // Faz a plataforma aparecer suavemente
                        novaPlataforma.alpha = 0.0
                        addChild(novaPlataforma)
                        novaPlataforma.run(SKAction.fadeIn(withDuration: 0.5))

                        // Marca que a plataforma já reapareceu para não executar de novo
                        plataformaJaReapareceu = true
                    }
                }
            
        }
    
    func loseHp(dmg: Int) {
//        vibrate(with: .heavy)
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
        // 1. Garante que o código de game over só rode uma vez
        
        // Pausa a cena para congelar a ação
        self.isPaused = true
        
        // --- 2. Criar e configurar a imagem de fundo ---
        let gameOverBackground = SKSpriteNode(imageNamed: "fireAcademy") // IMPORTANTE: Mude para o nome da sua imagem de game over
        gameOverBackground.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        gameOverBackground.size = self.size // Faz a imagem cobrir a tela inteira
        gameOverBackground.zPosition = 100 // Um valor bem alto para garantir que fique na frente de tudo
        
        
        // --- 3. Criar e configurar o texto ---
        let gameOverLabel = SKLabelNode(fontNamed: "Retro Gaming") // Usando uma fonte que você já usa na cena
        gameOverLabel.text = "Você deixou a academy pegar fogo"
        gameOverLabel.fontSize = 32
        gameOverLabel.fontColor = .black
        gameOverLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        gameOverLabel.zPosition = 101 // Na frente do background
        
        // Para que o texto quebre a linha em telas menores
        gameOverLabel.numberOfLines = 0
        gameOverLabel.preferredMaxLayoutWidth = self.size.width - 60 // Define uma largura máxima com margens
        
        
        // --- 4. Adicionar os elementos na cena ---
        addChild(gameOverBackground)
        addChild(gameOverLabel)
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            // O código aqui dentro será executado após 3 segundos, mesmo com a cena pausada.
            self?.presentMenuScene()
        }
    }
    
    
    func gameWin() {
        // 1. Garante que o código de game over só rode uma vez
        
        // Pausa a cena para congelar a ação
        self.isPaused = true
        
        // --- 2. Criar e configurar a imagem de fundo ---
        let gameWinBackground = SKSpriteNode(imageNamed: "levelOneBackground")
        gameWinBackground.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        gameWinBackground.size = self.size // Faz a imagem cobrir a tela inteira
        gameWinBackground.zPosition = 100 // Um valor bem alto para garantir que fique na frente de tudo
        
        
        // --- 3. Criar e configurar o texto ---
        let gameWinLabel = SKLabelNode(fontNamed: "Retro Gaming") // Usando uma fonte que você já usa na cena
//        gameWinLabel.text = "Parabéns, você salvou o Academy!"
        gameWinLabel.fontSize = 32
        gameWinLabel.fontColor = .black
        gameWinLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        gameWinLabel.zPosition = 101 // Na frente do background
        
        // Para que o texto quebre a linha em telas menores
        gameWinLabel.numberOfLines = 0
        gameWinLabel.preferredMaxLayoutWidth = self.size.width - 60 // Define uma largura máxima com margens
        
        
        // --- 4. Adicionar os elementos na cena ---
        addChild(gameWinBackground)
        addChild(gameWinLabel)
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            // O código aqui dentro será executado após 3 segundos, mesmo com a cena pausada.
            self?.presentMenuScene()
        }
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
    
    
    
//    func calculatePlayerMovement() {
        // Movimentação por botões de tela
//        if activeTouches.values.contains(leftButton) {
//            player.movePlayer(direction: -1, maxWidth: size.width)
//        }
//        if activeTouches.values.contains(rightButton) {
//            player.movePlayer(direction: 1, maxWidth: size.width)
//        }
        
        // Movimentação por gestos
        
//        switch arController.gesture {
//        case .open:
//            player.movePlayer(direction: 1, maxWidth: size.width)
//        case .closed:
//            player.movePlayer(direction: -1, maxWidth: size.width)
//        case .background:
//            player.movePlayer(direction: 0, maxWidth: size.width)
//        }
//        player.movePlayer(direction: gestureDirection, maxWidth: size.width)
    
    
    
    
    func presentMenuScene() {
        let scene = MenuScene(size: self.size)
        scene.scaleMode = self.scaleMode
        self.view?.presentScene(scene)
    }
        
    
//    func handleGesture(gesture: HandPoses) {
//        switch gesture {
//        case .open:
//            gestureDirection = 1
//        case .closed:
//            gestureDirection = -1
//        case .background:
//            gestureDirection = 0
//        }
//    }
    
}

enum MovementState{
    case none
    case forward
    case backward
}

