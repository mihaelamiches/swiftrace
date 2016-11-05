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
}


//
//extension Race {
//    init?(message: MSMessage?) {
//        guard let messageURL = message?.url else { return nil }
//        guard let urlComponents = NSURLComponents(url: messageURL, resolvingAgainstBaseURL: false), let queryItems = urlComponents.queryItems else { return nil }
//        
//        self.init(queryItems: queryItems)
//    }
//}
