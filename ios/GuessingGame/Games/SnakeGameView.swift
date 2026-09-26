// SnakeGameView.swift
// iOS version of Snake Game - iPhone 15 Portrait Optimized

import SwiftUI
import SpriteKit

struct SnakeGameView: View {
    let onFlip: () -> Void
    
    @StateObject private var gameModel = SnakeGameModel()
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    private var isPortrait: Bool {
        verticalSizeClass == .regular && horizontalSizeClass == .compact
    }
    
    private let safeAreaTop: CGFloat = 59
    private let safeAreaBottom: CGFloat = 34
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background - full screen
                Color(red: 0.05, green: 0.06, blue: 0.09)
                    .ignoresSafeArea()
                
                // Subtle grid pattern
                GridBackground()
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header with safe area
                    HStack {
                        Button(action: onFlip) {
                            HStack(spacing: 6) {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                Text("Flip")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Color(red: 0.15, green: 0.18, blue: 0.23))
                            .cornerRadius(10)
                        }
                        Spacer()
                        Text("Snake Game")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                        Spacer()
                        // Pause button
                        Button(action: { gameModel.togglePause() }) {
                            Image(systemName: gameModel.isPaused ? "play.fill" : "pause.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding(10)
                                .background(Color(red: 0.15, green: 0.18, blue: 0.23))
                                .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, safeAreaTop + 8)
                    .padding(.bottom, 8)
                    
                    // Score bar
                    HStack {
                        Text("Score: \(gameModel.score)")
                            .font(.title3.bold())
                            .foregroundColor(.white)
                        Spacer()
                        Text("Best: \(gameModel.highScore)")
                            .font(.title3)
                            .foregroundColor(Color(red: 0.6, green: 0.65, blue: 0.72))
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
                    
                    Divider()
                        .background(Color(red: 0.2, green: 0.22, blue: 0.28))
                        .padding(.horizontal, 16)
                    
                    // Game area - SpriteKit view with proper constraints
                    SpriteView(scene: gameModel.scene, options: [.allowsTransparency])
                        .frame(
                            width: min(geometry.size.width - 32, geometry.size.height * 0.55),
                            height: min(geometry.size.width - 32, geometry.size.height * 0.55)
                        )
                        .background(Color(red: 0.06, green: 0.07, blue: 0.1))
                        .cornerRadius(12)
                        .padding(.vertical, 8)
                        // Add swipe gesture for snake control
                        .gesture(
                            DragGesture(minimumDistance: 20)
                                .onEnded { value in
                                    gameModel.handleSwipe(value.translation)
                                }
                        )
                    
                    // Controls hint
                    VStack(spacing: 6) {
                        Text("Swipe to move • Tap pause button to pause")
                            .font(.subheadline)
                            .foregroundColor(Color(red: 0.5, green: 0.55, blue: 0.62))
                        Text("Swipe with 2 fingers or tap pause")
                            .font(.caption)
                            .foregroundColor(Color(red: 0.4, green: 0.45, blue: 0.52))
                    }
                    .padding(.bottom, 12)
                    
                    // Restart button (shown when game over)
                    if gameModel.isGameOver {
                        VStack(spacing: 12) {
                            Text("GAME OVER")
                                .font(.title2.bold())
                                .foregroundColor(Color(red: 1.0, green: 0.31, blue: 0.31))
                            
                            Text("Final Score: \(gameModel.score)")
                                .font(.title3)
                                .foregroundColor(Color(red: 0.78, green: 0.78, blue: 0.86))
                            
                            Button(action: { gameModel.restart() }) {
                                Text("Restart")
                                    .font(.title3.bold())
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(Color(red: 0.18, green: 0.65, blue: 0.3))
                                    .cornerRadius(12)
                            }
                            .buttonStyle(ScaleButtonStyle())
                            .padding(.horizontal, 40)
                        }
                        .padding(.vertical, 24)
                        .background(Color(red: 0.08, green: 0.09, blue: 0.12))
                        .cornerRadius(16)
                        .padding(.horizontal, 24)
                        .transition(.scale.combined(with: .opacity))
                        .padding(.bottom, safeAreaBottom + 12)
                    }
                    
                    Spacer(minLength: 0)
                }
            }
            .onAppear {
                gameModel.setupGestures()
            }
        }
    }
}

// SpriteKit scene for smooth 60fps rendering - Portrait Optimized
class SnakeScene: SKScene {
    weak var gameModel: SnakeGameModel?
    
