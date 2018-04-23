//
//  GameInstances.swift
//  FlapFlap
//
//  Created by Mihri on 23.04.18.
//  Copyright © 2018 mihriban minaz. All rights reserved.
//

import SpriteKit

extension GameScene {
    
    func createBird() -> SKSpriteNode {
        let bird = SKSpriteNode(texture: SKTextureAtlas(named:"bird").textureNamed("bird1"))
        bird.size = CGSize(width: 80, height: 80)
        bird.position = CGPoint(x:self.frame.midX, y:self.frame.midY)
        
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.width / 2)
        bird.physicsBody?.linearDamping = 1.1
        bird.physicsBody?.restitution = 0
        bird.physicsBody?.categoryBitMask = CollisionBitMask.birdCategory
        bird.physicsBody?.collisionBitMask = CollisionBitMask.groundCategory | CollisionBitMask.pipeCategory
        bird.physicsBody?.contactTestBitMask = CollisionBitMask.groundCategory | CollisionBitMask.foodCategory | CollisionBitMask.pipeCategory
    
        bird.physicsBody?.affectedByGravity = false
        bird.physicsBody?.isDynamic = true
        bird.zPosition = 7
        
        return bird
    }
    
    func createFood(point: CGPoint) -> SKSpriteNode {
        let avocadoNode = SKSpriteNode(imageNamed: "avocado")
        avocadoNode.size = CGSize(width: 40, height: 40)
        avocadoNode.position = point
        avocadoNode.physicsBody = SKPhysicsBody(rectangleOf: avocadoNode.size)
        avocadoNode.physicsBody?.affectedByGravity = false
        avocadoNode.physicsBody?.isDynamic = false
        avocadoNode.physicsBody?.categoryBitMask = CollisionBitMask.foodCategory
        avocadoNode.physicsBody?.collisionBitMask = 0
        avocadoNode.physicsBody?.contactTestBitMask = CollisionBitMask.birdCategory
        avocadoNode.color = SKColor.blue
        avocadoNode.zPosition = 5
        
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
    
    func createTopScoreLabel() -> SKLabelNode {
        let topScoreLbl = SKLabelNode()
        topScoreLbl.position = CGPoint(x: 40, y: 10)
        if let topScoreValue = UserDefaults.standard.object(forKey: "topScore"){
            topScoreLbl.text = "Top Score: \(topScoreValue)"
        } else {
            topScoreLbl.text = "Top Score: 0"
        }
        
        topScoreLbl.zPosition = 10
        topScoreLbl.fontSize = 10
        topScoreLbl.fontColor = UIColor.purple
        return topScoreLbl
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
    
    func createPipes() -> SKNode  {
        wholePipe = SKNode()
        wholePipe.name = "wholePipe"
        
        let topPipe = SKSpriteNode(imageNamed: "pipe")
        let bottomPipe = SKSpriteNode(imageNamed: "pipe")
        
        topPipe.position = CGPoint(x: self.frame.width + 25, y: self.frame.height / 2 + 420)
        bottomPipe.position = CGPoint(x: self.frame.width + 25, y: self.frame.height / 2 - 420)
        
        topPipe.setScale(0.5)
        bottomPipe.setScale(0.5)
        
        topPipe.physicsBody = SKPhysicsBody(rectangleOf: topPipe.size)
        topPipe.physicsBody?.categoryBitMask = CollisionBitMask.pipeCategory
        topPipe.physicsBody?.collisionBitMask = CollisionBitMask.birdCategory
        topPipe.physicsBody?.contactTestBitMask = CollisionBitMask.birdCategory
        topPipe.physicsBody?.isDynamic = false
        topPipe.physicsBody?.affectedByGravity = false
        
        bottomPipe.physicsBody = SKPhysicsBody(rectangleOf: bottomPipe.size)
        bottomPipe.physicsBody?.categoryBitMask = CollisionBitMask.pipeCategory
        bottomPipe.physicsBody?.collisionBitMask = CollisionBitMask.birdCategory
        bottomPipe.physicsBody?.contactTestBitMask = CollisionBitMask.birdCategory
        bottomPipe.physicsBody?.isDynamic = false
        bottomPipe.physicsBody?.affectedByGravity = false
        
        topPipe.zRotation = CGFloat(Double.pi)
        
        wholePipe.addChild(topPipe)
        wholePipe.addChild(bottomPipe)
        
        wholePipe.zPosition = 1
        
        let randomPosition = random(min: -200, max: 200)
        wholePipe.position.y = wholePipe.position.y +  randomPosition
    
        let foodPosition = CGPoint(x: self.frame.width + 25, y: bottomPipe.position.y + self.frame.height / 2 + 50)
        let foodNode = createFood(point: foodPosition)
        wholePipe.addChild(foodNode)
        
        wholePipe.run(moveAndRemove)
        
        return wholePipe
    }
    
    func random(min : CGFloat, max : CGFloat) -> CGFloat{
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF) * (max - min) + min
    }

}

