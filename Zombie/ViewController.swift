//
//  ViewController.swift
//  Zombie
//
//  Created by Pierre Kopaczewski on 08/12/2015.
//  Copyright © 2015 Pierre Kopaczewski. All rights reserved.
//

import UIKit
import FBSDKShareKit
import FBSDKLoginKit
import Alamofire
import SwiftyJSON

class ViewController: UIViewController,UITableViewDelegate, UITableViewDataSource,FBSDKLoginButtonDelegate {

    @IBOutlet var pointsLabel : UILabel?
    @IBOutlet var healthLabel : UILabel?
    @IBOutlet var board : Board?
    @IBOutlet var gameOverButton : UIButton?
    @IBOutlet var highScoreTableView: UITableView!
    
    var items: [String]? = []


    var turns = 0
    var playerName:String = ""
    let facebookReadPermissions = ["public_profile"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createFacebookButtons()
        highScoreTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        // Do any additional setup after loading the view, typically from a nib.

        if (FBSDKAccessToken.currentAccessToken() != nil)
        {
            // User is already logged in, do work such as go to next view controller.
            returnUserData()
        }
        else
        {
            let loginView : FBSDKLoginButton = FBSDKLoginButton()
            self.view.addSubview(loginView)
            loginView.center = self.view.center
            loginView.readPermissions = ["public_profile", "mail", "user_friends"]
            loginView.delegate = self
        }
        self.initGame()
        
    }
        
    func initGame() {
        
        self.board!.centerPlayer()
        for _ in 0...Settings.initialZombiesNumber {
            self.board?.spawnNewZombie()
        }
        
        self.syncWithPlayer((self.board?.player)!)
        
        self.gameOverButton?.hidden = true
        self.highScoreTableView?.hidden = true
    }
    
    @IBAction func moveNorth() {
        print("player moved to the north")
        self.board?.player.moveTo(Direction.North, board: self.board!)
        self.turn()
    }
    
    @IBAction func moveSouth() {
        print("player moved to the south")
        self.board?.player.moveTo(Direction.South, board: self.board!)
        self.turn()
    }
    
    @IBAction func moveEast() {
        print("player moved to the east")
        self.board?.player.moveTo(Direction.East, board: self.board!)
        self.turn()
    }
    
    @IBAction func moveWest() {
        print("player moved to the west")
        self.board?.player.moveTo(Direction.West, board: self.board!)
        self.turn()
    }
    
    func turn() {
        
        self.board?.killZombiesUnderPlayer()
        
        self.board?.moveZombies()
        
        if ((self.turns % Settings.turnsBetweenZombieSpawn) == 0 ) {
            self.board?.spawnNewZombie()
        }
        
        self.board?.setNeedsDisplay()

        self.board?.checkIfplayerIsInDanger()
        
        self.syncWithPlayer((self.board!.player))

        if (self.board?.player.health < 1) {
            self.gameOver()
            return
        }
        
        self.pointsLabel?.text = "\(self.turns)"
        
        
        self.turns++
    }
    
    func saveScoreIfNeeded() {
        let highestScore = NSUserDefaults.standardUserDefaults().integerForKey("highscore")
        if (highestScore < self.turns) {
            NSUserDefaults.standardUserDefaults().setInteger(self.turns, forKey: "highscore")
            let author = NSUserDefaults.standardUserDefaults().objectForKey("currentauthor")
            NSUserDefaults.standardUserDefaults().setObject(author, forKey: "highscoreauthor")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }

    func syncWithPlayer(player : Player) {
        
        var healthString = ""
        if player.health < 1 {
            // ok
        } else {
            for _ in 1...player.health {
                healthString += "❤️"
            }
        }
        
        self.healthLabel?.text = healthString
    }
    
    func gameOver() {
        self.saveScoreIfNeeded()
        self.gameOverButton?.hidden = false
        self.highScoreTableView?.hidden = false
        createFacebookButtons()
        sendData(String(self.turns),nomJoueur: self.playerName)
        getBestResults()
        
    }
    
    @IBAction func leave () {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        print("User Logged In")
        
        if ((error) != nil)
        {
            // Process error
        }
        else if result.isCancelled {
            // Handle cancellations
        }
        else {
            // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
            if result.grantedPermissions.contains("email")
            {
                // Do work
            }
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("User Logged Out")
    }
    
    func returnUserData()
    {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) != nil)
            {
                // Process error
                print("Error: \(error)")
            }
            else
            {
                //print("fetched user: \(result)")
                let userName : NSString = result.valueForKey("name") as! NSString
                self.playerName = "le vrai \(userName)"
                print("User Name is: \(userName)")
            }
        })
    }
    
    func createFacebookButtons(){
        let content : FBSDKShareLinkContent = FBSDKShareLinkContent()
        content.contentURL = NSURL(string: "<www.lequipe.fr>")
        content.contentTitle = "<PARTAGE>"
        content.contentDescription = "<Description du partage>"
        content.imageURL = NSURL(string: "<INSERT STRING HERE>")
        
        let button : FBSDKShareButton = FBSDKShareButton()
        let likeButton : FBSDKLikeButton = FBSDKLikeButton()
        
        button.shareContent = content
        button.frame = CGRectMake((UIScreen.mainScreen().bounds.width - 225) * 0.5, 50, 80, 25)
        self.view.addSubview(button)
        
        likeButton.frame = CGRectMake((UIScreen.mainScreen().bounds.width - 75) * 0.6, 50, 80, 25)
        self.view.addSubview(likeButton)
    }
    
    func sendData(score:String,nomJoueur:String){
        let parameters = [
            "score": "501",
            "player": "Vladimir"
        ]
        
        Alamofire.request(.POST, "http://scenies.com/insset_api/services/zombie/publishScore.php", parameters: parameters)
    }
    
    func getBestResults(){
        Alamofire.request(.GET, "http://scenies.com/insset_api/services/zombie/scores.json")
            .responseJSON { response in
                
                if let json = response.result.value {
                    let results = JSON(json)
                    let jsonArray = results.arrayValue
                    let sortedResults = jsonArray.sort { $0["score"].doubleValue > $1["score"].doubleValue }
                    //print("JSON: \(sortedResults)")
                    
                   for index in 0...5 {
 
                     var score_index = sortedResults[index]["score"]
                     var player_index = sortedResults[index]["player"]
                     self.items?.append("\(score_index) : \(player_index)")
                   }
                    
                }
                
                
                self.highScoreTableView.delegate      =   self
                self.highScoreTableView.dataSource    =   self
                self.highScoreTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
                
        }
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
        
        cell.textLabel?.text = self.items![indexPath.row]
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("You selected cell #\(indexPath.row)!")
    }
}