    private var lastUpdateTime: TimeInterval = 0
    private let gridSize = 20
    private var cellSize: CGFloat = 0
    private var gridOffset = CGPoint.zero
    
    // Colors matching desktop theme
    let backgroundColor = SKColor(red: 0.04, green: 0.05, blue: 0.06, alpha: 1.0)
    let gridLineColor = SKColor(red: 0.1, green: 0.11, blue: 0.14, alpha: 1.0)
    let headColor = SKColor(red: 0.24, green: 0.86, blue: 0.39, alpha: 1.0)
    let bodyColorStart = SKColor(red: 0.16, green: 0.71, blue: 0.27, alpha: 1.0)
    let bodyColorEnd = SKColor(red: 0.11, green: 0.47, blue: 0.18, alpha: 1.0)
    let foodColor = SKColor(red: 1.0, green: 0.31, blue: 0.31, alpha: 1.0)
    let foodGlowColor = SKColor(red: 1.0, green: 0.71, blue: 0.71, alpha: 0.8)
    
    override func didMove(to view: SKView) {
        backgroundColor = backgroundColor
        calculateLayout(view: view)
    }
    
    override func didChangeSize(_ oldSize: CGSize) {
        calculateLayout(view: view!)
    }
    
    private func calculateLayout(view: SKView) {
        // Square grid centered in view
        let padding: CGFloat = 16
        let availableWidth = view.bounds.width - padding * 2
        let availableHeight = view.bounds.height - padding * 2
        cellSize = min(availableWidth / CGFloat(gridSize), availableHeight / CGFloat(gridSize))
        
        let gridWidth = cellSize * CGFloat(gridSize)
        let gridHeight = cellSize * CGFloat(gridSize)
        gridOffset = CGPoint(
            x: (view.bounds.width - gridWidth) / 2,
            y: (view.bounds.height - gridHeight) / 2
        )
    }
    
    override func update(_ currentTime: TimeInterval) {
        guard let model = gameModel, !model.isGameOver, !model.isPaused else { return }
        
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
            return
        }
        
        let delta = currentTime - lastUpdateTime
        model.accumulator += delta
        
        while model.accumulator >= model.stepTime {
            model.accumulator -= model.stepTime
            model.step()
        }
        
