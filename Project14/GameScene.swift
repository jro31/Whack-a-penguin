import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var slots = [WhackSlot]()
    var gameScore: SKLabelNode!
    var score = 0 {
        didSet {
            gameScore.text = "Score: \(score)"
        }
    }
    var highScoreLabel: SKLabelNode!
    var popupTime = 0.85
    var numRounds = 0
    var gameStarted = false
    var gameOver: SKSpriteNode!
    var touchToBegin: SKLabelNode!
    let defaults = UserDefaults.standard
    var highScore = 0
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "whackBackground")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        touchToBegin = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
        touchToBegin.text = "Tap anywhere to begin"
        touchToBegin.position = CGPoint(x: frame.midX, y: frame.midY)
        touchToBegin.fontSize = 70
        touchToBegin.zPosition = 2
        addChild(touchToBegin)
        
        gameScore = SKLabelNode(fontNamed: "Chalkduster")
        gameScore.text = "Score: 0"
        gameScore.position = CGPoint(x: 8, y: 8)
        gameScore.horizontalAlignmentMode = .left
        gameScore.fontSize = 48
        addChild(gameScore)
        
        highScore = defaults.object(forKey: "highScore") as? Int ?? 0
        
        highScoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        highScoreLabel.text = "High score: \(highScore)"
        highScoreLabel.position = CGPoint(x: frame.maxX - 8, y: 8)
        highScoreLabel.horizontalAlignmentMode = .right
        highScoreLabel.fontSize = 48
        addChild(highScoreLabel)
        
        for i in 0 ..< 5 { createSlot(at: CGPoint(x: 100 + (i * 170), y: 410)) }
        for i in 0 ..< 4 { createSlot(at: CGPoint(x: 180 + (i * 170), y: 320)) }
        for i in 0 ..< 5 { createSlot(at: CGPoint(x: 100 + (i * 170), y: 230)) }
        for i in 0 ..< 4 { createSlot(at: CGPoint(x: 180 + (i * 170), y: 140)) }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        print("I'm the touchesBegan() function")
        
        if gameStarted == false {
            startGame()
        }
        if let touch = touches.first {
            let location = touch.location(in: self)
            let tappedNodes = nodes(at: location)
            
            for node in tappedNodes {
                if node.name == "charFriend" {
                    let whackSlot = node.parent!.parent as! WhackSlot
                    if !whackSlot.isVisible { continue }
                    if whackSlot.isHit { continue }
                    
                    whackSlot.hit()
                    score -= 5
                    
                    run(SKAction.playSoundFileNamed("whackBad.caf", waitForCompletion: false))
                } else if node.name == "charEnemy" {
                    let whackSlot = node.parent!.parent as! WhackSlot
                    if !whackSlot.isVisible { continue }
                    if whackSlot.isHit { continue }
                    
                    whackSlot.charNode.xScale = 0.85
                    whackSlot.charNode.yScale = 0.85
                    
                    whackSlot.hit()
                    score += 1
                    
                    run(SKAction.playSoundFileNamed("whack.caf", waitForCompletion: false))
                }
            }
        }
    }
    
    func startGame() {
        
        print("I'm the startGame() function")
        
        numRounds = 0
        
        if touchToBegin != nil {
            touchToBegin.isHidden = true
        }
        
        if gameOver != nil {
            if gameOver.isHidden == false {
                gameOver.isHidden = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            [unowned self] in
            self.createEnemy()
            
            self.score = 0
            self.gameStarted = true
            
        }
    }
    
    func createSlot(at position: CGPoint) {
        let slot = WhackSlot()
        slot.configure(at: position)
        addChild(slot)
        slots.append(slot)
    }
    
    func createEnemy() {
        
        print("I'm the createEnemy() function")
        
        numRounds += 1
        
        if numRounds >= 50 {
            for slot in slots {
                slot.hide()
            }
            
            gameOver = SKSpriteNode(imageNamed: "gameOver")
            gameOver.position = CGPoint(x: 512, y: 384)
            gameOver.zPosition = 1
            addChild(gameOver)
            
            gameStarted = false
            
            if score > highScore {
                persistHighScore()
            }
            
            return
        }
        
        popupTime *= 0.991
        
        slots = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: slots) as! [WhackSlot]
        slots[0].show(hideTime: popupTime)
        
        if RandomInt(min: 0, max: 12) > 4 {
            slots[1].show(hideTime: popupTime)
        }
        if RandomInt(min: 0, max: 12) > 8 {
            slots[2].show(hideTime: popupTime)
        }
        if RandomInt(min: 0, max: 12) > 10 {
            slots[3].show(hideTime: popupTime)
        }
        if RandomInt(min: 0, max: 12) > 11 {
            slots[4].show(hideTime: popupTime)
        }
        
        let minDelay = popupTime / 2.0
        let maxDelay = popupTime * 2
        let delay = RandomDouble(min: minDelay, max: maxDelay)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            [unowned self] in
            self.createEnemy()
        }
    }
    
    func persistHighScore() {
        
        print("I'm the persistHighScore() function")
        
        highScore = score
        defaults.set(highScore, forKey: "highScore")
        highScoreLabel.text = "High score: \(highScore)"
    }
}
