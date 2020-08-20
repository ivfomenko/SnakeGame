//
//  ContentView.swift
//  SnakeGame
//
//  Created by Ivan Fomenko on 20.08.2020.
//  Copyright © 2020 ivanfomenko. All rights reserved.
//

import SwiftUI
import Combine

// MARK: - View
struct ContentView: View {
    
    /// The start poisition of our swipe
    @State private var startPos : CGPoint = .zero
    
    /// State marker for user's swipe start
    @State private var isStarted = true
    
    /// State marker for ending the game when the snake hits the screen borders
    @State private var gameOver = false
    
    /// The direction the snake is going to take
    @State private var dir = Direction.down
    
    /// array of the snake's body positions
    @State private var posArray = [CGPoint(x: 0, y: 0)]
    
    /// The position of the food
    @State private var foodPos = CGPoint(x: 0, y: 0)
    
    /// Width and height of the snake
    private let snakeSize : CGFloat = 10
    
    /// To updates the snake position every 0.1 second
    private let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    // - Private UI Screens params
    private let minX = UIScreen.main.bounds.minX
    private let maxX = UIScreen.main.bounds.maxX
    private let minY = UIScreen.main.bounds.minY
    private let maxY = UIScreen.main.bounds.maxY
    
    // - Body
    var body: some View {
        ZStack {
            Color.white
            ZStack {
                Color.white
                ZStack {
                    ForEach (0..<posArray.count, id: \.self) { index in
                        Rectangle()
                            .frame(width: self.snakeSize, height: self.snakeSize)
                            .position(self.posArray[index])
                    }
                    Rectangle()
                        .fill(Color.red)
                        .frame(width: snakeSize, height: snakeSize)
                        .position(foodPos)
                }
                
                if self.gameOver {
                    VStack(spacing: 8.0) {
                        Text("Game Over").font(.headline)
                        Text("Your score: \(self.posArray.count - 1)").font(.subheadline)
                    }
                    
                }
            }
        }
        .onAppear() {
            self.foodPos = self.changeRectPos()
            self.posArray[0] = self.changeRectPos()
        }
        .gesture(DragGesture()
        .onChanged { gesture in
            if self.isStarted {
                self.startPos = gesture.location
                self.isStarted.toggle()
            }
        }
        .onEnded {  gesture in
            let xDist =  abs(gesture.location.x - self.startPos.x)
            let yDist =  abs(gesture.location.y - self.startPos.y)
            if self.startPos.y <  gesture.location.y && yDist > xDist {
                self.dir = Direction.down
            }
            else if self.startPos.y >  gesture.location.y && yDist > xDist {
                self.dir = Direction.up
            }
            else if self.startPos.x > gesture.location.x && yDist < xDist {
                self.dir = Direction.right
            }
            else if self.startPos.x < gesture.location.x && yDist < xDist {
                self.dir = Direction.left
            }
            self.isStarted.toggle()
            }
        )
        .onReceive(timer) { (_) in
            if !self.gameOver {
                self.changeDirection()
                if self.posArray[0] == self.foodPos {
                    self.posArray.append(self.posArray[0])
                    self.foodPos = self.changeRectPos()
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

// MARK: - Logic
extension ContentView {
    
    private func changeRectPos() -> CGPoint {
        let rows = Int(maxX / snakeSize)
        let cols = Int(maxY / snakeSize)
        
        let randomX = Int.random(in: 1..<rows) * Int(snakeSize)
        let randomY = Int.random(in: 1..<cols) * Int(snakeSize)
        
        return CGPoint(x: randomX, y: randomY)
    }
    
    private func changeDirection () {
        if self.posArray[0].x < minX || self.posArray[0].x > maxX && !gameOver{
            gameOver.toggle()
        }
        else if self.posArray[0].y < minY || self.posArray[0].y > maxY  && !gameOver {
            gameOver.toggle()
        }
        var prev = posArray[0]
        if dir == .down {
            self.posArray[0].y += snakeSize
        } else if dir == .up {
            self.posArray[0].y -= snakeSize
        } else if dir == .left {
            self.posArray[0].x += snakeSize
        } else {
            self.posArray[0].x -= snakeSize
        }
        
        for index in 1..<posArray.count {
            let current = posArray[index]
            posArray[index] = prev
            prev = current
        }
    }
}
