//
//  ViewController.swift
//  InstgramJoseph
//
//  Created by ZD on 2016/8/3.
//  Copyright © 2016年 ZD. All rights reserved.
//

import UIKit
import GoogleSignIn

class ViewController: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate, AWSIdentityProviderManager {

    var googleIdToken = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().shouldFetchBasicProfile = true
    }


    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser, withError error: NSError!) {
        if (error == nil) {
            googleIdToken = user.authentication.idToken
            
            signInToCognito(user)
        } else {
            print("\(error.localizedDescription)")
        }
    }
    
    func signInToCognito(user: GIDGoogleUser) {
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType: .USWest2, identityPoolId: "us-west-2:2e36895d-7aab-4355-810d-e5eb08b37965", identityProviderManager: self)
        
        let configuration = AWSServiceConfiguration(region: .USWest2, credentialsProvider: credentialsProvider)
        
        AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = configuration
        
        credentialsProvider.getIdentityId().continueWithBlock { (task:AWSTask) -> AnyObject? in
            if(task.error != nil) {
                print(task.error)
                return nil
            }
            
            let syncClient = AWSCognito.defaultCognito()
            let dataset = syncClient.openOrCreateDataset("instagramDataSet2")
            
            
//            if dataset.getAllRecords().count < 2 {return nil}
            
            dataset.setString(user.profile.email, forKey: "email")
            dataset.setString(user.profile.name, forKey: "name")
            dataset.setString(dataset.lastSyncCount.stringValue, forKey:"lastSyncCount")
            
            
            
            let result = dataset.synchronize()
            
            result.continueWithBlock({ (task:AWSTask) -> AnyObject? in
                if task.error != nil {
                    print(task.error)
                } else {
                    print(task.result)
                    dispatch_async(dispatch_get_main_queue(), {
                        self.performSegueWithIdentifier("login", sender: nil)
                    })
                }
                return nil
            })
            
            return nil
        }
    }
    
    func logins() -> AWSTask {
        let result = NSDictionary(dictionary: [AWSIdentityProviderGoogle: googleIdToken])
        return AWSTask(result: result)
    }
    
}

