//
//  RaceTableViewController.swift
//  SwiftRacer
//
//  Created by Mihaela Miches on 11/4/16.
//  Copyright © 2016 me. All rights reserved.
//

import UIKit

class RaceViewController: UICollectionViewController {
    static let storyboardId = "RaceViewController"
    var raceData: RaceData?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        collectionView?.reloadData()
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RacerCollectionViewCell", for: indexPath) as? RacerCollectionViewCell else {
            fatalError("cannot dequeu a RacerCollectionViewCell from the storyboard")
        }
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
}

