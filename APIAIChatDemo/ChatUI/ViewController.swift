//
//  ViewController.swift
//  ChatUI
//
//  Created by Solution Analysts. Pvt. Ltd.
//

import UIKit
import ApiAI
import AVFoundation
import JSQMessagesViewController

struct User {
    let id: String
    let name: String
}

class ViewController: JSQMessagesViewController {
    let user1 = User(id: "1", name: "Steve") // current user
    let botName = "SA Bot"
    let botUserId = "2"
    //    let user2 = User(id: "2", name: "Tim")
    
    let speechSynthesizer = AVSpeechSynthesizer() // for speak
    
    
    var currentUser: User {
        return user1
    }
    
    // all messages of users1, users2
    var messages = [JSQMessage]() //
}

extension ViewController {
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
        // call when user press send button
        let message = JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text)
        messages.append(message!)
        // call APIAi for answer
        callAPIAi(messageText: text)
        finishSendingMessage()
    }
    
    func callAPIAi(messageText: String) {
        let request = ApiAI.shared().textRequest()
        if messageText.characters.count != 0 {
            request?.query = messageText
        } else {
            return
        }
        
        request?.setMappedCompletionBlockSuccess({ (request, response) in
            let response = response as! AIResponse
            
            if let parameter = response.result.fulfillment {
                let message = JSQMessage(senderId: self.botUserId, displayName: self.botName, text: parameter.speech)
                self.messages.append(message!)
                self.finishSendingMessage()
            }
            
            if let textResponse = response.result.fulfillment.speech {
                self.speak(text: textResponse)
            }
            
        }, failure: { (request, error) in
            print("Something went wrong",error as Any)
        })
        ApiAI.shared().enqueue(request)
    }
    
    //Device speak
    func speak(text: String) {
        let speechUtterance = AVSpeechUtterance(string: text)
        speechSynthesizer.speak(speechUtterance)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        let message = messages[indexPath.row]
        let messageUsername = message.senderDisplayName
        
        return NSAttributedString(string: messageUsername!)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
        return 15
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        
        let message = messages[indexPath.row]
        
        // according to user id set MessagesBubbleImage color
        if currentUser.id == message.senderId {
            return bubbleFactory?.outgoingMessagesBubbleImage(with: .green)
        } else {
            return bubbleFactory?.incomingMessagesBubbleImage(with: .blue)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.row]
    }
}

extension ViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.inputToolbar.contentView.leftBarButtonItem = nil
        // tell JSQMessagesViewController
        // who is the current user
        self.senderId = currentUser.id
        self.senderDisplayName = currentUser.name
    }
}
