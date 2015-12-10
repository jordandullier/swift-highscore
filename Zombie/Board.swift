//
//  Board.swift
//  Board
//
//  Created by Pierre Kopaczewski on 20/08/2015.
//  Copyright © 2015 PierreKopa. All rights reserved.
//

import UIKit

extension Array where Element: Equatable {
    mutating func removeObject(object: Element) {
        if let index = self.indexOf(object) {
            self.removeAtIndex(index)
        }
    }
    
    mutating func removeObjectsInArray(array: [Element]) {
        for object in array {
            self.removeObject(object)
        }
    }
}

class Board: UIView {
    
    var width = 15
    var height = 23
    
    var player:Player = Player()
    var zombies:[Zombie] = []
    
    // logic
    func centerPlayer () {
        self.player.position = (Int(self.width/2),Int(self.height/2))
    }
    
    func spawnNewZombie() {
        let zombie = Zombie()
        self.zombies.append(zombie)
        zombie.position = (Int(arc4random_uniform(UInt32(self.width))),Int(arc4random_uniform(UInt32(self.height))))
        
    }
    
    func moveZombies () {
        for zombie in self.zombies {
            zombie.randomMove(self)
        }
    }
    
    func killZombiesUnderPlayer() {
        for zombie in self.zombies {
            if (zombie.position.0 == self.player.position.0) && (zombie.position.1 == self.player.position.1) {
                // kill

            }
        }
    }
    
    func checkIfplayerIsInDanger(){
        var res:Bool = false
        for zombie in self.zombies {
            if self.isClose(zombie.position, position2: self.player.position) {
                res = true
            }
        }

        if (res) {
            self.player.health--
        }
    }
    
    func isClose(position1:(Int,Int),position2:(Int,Int)) -> Bool {
        var res:Bool = false
        
        if ((position1.0 == position2.0) && (abs(position1.1-position2.1) < 2)) {
            res = true
        }
        
        if ((position1.1 == position2.1) && (abs(position1.0-position2.0) < 2)) {
            res = true
        }
        
        return res
    }
    
    // draw
    override func drawRect(rect: CGRect) {
        
        for y in 0...self.height { // lines
            for x in 0...self.width { // columns
                let rand = Double(arc4random_uniform(UInt32(6)))
                UIColor(white: CGFloat(((248.0+rand)/255.0)), alpha: 1).set()
                UIRectFill(self.rectForCoordinate(x, y:y))
            }
        }
        
        for zombie in self.zombies {
            if let previousPos = zombie.previousPosition {
                if self.isClose(previousPos, position2: zombie.position) {
                    // draw line
                    let prevRect = self.rectForCoordinate(previousPos.0, y: previousPos.1)
                    let actualRect = self.rectForCoordinate(zombie.position.0, y: zombie.position.1)
                    
                    let prevRectPoint = CGPointMake(CGRectGetMidX(prevRect) , CGRectGetMidY(prevRect))
                    let actualRectPoint = CGPointMake(CGRectGetMidX(actualRect) , CGRectGetMidY(actualRect))
                    
                    self.drawLineFrom(prevRectPoint, toPoint: actualRectPoint)
                    
                }
            }
        }
        
        for zombie in self.zombies {
            UIColor(colorLiteralRed: 0.68, green: 0.91, blue: 0.88, alpha: 1.0).set()
            UIRectFill(self.rectForCoordinate(zombie.position.0, y:zombie.position.1))
        }
        
        UIColor(colorLiteralRed: 0.44, green: 0.41, blue: 0.38, alpha: 1.0).set()
        UIRectFill(self.rectForCoordinate(self.player.position.0, y:self.player.position.1))

    }
    
    func drawLineFrom(fromPoint: CGPoint, toPoint: CGPoint) {
                
        let context = UIGraphicsGetCurrentContext()
        CGContextSetLineWidth(context, 2.0)
        CGContextSetLineCap(context, CGLineCap.Round)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let components: [CGFloat] = [0.68, 0.91, 0.88, 1.0]
        let color = CGColorCreate(colorSpace, components)
        CGContextSetStrokeColorWithColor(context, color)
        CGContextMoveToPoint(context, fromPoint.x, fromPoint.y)
        CGContextAddLineToPoint(context, toPoint.x, toPoint.y)
        CGContextStrokePath(context)
    }
    
    // geometry
    func squareSize() -> CGSize {
        return CGSizeMake(CGFloat(self.bounds.width/CGFloat(self.width)), CGFloat(self.bounds.height/CGFloat(self.height)))
    }
    
    func rectForCoordinate(x : Int, y : Int) -> CGRect {
        
        let squareSize = self.squareSize()
        
        return CGRectMake(CGFloat(x)*squareSize.width, CGFloat(y)*squareSize.height, squareSize.width, squareSize.height)
    }
    
}