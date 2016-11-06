//
//  ViewController.swift
//  SwiftRacer
//
//  Created by Mihaela Miches on 11/4/16.
//  Copyright © 2016 me. All rights reserved.
//

import UIKit
import HealthKit

class ViewController: UIViewController {
    let shareTypes: [HKSampleType] = [HKQuantityType.quantityType(forIdentifier: .distanceCycling)!,
                                      HKQuantityType.quantityType(forIdentifier: .distanceSwimming)!,
                                      HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!,
                                      HKQuantityType.quantityType(forIdentifier: .distanceWheelchair)!]
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        HKHealthStore().requestAuthorization(toShare: nil, read: Set(shareTypes)) { (success, error) -> Void in
        }
    }
}
