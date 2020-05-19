//
//  GPVideoClipperController.swift
//  GPVideoClipperDemo-Swift
//
//  Created by Roc Kwok on 2020/5/19.
//  Copyright © 2020 Roc Kwok. All rights reserved.
//

import UIKit
import AVKit
import Photos

public typealias ClipperCallback = (_ videoURL: URL, _ videoAsset: PHAsset, _ coverImage: UIImage) -> Void;

open class GPVideoClipperController: UIViewController, GPVideoPlayerViewDelegate, GPVideoClipperViewDelegate {
    
    let kClipViewHeight = 135
    let kCutVideoPath = "cutDoneVideo.mp4"
    var videoURL: URL!
    var timeObserver: Any!
    var outputURL: URL!
    var coverImage: UIImage!
    var callback: ClipperCallback?
    
    lazy var maker: GPVideoConfigMaker = {
        var maker = GPVideoConfigMaker.init()
        maker.startTime = 0
        maker.endTime = 15
        maker.clippedVideoMinDuration = 3
        maker.clippedVideoMaxDuration = 15
        maker.sourceVideoTotalDuration = CGFloat(CMTimeGetSeconds(AVURLAsset.init(url: self.videoURL).duration))

        return maker
    }()
    
    lazy var playerView: GPVideoPlayerView = {
        let x = 30
        let y = self.gp_statusBarHeight() + 44
        let width = self.view.frame.size.width - 60
        let bottomMargin = self.gp_safeAreaBottomHeight() + 25
        let height = self.view.frame.size.height - y - bottomMargin - CGFloat(kClipViewHeight)
        let playerView = GPVideoPlayerView.init(frame: CGRect.init(x: CGFloat(x), y: y, width: width, height: height), videoURL: self.videoURL)
        playerView.delegate = self
        playerView.maker = self.maker
        return playerView
    }()
    
