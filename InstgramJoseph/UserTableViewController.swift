//
//  UserViewController.swift
//  InstagramClone
//
//  Created by Peter Sbarski on 20/05/2016.
//  Copyright © 2016 A Cloud Guru. All rights reserved.
//

import UIKit

class UserViewController: UITableViewController {
    
    let databaseService = DatabaseService()
    var credentialsProvider:AWSCognitoCredentialsProvider = AWSServiceManager.defaultServiceManager().defaultServiceConfiguration.credentialsProvider as! AWSCognitoCredentialsProvider
    
    var users = [User]()
    
    var refresher: UIRefreshControl!
    
    func refresh() {
        let identityId = credentialsProvider.identityId! as String
        
        let mapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        let scan = AWSDynamoDBScanExpression()
        
        mapper.scan(User.self, expression: scan).continueWithBlock { (dynamoTask:AWSTask) -> AnyObject? in
            if (dynamoTask.error != nil) {
                print(dynamoTask.error)
            }
            
            if (dynamoTask.exception != nil) {
                print(dynamoTask.exception)
            }
            
            if (dynamoTask.result != nil) {
                self.users.removeAll(keepCapacity: true)
                
                let dynamoResults = dynamoTask.result as! AWSDynamoDBPaginatedOutput
                
                for user in dynamoResults.items as! [User] {
                    
                    if user.id != identityId {
                        self.users.append(user)
                    }
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
                self.refresher.endRefreshing()
            })
            
            return nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "User List"
        
        refresher = UIRefreshControl()
        
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        
        refresher.addTarget(self, action: #selector(UserViewController.refresh), forControlEvents: UIControlEvents.ValueChanged)
        
        self.tableView.addSubview(refresher)
        
        refresh()
        
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        
        cell.textLabel?.text = users[indexPath.row].name
        
        return cell
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return users.count
    }
}
