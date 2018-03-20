//
//  GameScene.swift
//  FlapFlap
//
//  Created by mihriban minaz on 3/20/18.
//  Copyright © 2018 mihriban minaz. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {

    var gameStarted = Bool(false)
    //BIRD ATLAS
    let birdAtlas = SKTextureAtlas(named:"bird")
    var birdSprites = Array<SKTexture>()
    var bird = SKSpriteNode()
    var repeatActionbird = SKAction()

    override func didMove(to view: SKView) {
        createScene()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameStarted == false {
            gameStarted =  true
            self.bird.run(repeatActionbird)
        }
    }

    func createScene(){
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsBody?.isDynamic = false
        self.physicsBody?.affectedByGravity = false
        self.physicsWorld.contactDelegate = self

        self.backgroundColor = SKColor(red: 80.0/255.0, green: 192.0/255.0, blue: 203.0/255.0, alpha: 1.0)

        for i in 0..<2 {
            let background = SKSpriteNode(imageNamed: "bg")
            background.anchorPoint = CGPoint.init(x: 0, y: 0)
            background.position = CGPoint(x:CGFloat(i) * self.frame.width, y:0)
            background.name = "background"
            background.size = (self.view?.bounds.size)!
            self.addChild(background)
        }

        //SET UP THE BIRD SPRITES FOR ANIMATION
        birdSprites.append(birdAtlas.textureNamed("bird1"))
        birdSprites.append(birdAtlas.textureNamed("bird2"))
        birdSprites.append(birdAtlas.textureNamed("bird3"))
        birdSprites.append(birdAtlas.textureNamed("bird4"))
        birdSprites.append(birdAtlas.textureNamed("bird5"))

        self.bird = createBird()
        self.addChild(bird)

        //ANIMATE THE BIRD AND REPEAT THE ANIMATION FOREVER
        let animatebird = SKAction.animate(with: self.birdSprites, timePerFrame: 0.1)
        self.repeatActionbird = SKAction.repeatForever(animatebird)
    }

    func createBird() -> SKSpriteNode {
        let bird = SKSpriteNode(texture: SKTextureAtlas(named:"bird").textureNamed("bird1"))
        bird.size = CGSize(width: 100, height: 100)
        bird.position = CGPoint(x:self.frame.midX, y:self.frame.midY)

        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.width / 2)
        bird.physicsBody?.linearDamping = 1.1
        bird.physicsBody?.restitution = 0
        bird.physicsBody?.affectedByGravity = true
        bird.physicsBody?.isDynamic = true

        return bird
    }

    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        enumerateChildNodes(withName: "background", using: ({
            (node, error) in
            let bg = node as! SKSpriteNode
            bg.position = CGPoint(x: bg.position.x - 2, y: bg.position.y)
            if bg.position.x <= -bg.size.width {
                bg.position = CGPoint(x:bg.position.x + bg.size.width * 2, y:bg.position.y)
            }
        }))
    }

}
