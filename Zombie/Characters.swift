//
//  Player.swift
//  Zombie
//
//  Created by Pierre Kopaczewski on 08/12/2015.
//  Copyright © 2015 Pierre Kopaczewski. All rights reserved.
//

import Foundation

class Character {
    
    var previousPosition:(Int,Int)?
    var position:(Int,Int) = (0,0)
    
    func moveTo(direction : Direction, board:Board) {
        
        self.previousPosition = position
        
        switch (direction) {
        case Direction.North :
            self.position.1 = (self.position.1 == 0) ? (board.height - 1) : (self.position.1 - 1)
        case Direction.South :
            self.position.1 = (self.position.1 + 1) % board.height
        case Direction.West :
            self.position.0 = (self.position.0 == 0) ? (board.width - 1) : (self.position.0 - 1)
        case Direction.East:
            self.position.0 = (self.position.0 + 1) % board.width
        }
        
    }

}

class Player : Character {
    
    var health = Settings.initialLifePoints
    
}

class Zombie : Character {
    
    func randomMove(board:Board) {
        
        let rand = Int(arc4random_uniform(UInt32(100)))
        
        switch (rand) {
        case 0...24 : self.moveTo(Direction.North, board: board)
        case 25...49 : self.moveTo(Direction.South, board: board)
        case 50...74 : self.moveTo(Direction.East, board: board)
        case 75...100 : self.moveTo(Direction.West, board: board)
        default : print("error in Zombie.randomMove")
        }
        
    }
}
