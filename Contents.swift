import Cocoa
import AVFoundation
import AVKit
import PlaygroundSupport
import Foundation

let rect = CGRect(x: 0, y: 0, width: 300, height: 500)

//: This is where we select the audio files that will be processed

let username = NSUserName()
let basePath = "/Users/\(username)/Library/Mobile Documents/iCloud~is~workflow~my~workflows/Documents/"
var times = ["Sat2100",
                 "Sat2130",
                 "Sat2200",
                 "Sat2230",
                 "Sat2300",
                 "Sat2330",
                 "Sun0000"]


var paths = times
    .map{basePath + $0}
    // I comment or uncomment this line depending on if I'm trying to combine this week's or last week's show
    .map{$0 + "_old"}
    .map{$0 + ".mp3"}

let assets = paths.map{ path in AVURLAsset(url: URL(fileURLWithPath: path))}

let composition = AVMutableComposition()

//Make aure they're all audio files
debugPrint("asserting")
assets.forEach{asset in assert(asset.tracks[0].mediaType == .audio)}

// Prints total amount of time of combined files
let t = assets.reduce(CMTime.zero, {time, asset in
    do {
        try composition.insertTimeRange(CMTimeRangeMake(start: .zero, duration: asset.duration), of: asset, at: time)
    } catch {
        return time
    }
    return time + asset.duration
})

debugPrint(t.seconds)


//AVAssetExportSession.exportPresets(compatibleWith: assets[0])

//Export to .m4a audio file
let exporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetAppleM4A)

exporter?.outputURL = URL(fileURLWithPath: "/Users/\(username)/Desktop/out.m4a")
exporter?.outputFileType = AVFileType.m4a

// Runs exporter
exporter?.exportAsynchronously {
    DispatchQueue.main.async {
        let outputURL = exporter?.outputURL
//        let output = AVAsset(url: outputURL!)
        let player = AVPlayer(playerItem: AVPlayerItem(url: outputURL!))
//        player.play()
        debugPrint(player.currentItem?.asset.duration)
        let playerView = AVPlayerView(frame: rect)
        playerView.player = player
        PlaygroundPage.current.liveView = playerView
    }
}

/* If you want to play the file right after downloading */

//let playerItem = AVPlayerItem(asset: assets[2])
//let player = AVPlayer(playerItem: playerItem)
////player.play()
