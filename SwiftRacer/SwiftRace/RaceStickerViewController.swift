//
//  RaceStickerViewController.swift
//  SwiftRacer
//
//  Created by Mihaela Miches on 11/5/16.
//  Copyright © 2016 me. All rights reserved.
//

import UIKit
import Messages

protocol RaceStickerViewControllerDelegate {
    func didPressJoin(race: Race)
}

class RaceStickerViewController: UIViewController {
    static let storyboardId = "RaceStickerViewController"
    
    var race: Race?
    var canJoin: Bool = false
    var delegate: RaceStickerViewControllerDelegate?
    
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var stickerView: MSStickerView!
    
    @IBAction func didPressJoinButton(_ sender: UIButton) {
        guard let race = race else { fatalError("no race") }
        delegate?.didPressJoin(race: race)
    }
    
    override func viewDidLoad() {
        guard let race = race else { fatalError("no race") }
        super.viewDidLoad()
        
        joinButton.isHidden = !canJoin
        RaceStickerCache.cache.sticker(for: race) { sticker in
            OperationQueue.main.addOperation {
                guard self.isViewLoaded else { return }
                
                self.stickerView.sticker = sticker
            }
        }
    }
}
