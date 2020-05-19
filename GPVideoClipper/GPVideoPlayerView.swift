//
//  GPVideoPlayerView.swift
//  GPVideoClipperDemo-Swift
//
//  Created by Roc Kwok on 2020/5/19.
//  Copyright © 2020 Roc Kwok. All rights reserved.
//

import UIKit
import AVFoundation

@objc protocol GPVideoPlayerViewDelegate: NSObjectProtocol {
    @objc optional func gp_videoReadyToPlay()
}

open class GPVideoPlayerView: UIView {
    var playerItem: AVPlayerItem!
    var player: AVPlayer!
    var maker: GPVideoConfigMaker!
    weak var delegate:GPVideoPlayerViewDelegate?
    
    private var avPlayer: AVPlayerLayer!
    private var videoURL: URL!
    
    init(frame: CGRect, videoURL: URL) {
        self.videoURL = videoURL
        self.playerItem = AVPlayerItem.init(url: videoURL)
        self.player = AVPlayer.init(playerItem: self.playerItem)
        self.avPlayer = AVPlayerLayer.init(player: self.player)
        self.maker = GPVideoConfigMaker.init()
        
        super.init(frame: frame)
        
        self.layer.addSublayer(self.avPlayer)
        self.avPlayer.frame = self.bounds
        self.playerItem.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(videoDidPlayEnd(notification:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Action
    
    @objc func videoDidPlayEnd(notification: Notification) {
        self.player.pause()
        self.player.seek(to: CMTime.init(value: CMTimeValue(self.maker.startTime * 1000), timescale: 1000), toleranceBefore: .zero, toleranceAfter: .zero)
        self.player.play()
    }
    
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "status" {
            let status = self.playerItem.status
            if status == .readyToPlay {
                if (self.delegate != nil) && self.delegate!.responds(to: Selector.init(("gp_videoReadyToPlay"))) {
                    self.delegate!.gp_videoReadyToPlay?()
                }
                self.playerItem.removeObserver(self, forKeyPath: "status")
            } else {
                assert(false, "Video play failed:\(String(describing: keyPath))")
            }
        }
    }
}
