//
//  GameScene.swift
//  FlapFlap
//
//  Created by mihriban minaz on 3/20/18.
//  Copyright © 2018 mihriban minaz. All rights reserved.
//

import SpriteKit
import GameplayKit

struct CollisionBitMask {
    static let birdCategory:UInt32 = 0x1 << 0
    static let groundCategory:UInt32 = 0x1 << 1
    static let foodCategory:UInt32 = 0x1 << 2
    static let pipeCategory:UInt32 = 0x1 << 3
}

class GameScene: SKScene, SKPhysicsContactDelegate {

    var gameStarted = Bool(false)
    var birdFell = Bool(false)

    var score = Int(0)
    var topScote = Int(0)
    var scoreLbl = SKLabelNode()
    var topScoreLbl = SKLabelNode()
    var wholePipe = SKNode()
    var moveAndRemove = SKAction()

    //BIRD ATLAS
    let birdAtlas = SKTextureAtlas(named:"bird")
    var birdSprites = Array<SKTexture>()
    var bird = SKSpriteNode()
    var repeatActionbird = SKAction()

    var replayBtn = SKSpriteNode()

    override func didMove(to view: SKView) {
        createScene()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameStarted == false{
            gameStarted =  true
            bird.physicsBody?.affectedByGravity = true

            self.bird.run(repeatActionbird)
            
            let generateGameElements = SKAction.run({
                () in
                self.wholePipe = self.createPipes()
                self.addChild(self.wholePipe)
            })

            let delay = SKAction.wait(forDuration: 1.5)
            let SpawnDelay = SKAction.sequence([generateGameElements, delay])
            let spawnDelayForever = SKAction.repeatForever(SpawnDelay)
            self.run(spawnDelayForever)
            
            let distance = CGFloat(self.frame.width + wholePipe.frame.width)
            let movePipes = SKAction.moveBy(x: -distance - 50, y: 0, duration: TimeInterval(0.008 * distance))
            let removePipes = SKAction.removeFromParent()
            moveAndRemove = SKAction.sequence([movePipes, removePipes])
            
            bird.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 120))
        } else {
            if birdFell == false {
                bird.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 120))
            }
        }

        for touch in touches{
            let location = touch.location(in: self)
            if birdFell == true {
                if replayBtn.contains(location){
                    if UserDefaults.standard.object(forKey: "topScore") != nil {
                        let hscore = UserDefaults.standard.integer(forKey: "topScore")
                        if hscore < Int(scoreLbl.text!)!{
                            UserDefaults.standard.set(scoreLbl.text, forKey: "topScore")
                        }
                    } else {
                        UserDefaults.standard.set(0, forKey: "topScore")
                    }
                    
                    replay()
                }
            }
        }
    }

    func replay(){
        self.removeAllChildren()
        self.removeAllActions()
        birdFell = false
        gameStarted = false
        score = 0
        createScene()
    }

    func createScene(){
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsBody?.categoryBitMask = CollisionBitMask.groundCategory
        self.physicsBody?.collisionBitMask = CollisionBitMask.birdCategory
        self.physicsBody?.contactTestBitMask = CollisionBitMask.birdCategory
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

        scoreLbl = createScoreLabel()
        self.addChild(scoreLbl)
        topScoreLbl = createTopScoreLabel()
        self.addChild(topScoreLbl)
    }

    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB

        if firstBody.categoryBitMask == CollisionBitMask.birdCategory
            && secondBody.categoryBitMask == CollisionBitMask.groundCategory
            || firstBody.categoryBitMask == CollisionBitMask.groundCategory
            && secondBody.categoryBitMask == CollisionBitMask.birdCategory
            || firstBody.categoryBitMask == CollisionBitMask.birdCategory && secondBody.categoryBitMask == CollisionBitMask.pipeCategory
            || firstBody.categoryBitMask == CollisionBitMask.pipeCategory && secondBody.categoryBitMask == CollisionBitMask.birdCategory {

            enumerateChildNodes(withName: "wholePipe", using: ({
                (node, error) in
                node.speed = 0
                self.removeAllActions()
            }))
            
            if birdFell == false{
                birdFell = true
                createReplayBtn()
                self.bird.removeAllActions()
            }
        } else if firstBody.categoryBitMask == CollisionBitMask.birdCategory && secondBody.categoryBitMask == CollisionBitMask.foodCategory
        || firstBody.categoryBitMask == CollisionBitMask.foodCategory && secondBody.categoryBitMask == CollisionBitMask.birdCategory {
            score += 1
            scoreLbl.text = "\(score)"
            firstBody.categoryBitMask == CollisionBitMask.birdCategory ? secondBody.node?.removeFromParent() : firstBody.node?.removeFromParent()
        }
    }

   
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if gameStarted && birdFell == false {
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
    
}
