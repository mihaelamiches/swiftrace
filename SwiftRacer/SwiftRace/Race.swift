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
    
    func stickerImage() -> UIImage? {
        return nil
    }
}

struct Race {
    let participants: [String: RaceData]
}

extension Race {
    var queryItems: [URLQueryItem] {
        var items = [URLQueryItem]()
        
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
        var participants: [String: RaceData] = [:]

        var racerIndex = 0
        for queryItem in queryItems {
            var participant: String?
            var distance: Double?
            var turbo: Double?
            
            switch queryItem.name {
            case "racer_\(racerIndex)":
                participant = queryItem.value
            case "distance_\(racerIndex)":
                distance = Double(queryItem.value ?? "")
            case "turbo_\(racerIndex)":
                turbo = Double(queryItem.value ?? "")
            default:
                break
            }
            
            if let participant = participant, let distance = distance {
                participants[participant] = RaceData(totalDistance: distance, turboValue: turbo)
            }
            
            racerIndex += 1
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
