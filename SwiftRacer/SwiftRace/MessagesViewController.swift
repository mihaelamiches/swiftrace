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
            self.startRace(with: raceData)
            self.requestPresentationStyle(.compact)
        }
    }
    
    func startRace(with raceData: RaceData) {
        guard let conversation = activeConversation else { fatalError("Expected a conversation") }
        let race = Race(participants: [conversation.localParticipantIdentifier.uuidString : raceData])
        let message = composeMessage(with: race, caption: "$\(conversation.localParticipantIdentifier) takes the lead with \(raceData.totalDistance)", session: conversation.selectedMessage?.session)
        conversation.insert(message) { error in
            guard error == nil else {
                return print(error!)
            }
        }
    }
    
    func join(_ race: Race, with raceData: RaceData) {
        guard let conversation = activeConversation else { fatalError("Expected a conversation") }
        
        var participants = race.participants
        participants[conversation.localParticipantIdentifier.uuidString ] = raceData
        
        let message = composeMessage(with: Race(participants: participants), caption: "$\(conversation.localParticipantIdentifier) takes the lead with \(raceData.totalDistance)", session: conversation.selectedMessage?.session)
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
        layout.image = race.renderSticker(opaque: false)
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
        if let message = conversation.selectedMessage, let race = Race(message: message) {
            let canJoin = (race.participants.filter { $0.key == conversation.localParticipantIdentifier.uuidString }.count == 0)
            self.embedStickerViewController(withRace: race, canJoin: canJoin)
        }
    }
    
    func embedStickerViewController(withRace race: Race, canJoin: Bool) {
        guard let controller = storyboard?.instantiateViewController(withIdentifier: RaceStickerViewController.storyboardId) as? RaceStickerViewController else { fatalError("Unable to instantiate a RaceStickerViewController from the storyboard") }

        controller.race = race
        controller.canJoin = canJoin
        controller.delegate = self
        
        removeChildViewControllers()
        
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
    
    func removeChildViewControllers() {
        for child in childViewControllers {
            child.willMove(toParentViewController: nil)
            child.view.removeFromSuperview()
            child.removeFromParentViewController()
        }
    }
}

extension MessagesViewController: RaceStickerViewControllerDelegate {
    func didPressJoin(race: Race) {
        queryLocalRaceData { raceData in
            self.join(race, with: raceData)
            self.removeChildViewControllers()
            self.requestPresentationStyle(.compact)
        }
    }
}
