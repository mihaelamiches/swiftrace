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
    
    var race: Race?
    
    @IBOutlet weak var stickerView: MSStickerView!
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        guard let race = race else { fatalError("no race") }
        super.viewDidLoad()
        
        // Update the sticker view
        let cache = RaceStickerCache.cache
        
        stickerView.sticker = cache.placeholderSticker
        cache.sticker(for: race) { sticker in
            OperationQueue.main.addOperation {
                guard self.isViewLoaded else { return }
                
                self.stickerView.sticker = sticker
            }
        }
    }
}