    lazy var clipperView: GPVideoClipperView = {
        let x = CGFloat(0)
        let y = self.view.bounds.size.height - self.gp_safeAreaBottomHeight() - CGFloat(kClipViewHeight) - 25
        let width = self.view.bounds.size.width
        let height = CGFloat(kClipViewHeight)
 
        var clipperView = GPVideoClipperView.init(frame: CGRect.init(x: x, y: y, width: width, height: height), maker: self.maker)
        clipperView.delegate = self
        clipperView.avAsset = AVAsset.init(url: self.videoURL)
        return clipperView
    }()
    
    
    //MARK: - Life cycle
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.playerView)
        self.view.addSubview(self.clipperView)
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    deinit {
          if self.timeObserver != nil {
            self.playerView.player.removeTimeObserver(self.timeObserver as Any)
            self.timeObserver = nil
          }
    }
    
    //MARK: - Public
    static public func clipperWithVideoURL(_ videoURL: URL, makerBlock:@escaping(GPVideoConfigMaker)->Void, callback: @escaping ClipperCallback) -> GPVideoClipperController {
        let maker = GPVideoConfigMaker.init()
        makerBlock(maker)
        maker.sourceVideoTotalDuration = CGFloat(CMTimeGetSeconds(AVURLAsset.init(url: videoURL).duration))
        let controller = GPVideoClipperController.init()
        controller.videoURL = videoURL
        controller.maker = maker
        controller.callback = callback
        return controller
    }
    
    //MARK: - Private
    
    func gp_back() {
        let array: NSArray = NSArray.init(array: self.navigationController!.viewControllers)
        if (self.navigationController != nil) && array.index(of: self) != 0 {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func gp_playVideo() {
        self.playerView.player.seek(to: CMTime.init(value: CMTimeValue(self.maker.startTime * 1000), timescale: 1000), toleranceBefore: .zero, toleranceAfter: .zero)
        self.playerView.player.play()
        if self.timeObserver != nil {
            self.playerView.player.removeTimeObserver(self.timeObserver as Any)
            self.timeObserver = nil
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.timeObserver = self.playerView.player.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 10), queue: .main, using: { [weak self](time) in
                let delta = CMTimeGetSeconds(time)
                let temp = CGFloat((self!.maker.endTime)) - CGFloat((self!.maker.startTime))
                self!.clipperView.gp_updateProgressViewWithProgress((CGFloat(delta) - self!.maker.startTime) / CGFloat(temp))
            })
        }
    }
    
    func gp_safeAreaBottomHeight() -> CGFloat {
        var bottom: CGFloat!
        if #available(iOS 11.0, *) {
            bottom = (UIApplication.shared.windows.first?.safeAreaInsets.bottom)!
        }
        if bottom <= 0 && self.gp_isIphoneXSeries() {
            bottom = 34
        }
        return bottom
    }
    
    func gp_statusBarHeight() -> CGFloat {
        var statusBarHeight: CGFloat
        if #available(iOS 13.0, *) {
            statusBarHeight = (UIApplication.shared.windows.first?.windowScene?.statusBarManager?.statusBarFrame.size.height)!
        } else {
            statusBarHeight = UIApplication.shared.statusBarFrame.size.height
        }
        return statusBarHeight
    }
    
    func gp_isIphoneXSeries() -> Bool {
        return self.gp_statusBarHeight() == 40 ? true : false
    }
    
    func gp_saveVideo() {
        if self.videoURL.absoluteString.count > 0 && self.maker.startTime >= 0 && self.maker.endTime > self.maker.startTime {
            self.gp_clippVideoWithCompletion {
                self.gp_saveVideoToAlbumWithVideoURL(URL: self.outputURL, success: { (asset) in
                    PHImageManager.default().requestAVAsset(forVideo: asset!, options: nil) { (avAsset, audioMix, info) in
                        let urlAsset:AVURLAsset = avAsset as! AVURLAsset
                        let url = urlAsset.url
                        DispatchQueue.main.async {
                            print(url, asset as Any, self.coverImage as Any)
                            self.gp_back()
                            if self.callback != nil {
                                self.callback!(url, asset!, self.coverImage!)
                            }
                        }
                    }
                }) { (message) in
                    print(String.init(format: "Save failed:%@", message!))
                }
            }
        }
    }
    
    func gp_clippVideoWithCompletion(completionHandle: @escaping() -> Void) {
        let asset = AVURLAsset.init(url: self.videoURL)
        let exportSession = AVAssetExportSession.init(asset: asset, presetName: AVAssetExportPresetPassthrough)
        let outputPath = NSString.init(string: NSTemporaryDirectory()).appendingPathComponent(kCutVideoPath)
        self.outputURL = URL.init(fileURLWithPath: outputPath)
        if FileManager.default.fileExists(atPath: outputPath) {
            do {
                try FileManager.default.removeItem(atPath: outputPath)
            } catch {}
        }
        exportSession!.outputFileType = .mp4
        exportSession!.outputURL = self.outputURL as URL?
        exportSession!.shouldOptimizeForNetworkUse = true
        
        let start = CMTimeMakeWithSeconds(Float64(maker.startTime), preferredTimescale: asset.duration.timescale)
        let duration = CMTimeMakeWithSeconds(Float64(maker.endTime - maker.startTime), preferredTimescale: asset.duration.timescale)
        let range = CMTimeRangeMake(start: start, duration: duration)
        exportSession?.timeRange = range
        
        exportSession?.exportAsynchronously(completionHandler: {
            completionHandle()
        })
    }
    
    func gp_saveVideoToAlbumWithVideoURL(URL: URL, success completionHandler: @escaping(PHAsset?) -> Void, failure:@escaping(String?)->Void) {
        var _targetCollection: PHAssetCollection? = nil
        var _asset: PHAsset? = nil
        var _assetIdentifier: String? = nil
        var _collectionIdentifier: String? = nil

        let collectionTitle = Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String
        let results:PHFetchResult<PHAssetCollection> = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: nil)
        
        results.enumerateObjects { (collection, index, protocol) in
            if collection.localizedTitle == collectionTitle {
                _targetCollection = collection
            }
        }
        
        PHPhotoLibrary.shared().performChanges({
            _assetIdentifier = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL)?.placeholderForCreatedAsset?.localIdentifier
        }) { (success, error) in
            if success {
                PHPhotoLibrary.shared().performChanges({
                    if _targetCollection == nil {
                        _collectionIdentifier = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: collectionTitle!).placeholderForCreatedAssetCollection.localIdentifier
                    }
                    
                }) { (success1, error1) in
                    if success1 {
                        PHPhotoLibrary.shared().performChanges({
                            if _targetCollection == nil {
                                _targetCollection = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [_collectionIdentifier!], options: nil).lastObject
                             }
                             _asset = PHAsset.fetchAssets(withLocalIdentifiers: [_assetIdentifier!], options: nil).lastObject
                             let requestCollection = PHAssetCollectionChangeRequest.init(for: _targetCollection!)
                             let enumeration: NSArray = [_asset!]
                             requestCollection?.addAssets(enumeration)
                            
                        }) { (success2, error2) in
                            if success2 {
                                self.coverImage = self.gp_getVideoPreViewImage(path: self.outputURL)
                                completionHandler(_asset)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func gp_getVideoPreViewImage(path: URL) -> UIImage {
        var videoImage:UIImage!
        let asset = AVURLAsset.init(url: path, options: nil)
        let assetGen = AVAssetImageGenerator.init(asset: asset)
        assetGen.appliesPreferredTrackTransform = true
        let time = CMTimeMakeWithSeconds(0.0, preferredTimescale: 600)
        let pointer = UnsafeMutablePointer<CMTime>.allocate(capacity: 1);
        do {
            let image = try assetGen.copyCGImage(at: time, actualTime: pointer)
            videoImage = UIImage.init(cgImage: image)
            return videoImage
        } catch {}
        return videoImage
    }
    
    //MARK: - <GPVideoPlayerViewDelegate>
    
    func gp_videoReadyToPlay() {
        self.playerView.playerItem.forwardPlaybackEndTime = CMTime.init(value: (CMTimeValue(self.maker.endTime * 1000)), timescale: 1000)
        self.gp_playVideo()
    }
    
    //MARK: - <GPVideoClipperViewDelegate>
    
    func gp_cancelButtonAction(button: UIButton) {
        self.gp_back()
    }
    
    func gp_doneButtonAction(button: UIButton) {
        self.gp_saveVideo()
    }
    
    func gp_videoLengthDidChanged(time: CGFloat) {
        guard time < 0 else {
            if self.playerView.playerItem.status == .readyToPlay {
                self.playerView.player.seek(to: CMTime.init(value: CMTimeValue(time * 1000), timescale: 1000), toleranceBefore: .zero, toleranceAfter: .zero)
                self.playerView.player.pause()
            }
            return
        }
    }
    
    func gp_didEndDragging() {
        self.playerView.playerItem.forwardPlaybackEndTime =  CMTime.init(value: (CMTimeValue(self.maker.endTime * 1000)), timescale: 1000)
        self.gp_playVideo()
    }
}
