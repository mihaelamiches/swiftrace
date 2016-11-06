//
//  MessagesViewController.swift
//  SwiftRace
//
//  Created by Mihaela Miches on 11/4/16.
//  Copyright © 2016 me. All rights reserved.
//

import UIKit
import Messages
import HealthKit

class MessagesViewController: MSMessagesAppViewController {
    
    @IBOutlet weak var stickerView: MSStickerView!
    
    @IBAction func didPressChallengeButton(_ sender: UIButton) {
        queryLocalRaceData { raceData in
            self.join(with: raceData)
        }
    }
    
    func join(with raceData: RaceData) {
        guard let conversation = activeConversation else { fatalError("Expected a conversation") }
        let race = Race(participants: [conversation.localParticipantIdentifier.uuidString : raceData])
        let message = composeMessage(with: race, caption: "omg new race", session: conversation.selectedMessage?.session)
        conversation.insert(message) { error in
            guard error == nil else {
                return print(error!)
            }
        }
    }
    
    func composeMessage(with race: Race, caption: String, session: MSSession? = nil) -> MSMessage {
        var components = URLComponents()
        components.queryItems = race.queryItems
        
        let layout = MSMessageTemplateLayout()
        layout.image = race.renderSticker(opaque: true)
        layout.caption = caption
        
        let message = MSMessage(session: session ?? MSSession())
        message.url = components.url!
        message.layout = layout
        
        return message
    }
    
    func queryLocalRaceData(completion: @escaping ((RaceData) -> Void)) {
        var totalDistance = 0.0
        let queryGroup = DispatchGroup()
        
        func query(_ identifier: HKQuantityTypeIdentifier) -> HKStatisticsQuery {
            let startDate = Calendar.current.startOfDay(for: Date())
            let endDate = Date()
            let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: HKQueryOptions.strictStartDate)
            return HKStatisticsQuery(quantityType: HKQuantityType.quantityType(forIdentifier: identifier)!, quantitySamplePredicate: predicate, options: .cumulativeSum, completionHandler: { (_, statistics, error)  in
                defer { queryGroup.leave() }
                guard let statistics = statistics, let sum = statistics.sumQuantity(), error == nil else { return }
                
                totalDistance += sum.doubleValue(for: .meter())
            })
        }
        
        queryGroup.enter()
        HKHealthStore().execute(query(.distanceCycling))
        
        queryGroup.enter()
        HKHealthStore().execute(query(.distanceSwimming))
        
        queryGroup.enter()
        HKHealthStore().execute(query(.distanceWalkingRunning))
        
        queryGroup.enter()
        HKHealthStore().execute(query(.distanceWheelchair))
        
        queryGroup.notify(queue: DispatchQueue.main, execute: {
            let racer = RaceData(totalDistance: totalDistance, turboValue: nil)
            completion(racer)
        })
    }

    // MARK: - Conversation Handling
    
    override func willBecomeActive(with conversation: MSConversation) {
        if let _ = conversation.selectedMessage {
            queryLocalRaceData { race in
                self.embedRaceViewController(for: conversation, withRace: race)
            }
        }
    }
    
    func embedRaceViewController(for conversation: MSConversation?, withRace race: RaceData) {
        guard let controller = storyboard?.instantiateViewController(withIdentifier: RaceViewController.storyboardId) as? RaceViewController else { fatalError("Unable to instantiate a RaceViewController from the storyboard") }
        guard let conversation = activeConversation else { return }

        controller.racers = [conversation.localParticipantIdentifier.uuidString :race]
        for child in childViewControllers {
            child.willMove(toParentViewController: nil)
            child.view.removeFromSuperview()
            child.removeFromParentViewController()
        }
        
        // Embed the new controller.
        addChildViewController(controller)
        
        controller.view.frame = view.bounds
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controller.view)
        
        controller.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        controller.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        controller.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        controller.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        controller.didMove(toParentViewController: self)
    }
    
    override func didResignActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the active to inactive state.
        // This will happen when the user dissmises the extension, changes to a different
        // conversation or quits Messages.
        
        // Use this method to release shared resources, save user data, invalidate timers,
        // and store enough state information to restore your extension to its current state
        // in case it is terminated later.
    }
    
    override func didReceive(_ message: MSMessage, conversation: MSConversation) {
        // Called when a message arrives that was generated by another instance of this
        // extension on a remote device.
        
        // Use this method to trigger UI updates in response to the message.
    }
    
    override func didStartSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user taps the send button.
    }
    
    override func didCancelSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user deletes the message without sending it.
        
        // Use this to clean up state related to the deleted message.
    }
    
    override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Called before the extension transitions to a new presentation style.
        
        // Use this method to prepare for the change in presentation style.
    }
    
    override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Called after the extension transitions to a new presentation style.
        
        // Use this method to finalize any behaviors associated with the change in presentation style.
    }
}
