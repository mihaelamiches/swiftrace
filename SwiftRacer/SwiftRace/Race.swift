//
//  Race.swift
//  SwiftRacer
//
//  Created by Mihaela Miches on 11/4/16.
//  Copyright © 2016 me. All rights reserved.
//

import Messages

struct RaceData {
    let totalDistance: Double
    let turboValue: Double?
    
    func stickerImage(percentCompleted: CGFloat) -> UIImage? {
        let raceProgressView = RaceProgressView(frame: CGRect(origin: .zero, size: CGSize(width: 300, height: 35)))
        raceProgressView.percentCompleted = percentCompleted.isNaN ? 0 : percentCompleted
        return UIImage(view: raceProgressView)
    }
}

struct Race {
    let participants: [String: RaceData]
}

extension Race {
    var queryItems: [URLQueryItem] {
        var items = [URLQueryItem]()
        
        items.append(URLQueryItem(name: "count", value: "\(participants.count)"))
        var racerIndex = 0
        participants.forEach { racer in
            items.append(URLQueryItem(name: "racer_\(racerIndex)", value: racer.key))
            items.append(URLQueryItem(name: "distance_\(racerIndex)", value: String(racer.value.totalDistance)))
            items.append(URLQueryItem(name: "turbo_\(racerIndex)", value: String(describing: racer.value.turboValue)))
            
            racerIndex += 1
        }
        
        return items
    }
    
    init?(queryItems: [URLQueryItem]) {
        guard let count = queryItems.filter({$0.name == "count"}).first?.value, let participantCount = Int(count)
            else { return nil }
        
        var participants: [String: RaceData] = [:]
        
        for racerIndex in 0..<participantCount {
            var participant: String?
            var distance: Double?
            var turbo: Double?
            
            if let value = queryItems.filter({$0.name == "racer_\(racerIndex)" }).first?.value {
                participant = value
            }
            
            if let value = queryItems.filter({$0.name == "distance_\(racerIndex)" }).first?.value {
                distance = Double(value)
            }
            
            if let value = queryItems.filter({$0.name == "turbo_\(racerIndex)" }).first?.value {
                turbo = Double(value)
            }
            
            if let participant = participant, let distance = distance {
                participants[participant] = RaceData(totalDistance: distance, turboValue: turbo)
            }
        }
        
        self.participants = participants
    }
}

extension Race {
    init?(message: MSMessage?) {
        guard let messageURL = message?.url else { return nil }
        guard let urlComponents = NSURLComponents(url: messageURL, resolvingAgainstBaseURL: false), let queryItems = urlComponents.queryItems else { return nil }
        
        self.init(queryItems: queryItems)
    }
}
