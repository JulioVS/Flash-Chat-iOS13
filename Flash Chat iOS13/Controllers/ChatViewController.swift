//
//  ChatViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit

//  Add Firebase libraries
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

class ChatViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextfield: UITextField!
    
    // My Firestore Database
    let db = Firestore.firestore()
    
    var messages: [Message] = [
        
        Message(sender: "mymail@mydom.com", body: "My first message"),
        Message(sender: "mymail@mydom.com", body: "My second message"),
        Message(sender: "mymail@mydom.com", body: "My very long multi-line third message in order to test the wrapping function of the label UI element")
        
    ]
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        title = K.appName
        navigationItem.hidesBackButton = true
        
        tableView.dataSource = self
        tableView.register(UINib(nibName: K.cellNibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier)
        
        loadMessages()
        
    }
    
    func loadMessages() {
        
        db.collection(K.FStore.collectionName)
            .order(by: K.FStore.dateField)
            .addSnapshotListener { (querySnapshot, error) in

            self.messages = []
            
            if let e = error {
                
                print("There was an issue retrieving data from Firestore: \(e)")
                
            }
            else {
            
                if let snapshotDocuments = querySnapshot?.documents {
                    
                    for doc in snapshotDocuments {
                                                
                        let data = doc.data()
                        print(data)
                        
                        if let messageSender = data[K.FStore.senderField] as? String, let messageBody = data[K.FStore.bodyField] as? String {
                            
                            let newMessage = Message(sender: messageSender, body: messageBody)
                            self.messages.append(newMessage)
                            
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                            
                        }
                        
                    }
                    
                }
                
            }
            
        }
    }
    
    @IBAction func sendPressed(_ sender: UIButton) {
        
        if let messageSender = Auth.auth().currentUser?.email, let messageBody = messageTextfield.text {
            
            if messageBody == "" {
                return
            }

            print(messageSender)
            print(messageBody)

            db.collection(K.FStore.collectionName).addDocument(data: [
                
                K.FStore.senderField: messageSender,
                K.FStore.bodyField: messageBody,
                K.FStore.dateField: Date().timeIntervalSince1970
                
            ]) { error in
                
                if let e = error {
                    
                    print("There was an issue saving data to Firestore: \(e)")
                    
                }
                else {
                    
                    print("Successfully saved data!")
                    
                }
                
            }
            
        }
        
    }
    
    @IBAction func logOutPressed(_ sender: UIBarButtonItem) {
        
        do {
            
            try Auth.auth().signOut()
            print("Successful Logout")
            
            navigationController?.popToRootViewController(animated: true)
            
        }
        catch let signOutError as NSError {
            
            print("Error signing out: %@", signOutError)
            
        }
        
    }
    
}

extension ChatViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return messages.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! MessageCell
        cell.label.text = messages[indexPath.row].body
        
        return cell
        
    }
    
}