        model.foodPulse += delta * 3.0
    }
    
    override func didEvaluateActions() {
        renderGame()
    }
    
    private func renderGame() {
        removeAllChildren()
        guard let model = gameModel else { return }
        
        // Draw grid background
        let gridRect = CGRect(
            x: gridOffset.x,
            y: gridOffset.y,
            width: cellSize * CGFloat(gridSize),
            height: cellSize * CGFloat(gridSize)
        )
        
        let bgNode = SKShapeNode(rect: gridRect, cornerRadius: 8)
        bgNode.fillColor = backgroundColor
        bgNode.strokeColor = .clear
        addChild(bgNode)
        
        // Grid lines
        for x in 0...gridSize {
            let line = SKShapeNode()
            let path = CGMutablePath()
            path.move(to: CGPoint(x: gridOffset.x + CGFloat(x) * cellSize, y: gridOffset.y))
            path.addLine(to: CGPoint(x: gridOffset.x + CGFloat(x) * cellSize, y: gridOffset.y + cellSize * CGFloat(gridSize)))
            line.path = path
            line.strokeColor = gridLineColor
            line.lineWidth = 1
            addChild(line)
        }
        
        for y in 0...gridSize {
            let line = SKShapeNode()
            let path = CGMutablePath()
            path.move(to: CGPoint(x: gridOffset.x, y: gridOffset.y + CGFloat(y) * cellSize))
            path.addLine(to: CGPoint(x: gridOffset.x + cellSize * CGFloat(gridSize), y: gridOffset.y + CGFloat(y) * cellSize))
            line.path = path
            line.strokeColor = gridLineColor
            line.lineWidth = 1
            addChild(line)
        }
        
        // Draw food with pulse
        if model.foodX >= 0, model.foodY >= 0 {
            let pulse = 1.0 + 0.15 * sin(model.foodPulse * 4.0)
            let foodRadius = cellSize * 0.35 * pulse
            let foodX = gridOffset.x + CGFloat(model.foodX) * cellSize + cellSize / 2
            let foodY = gridOffset.y + CGFloat(model.foodY) * cellSize + cellSize / 2
            
            // Glow
            let glow = SKShapeNode(circleOfRadius: foodRadius)
            glow.position = CGPoint(x: foodX, y: foodY)
            glow.fillColor = foodGlowColor
            glow.strokeColor = .clear
            addChild(glow)
            
            // Food
            let food = SKShapeNode(circleOfRadius: foodRadius * 0.7)
            food.position = CGPoint(x: foodX, y: foodY)
            food.fillColor = foodColor
            food.strokeColor = .clear
            addChild(food)
        }
        
        // Draw snake
        for (index, segment) in model.body.enumerated() {
            let segX = gridOffset.x + CGFloat(segment.x) * cellSize + 1
            let segY = gridOffset.y + CGFloat(segment.y) * cellSize + 1
            let segW = cellSize - 2
            let segH = cellSize - 2
            let rounding = index == 0 ? 6.0 : 4.0
            
            let segmentNode = SKShapeNode(rect: CGRect(x: segX, y: segY, width: segW, height: segH), cornerRadius: rounding)
            
            if index == 0 {
                segmentNode.fillColor = headColor
            } else {
                let t = Double(index) / Double(model.body.count)
                let r = 0.16 + 0.55 * (1.0 - t)
                let g = 0.71 + 0.15 * (1.0 - t)
                let b = 0.27 + 0.07 * (1.0 - t)
                segmentNode.fillColor = SKColor(red: r, green: g, blue: b, alpha: 1.0)
            }
            segmentNode.strokeColor = .clear
            addChild(segmentNode)
            
            // Eyes on head
            if index == 0 {
                let eyeRadius = 3.0
                let eyeY = segY + segH * 0.35
                var eyeX1 = segX + segW * 0.3
                var eyeX2 = segX + segW * 0.7
                
                switch model.direction {
                case .left:
                    eyeX1 = segX + segW * 0.2
                    eyeX2 = segX + segW * 0.6
                case .right:
                    eyeX1 = segX + segW * 0.4
                    eyeX2 = segX + segW * 0.8
                case .up:
                    eyeY = segY + segH * 0.25
                case .down:
                    eyeY = segY + segH * 0.75
                }
                
                let eye1 = SKShapeNode(circleOfRadius: eyeRadius)
                eye1.position = CGPoint(x: eyeX1, y: eyeY)
                eye1.fillColor = .white
                eye1.strokeColor = .clear
                addChild(eye1)
                
                let eye2 = SKShapeNode(circleOfRadius: eyeRadius)
                eye2.position = CGPoint(x: eyeX2, y: eyeY)
                eye2.fillColor = .white
                eye2.strokeColor = .clear
                addChild(eye2)
            }
        }
        
        // Game over overlay
        if model.isGameOver {
            let overlay = SKShapeNode(rect: gridRect, cornerRadius: 8)
            overlay.fillColor = SKColor(red: 0, green: 0, blue: 0, alpha: 0.7)
            overlay.strokeColor = .clear
            addChild(overlay)
            
            let gameOverLabel = SKLabelNode(text: "GAME OVER")
            gameOverLabel.fontName = "SFProDisplay-Bold"
            gameOverLabel.fontSize = 28
            gameOverLabel.fontColor = SKColor(red: 1.0, green: 0.31, blue: 0.31, alpha: 1.0)
            gameOverLabel.position = CGPoint(x: frame.midX, y: frame.midY + 20)
            gameOverLabel.verticalAlignmentMode = .center
            addChild(gameOverLabel)
            
            let scoreLabel = SKLabelNode(text: "Final Score: \(model.score)")
            scoreLabel.fontName = "SFProDisplay-Regular"
            scoreLabel.fontSize = 20
            scoreLabel.fontColor = SKColor(red: 0.78, green: 0.78, blue: 0.86, alpha: 1.0)
            scoreLabel.position = CGPoint(x: frame.midX, y: frame.midY - 15)
            scoreLabel.verticalAlignmentMode = .center
            addChild(scoreLabel)
        } else if model.isPaused {
            let overlay = SKShapeNode(rect: gridRect, cornerRadius: 8)
            overlay.fillColor = SKColor(red: 0, green: 0, blue: 0, alpha: 0.5)
            overlay.strokeColor = .clear
            addChild(overlay)
            
            let pausedLabel = SKLabelNode(text: "PAUSED")
            pausedLabel.fontName = "SFProDisplay-Bold"
            pausedLabel.fontSize = 28
            pausedLabel.fontColor = SKColor(red: 1.0, green: 0.78, blue: 0.31, alpha: 1.0)
            pausedLabel.position = CGPoint(x: frame.midX, y: frame.midY)
            pausedLabel.verticalAlignmentMode = .center
            addChild(pausedLabel)
        }
    }
}

