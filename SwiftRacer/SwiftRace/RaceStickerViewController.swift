//
//  RaceStickerViewController.swift
//  SwiftRacer
//
//  Created by Mihaela Miches on 11/5/16.
//  Copyright © 2016 me. All rights reserved.
//

import UIKit
import Messages

class RaceStickerViewController: UIViewController {
    static let storyboardId = "RaceStickerViewController"
    
    var raceData: RaceData?
    
    @IBOutlet weak var stickerView: MSStickerView!
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        guard let raceData = raceData else { fatalError("no race") }
        super.viewDidLoad()
        
        // Update the sticker view
        let cache = RaceStickerCache.cache
        
        stickerView.sticker = cache.placeholderSticker
        cache.sticker(for: raceData) { sticker in
            OperationQueue.main.addOperation {
                guard self.isViewLoaded else { return }
                
                self.stickerView.sticker = sticker
            }
        }
    }
}
