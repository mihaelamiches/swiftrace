//
//  RaceStickerCache.swift
//  SwiftRacer
//
//  Created by Mihaela Miches on 11/5/16.
//  Copyright © 2016 me. All rights reserved.
//

import UIKit
import Messages

class RaceStickerCache {
    
    static let cache = RaceStickerCache()
    
    private let cacheURL: URL
    
    private let queue = OperationQueue()
    

    private init() {
        let fileManager = FileManager.default
        let tempPath = NSTemporaryDirectory()
        let directoryName = UUID().uuidString
        
        do {
            cacheURL = URL(fileURLWithPath: tempPath).appendingPathComponent(directoryName)
            try fileManager.createDirectory(at: cacheURL, withIntermediateDirectories: true, attributes: nil)
        }
        catch {
            fatalError("Unable to create cache URL: \(error)")
        }
    }
    
    deinit {
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(at: cacheURL)
        }
        catch {
            print("Unable to remove cache directory: \(error)")
        }
    }
    
    func sticker(for race: Race, completion: @escaping (_ sticker: MSSticker) -> Void) {
        let fileName = UUID().uuidString + ".png"
        let url = cacheURL.appendingPathComponent(fileName)
        
        let operation = BlockOperation {
            let fileManager = FileManager.default
            guard !fileManager.fileExists(atPath: url.absoluteString) else { return }
            
            guard let image = race.renderSticker(opaque: false), let imageData = UIImagePNGRepresentation(image) else { fatalError("Unable to build image for race") }
            
            do {
                try imageData.write(to: url, options: [.atomicWrite])
            } catch {
                fatalError("Failed to write sticker image to cache: \(error)")
            }
        }
        
        operation.completionBlock = {
            do {
                let sticker = try MSSticker(contentsOfFileURL: url, localizedDescription: "🏎")
                completion(sticker)
            } catch {
                print("Failed to write image to cache, error: \(error)")
            }
        }
        
        queue.addOperation(operation)
    }
}
