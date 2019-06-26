//
//  AudioPlayer.swift
//  coloringbook
//
//  Created by Iulian Dima on 12/3/16.
//  Copyright © 2016 Tapptil. All rights reserved.
//

import UIKit
import AVFoundation

// An array of all players stored in the pool; not accessible
// outside this file
private var players : [AVAudioPlayer] = []

class AudioPlayer: NSObject {
    
    // Given the URL of a sound file, either create or reuse an audio player
    class func playerWithURL(_ url : URL) -> AVAudioPlayer? {
        
        // Try to find a player that can be reused and is not playing
        let availablePlayers = players.filter { (player) -> Bool in
            return player.isPlaying == false && player.url == url
        }
        
        // If we found one, return it
        if let playerToUse = availablePlayers.first {
            //print("Reusing player for \(url.lastPathComponent)")
            return playerToUse
        }
        
        // Didn't find one? Create a new one
        
        do {
            let newPlayer = try AVAudioPlayer(contentsOf: url)
            newPlayer.prepareToPlay()
            players.append(newPlayer)
            
            return newPlayer
        }
        catch{
            print(error)
            return nil
        }
    }
    
}
