//
//  Settings.swift
//  Zombie
//
//  Created by Pierre Kopaczewski on 08/12/2015.
//  Copyright © 2015 Pierre Kopaczewski. All rights reserved.
//

import Foundation


class Settings {
    static let initialLifePoints = 5
    static let turnsBetweenZombieSpawn = 5
    static let initialZombiesNumber = 3
}

enum Direction {
    case North
    case South
    case East
    case West
}