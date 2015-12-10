//
//  MenuViewController.swift
//  Zombie
//
//  Created by Pierre Kopaczewski on 10/12/2015.
//  Copyright © 2015 Pierre Kopaczewski. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {

    @IBOutlet var nameField:UITextField?
    @IBOutlet var highScoreLabel:UILabel?
    
    override func viewDidAppear(animated: Bool) {
        
        if NSUserDefaults.standardUserDefaults().boolForKey("currentauthor") {
            NSUserDefaults.standardUserDefaults().setObject(self.nameField!.text, forKey: "currentauthor")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        
        if (NSUserDefaults.standardUserDefaults().integerForKey("highscore") > 0) {
            self.highScoreLabel!.hidden = false
        
            let score = NSUserDefaults.standardUserDefaults().integerForKey("highscore")
            let author = NSUserDefaults.standardUserDefaults().objectForKey("highscoreauthor") as! String
            highScoreLabel?.text = "HIGH SCORE : \(score) (\(author))"
        
        } else {
        
            self.highScoreLabel!.hidden = true
        }
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        NSUserDefaults.standardUserDefaults().setObject(self.nameField!.text, forKey: "currentauthor")
        NSUserDefaults.standardUserDefaults().synchronize()

    }
}