// Game model with logic
class SnakeGameModel: ObservableObject {
    @Published var score = 0
    @Published var highScore = 0
    @Published var isGameOver = false
    @Published var isPaused = false
    
    let scene = SnakeScene()
    
    // Game state
    var body: [(x: Int, y: Int)] = []
    var direction: SnakeDirection = .right
    var nextDirection: SnakeDirection = .right
    var foodX = -1
    var foodY = -1
    let gridSize = 20
    var accumulator: TimeInterval = 0
    var stepTime: TimeInterval = 0.12
    var foodPulse: TimeInterval = 0
    
    init() {
        scene.gameModel = self
        loadHighScore()
        restart()
    }
    
    func setupGestures() {
        // Swipe gestures handled by SwiftUI view
    }
    
    func setDirection(_ dir: SnakeDirection) {
        let opposite: Bool
        switch direction {
        case .up: opposite = (dir == .down)
        case .down: opposite = (dir == .up)
        case .left: opposite = (dir == .right)
        case .right: opposite = (dir == .left)
        }
        if !opposite {
            nextDirection = dir
        }
    }
    
    func togglePause() {
        if !isGameOver {
            isPaused.toggle()
        }
    }
    
    func restart() {
        body = []
        let startX = gridSize / 2
        let startY = gridSize / 2
        for i in 0..<3 {
            body.append((startX - i, startY))
        }
        direction = .right
        nextDirection = .right
        score = 0
        isGameOver = false
        isPaused = false
        accumulator = 0
        stepTime = 0.12
        foodPulse = 0
        spawnFood()
    }
    
    func step() {
        direction = nextDirection
        
        var head = body[0]
        var newHead = head
        
        switch direction {
        case .up: newHead.y -= 1
        case .down: newHead.y += 1
        case .left: newHead.x -= 1
        case .right: newHead.x += 1
        }
        
        // Wall collision
        if newHead.x < 0 || newHead.x >= gridSize || newHead.y < 0 || newHead.y >= gridSize {
            gameOver()
            return
        }
        
        // Self collision
        for segment in body {
            if segment.x == newHead.x && segment.y == newHead.y {
                gameOver()
                return
            }
        }
        
        // Move
        body.insert(newHead, at: 0)
        
        // Food
        if newHead.x == foodX && newHead.y == foodY {
            score += 10
            if score % 50 == 0 && stepTime > 0.05 {
                stepTime *= 0.9
            }
            spawnFood()
        } else {
            body.removeLast()
        }
    }
    
    func spawnFood() {
        var newFood: (x: Int, y: Int)
        var valid = false
        
        for _ in 0..<100 {
            newFood = (Int.random(in: 0..<gridSize), Int.random(in: 0..<gridSize))
            valid = true
            for segment in body {
                if segment.x == newFood.x && segment.y == newFood.y {
                    valid = false
                    break
                }
            }
            if valid {
                foodX = newFood.x
                foodY = newFood.y
                foodPulse = 0
                return
            }
        }
        
        // Fallback
        foodX = gridSize / 2
        foodY = gridSize / 2
        foodPulse = 0
    }
    
    func gameOver() {
        isGameOver = true
        if score > highScore {
            highScore = score
            saveHighScore()
        }
    }
    
    private func loadHighScore() {
        highScore = UserDefaults.standard.integer(forKey: "snake_highscore")
    }
    
    private func saveHighScore() {
        UserDefaults.standard.set(highScore, forKey: "snake_highscore")
    }
    
    // Handle swipe gestures from SwiftUI
    func handleSwipe(_ translation: CGSize) {
        let absX = abs(translation.width)
        let absY = abs(translation.height)
        
        if absX > absY {
            // Horizontal swipe
            if translation.width > 0 {
                setDirection(.right)
            } else {
                setDirection(.left)
            }
        } else {
            // Vertical swipe
            if translation.height > 0 {
                setDirection(.down)
            } else {
                setDirection(.up)
            }
        }
    }
}

enum SnakeDirection {
    case up, down, left, right
}