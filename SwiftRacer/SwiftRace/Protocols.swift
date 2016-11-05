//
//  Protocols.swift
//  SwiftRacer
//
//  Created by Mihaela Miches on 11/5/16.
//  Copyright © 2016 me. All rights reserved.
//

import UIKit

protocol RaceParicipant {
    var rawValue: String { get }
    
    var image: UIImage { get }
    
    var stickerImage: UIImage { get }
}
