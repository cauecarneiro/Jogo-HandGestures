//
//  GameViewController.swift


import UIKit
import SpriteKit
import GameplayKit
import HandGesturesClassifier

class GameViewController: UIViewController {
    
    //instanciando a ARViewController
    let arVC = ARViewController(cameraFrame: CGRect(x: 0, y: 0, width: 150, height: 200), isCameraHidden: false)
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let menuScene = MenuScene(size: view.bounds.size)
        menuScene.scaleMode = .aspectFill
        let skView = self.view as! SKView
        
        skView.presentScene(menuScene)
        
        // Adiciona ARViewController como child
        addChild(arVC)
        view.addSubview(arVC.view)
        arVC.didMove(toParent: self)
        
        // Configura callback de gestos
        arVC.onGestureUpdate = { [weak self] gesture in
            guard let self = self else { return }
            if let scene = skView.scene as? LevelOneScene {
                scene.handleGesture(gesture: gesture)
            }
        }

    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
}
