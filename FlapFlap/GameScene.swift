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
}

class GameScene: SKScene, SKPhysicsContactDelegate {

    var gameStarted = Bool(false)
    var birdFell = Bool(false)

    var score = Int(0)
    var scoreLbl = SKLabelNode()

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

            var elementGenerated: SKSpriteNode?
            let generateGameElements = SKAction.run({
                () in
                elementGenerated = self.createFood()
                if let foodElement = elementGenerated {
                    self.addChild(foodElement)
                    let distance = CGFloat(self.frame.width + foodElement.frame.width)
                    let movePipes = SKAction.moveBy(x: -distance - 50, y: 0, duration: TimeInterval(0.008 * distance))
                    let removePipes = SKAction.removeFromParent()
                    let moveAndRemove = SKAction.sequence([movePipes, removePipes])
                    foodElement.run(moveAndRemove)
                }
            })

            let delay = SKAction.wait(forDuration: 1.5)
            let SpawnDelay = SKAction.sequence([generateGameElements, delay])
            let spawnDelayForever = SKAction.repeatForever(SpawnDelay)
            self.run(spawnDelayForever)
            bird.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 80))
        } else {
            if birdFell == false {
                bird.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 80))
            }
        }

        for touch in touches{
            let location = touch.location(in: self)
            if birdFell == true {
                if replayBtn.contains(location){
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
    }

    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB

        if firstBody.categoryBitMask == CollisionBitMask.birdCategory
            && secondBody.categoryBitMask == CollisionBitMask.groundCategory
            || firstBody.categoryBitMask == CollisionBitMask.groundCategory
            && secondBody.categoryBitMask == CollisionBitMask.birdCategory {

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

    func createBird() -> SKSpriteNode {
        let bird = SKSpriteNode(texture: SKTextureAtlas(named:"bird").textureNamed("bird1"))
        bird.size = CGSize(width: 100, height: 100)
        bird.position = CGPoint(x:self.frame.midX, y:self.frame.midY)

        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.width / 2)
        bird.physicsBody?.linearDamping = 1.1
        bird.physicsBody?.restitution = 0
        bird.physicsBody?.categoryBitMask = CollisionBitMask.birdCategory
        bird.physicsBody?.collisionBitMask = CollisionBitMask.groundCategory
        bird.physicsBody?.contactTestBitMask = CollisionBitMask.groundCategory | CollisionBitMask.foodCategory
        bird.physicsBody?.affectedByGravity = false
        bird.physicsBody?.isDynamic = true

        return bird
    }

    func createFood() -> SKSpriteNode {
        let avocadoNode = SKSpriteNode(imageNamed: "avocado")
        avocadoNode.size = CGSize(width: 40, height: 40)
        avocadoNode.position = CGPoint(x: self.frame.width + 25, y: self.frame.height / 2 + 50)
        avocadoNode.physicsBody = SKPhysicsBody(rectangleOf: avocadoNode.size)
        avocadoNode.physicsBody?.affectedByGravity = false
        avocadoNode.physicsBody?.isDynamic = false
        avocadoNode.physicsBody?.categoryBitMask = CollisionBitMask.foodCategory
        avocadoNode.physicsBody?.collisionBitMask = 0
        avocadoNode.physicsBody?.contactTestBitMask = CollisionBitMask.birdCategory
        avocadoNode.color = SKColor.blue

        return avocadoNode
    }

    func createScoreLabel() -> SKLabelNode {
        let scoreLbl = SKLabelNode()
        scoreLbl.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2 + self.frame.height / 2.6)
        scoreLbl.text = "\(score)"
        scoreLbl.zPosition = 10
        scoreLbl.fontSize = 40
        scoreLbl.fontColor = UIColor.red
        return scoreLbl
    }

    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if gameStarted || !birdFell {
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

    func createReplayBtn() {
        replayBtn = SKSpriteNode(imageNamed: "replay")
        replayBtn.size = CGSize(width:150, height:150)
        replayBtn.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        replayBtn.zPosition = 6
        replayBtn.setScale(0)
        self.addChild(replayBtn)
        replayBtn.run(SKAction.scale(to: 1.0, duration: 0.3))
    }

}
