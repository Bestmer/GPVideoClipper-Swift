//
//  GPVideoClipperView.swift
//  GPVideoClipperDemo-Swift
//
//  Created by Roc Kwok on 2020/5/19.
//  Copyright © 2020 Roc Kwok. All rights reserved.
//

import UIKit
import AVKit

@objc protocol GPVideoClipperViewDelegate: NSObjectProtocol {
    @objc func gp_cancelButtonAction(button: UIButton)
    @objc func gp_doneButtonAction(button: UIButton)
    @objc func gp_videoLengthDidChanged(time: CGFloat)
    @objc func gp_didEndDragging()
}

open class GPVideoClipperView: UIView, UICollectionViewDelegate, UICollectionViewDataSource {

    // Const
    let kDurationLabelWidth = 70
    let kButtonWidth: CGFloat = 60.0
    let kButtonHeight: CGFloat = 30.0
    let kLineHeight: CGFloat = 3.0
    
    // Public
    public weak var delegate:GPVideoClipperViewDelegate?
    public var avAsset: AVAsset! {
          willSet {
            self.avAsset = newValue
            self.p_loadThumbnailImages()
          }
    }
    public var progressTime: CGFloat! {
        return (self.progressView.frame.minX - self.leftImageView.frame.maxX) / self.perSecondWidth
    }
    public var maker: GPVideoConfigMaker!

	// Private
    private var selectedTime: CGFloat!
    private var cellWidth: CGFloat!
    private var cellCount: UInt!
    private var perSecondWidth: CGFloat!
    private var collectionInsets: UIEdgeInsets!
    private var imageArray:[UIImage] = []
    private var preOriginX: CGFloat!
    private var selectedImageView: UIImageView!
    
    private lazy var collectionView: UICollectionView = {
        var layout = UICollectionViewFlowLayout.init()
        layout.itemSize = CGSize.init(width: self.cellWidth, height: 60)
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
        
        var collectionView = UICollectionView.init(frame:.zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceHorizontal = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.clipsToBounds = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = self.collectionInsets;
        collectionView.register(GPVideoClipperImageCell.self, forCellWithReuseIdentifier: NSStringFromClass(GPVideoClipperImageCell.self))
        return collectionView
    }()
    
    private lazy var imageGenerator: AVAssetImageGenerator = {
        var imageGenerator = AVAssetImageGenerator.init(asset: self.avAsset)
        imageGenerator.appliesPreferredTrackTransform = true;
        imageGenerator.requestedTimeToleranceBefore = .zero;
        imageGenerator.requestedTimeToleranceAfter = .zero;
        imageGenerator.maximumSize = CGSize.init(width: 320, height: 320)
        return imageGenerator
    }()
    
    private lazy var durationLabel: UILabel = {
        var durationLabel = UILabel.init()
        durationLabel.font = UIFont.boldSystemFont(ofSize: 12)
        durationLabel.backgroundColor = .black
        durationLabel.textColor = .white
        durationLabel.textAlignment = .right
        durationLabel.isHidden = self.maker.isHiddenSelectedTimeTag
        return durationLabel
    }()
    
    private lazy var cancelButton: UIButton = {
        var cancelButton = UIButton.init(type:.custom)
        cancelButton.titleLabel?.font = self.maker.leftButtonFont
        cancelButton.backgroundColor = self.maker.leftButtonBackgroundColor
        cancelButton.setTitle(self.maker.leftButtonTitle, for: .normal)
        cancelButton.setTitleColor(.white, for: .normal)
        cancelButton.addTarget(self, action:#selector(cancelButtonAction(_:)), for: .touchUpInside)
        return cancelButton
    }()
    
    private lazy var doneButton: UIButton = {
        var doneButton = UIButton.init(type:.custom)
        doneButton.titleLabel?.font = self.maker.rightButtonFont
        doneButton.backgroundColor = self.maker.rightButtonBackgroundColor
        doneButton.setTitle(self.maker.rightButtonTitle, for: .normal)
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.layer.cornerRadius = 5.0
        doneButton.clipsToBounds = true
        doneButton.addTarget(self, action: #selector(doneButtonAction(_:)), for: .touchUpInside)
        return doneButton
    }()
    
    private lazy var leftImageView: UIImageView = {
        var leftImageView = UIImageView.init()
        leftImageView.isUserInteractionEnabled = true
        leftImageView.contentMode = .scaleAspectFill
        if ((self.maker?.selectedBoxColor) != nil) {
            leftImageView.backgroundColor = self.maker.selectedBoxColor
        }
        if ((self.maker?.leftSelectedImage) != nil) {
            leftImageView.image = self.maker.leftSelectedImage
        }
        var panGesture = UIPanGestureRecognizer.init(target: self, action: Selector.init(("panGesture:")))
        panGesture.maximumNumberOfTouches = 1
        leftImageView.addGestureRecognizer(panGesture)
        return leftImageView
    }()
    
    private lazy var rightImageView: UIImageView = {
        var rightImageView = UIImageView.init()
        rightImageView.isUserInteractionEnabled = true
        rightImageView.contentMode = .scaleAspectFill
        if ((self.maker?.selectedBoxColor) != nil) {
            rightImageView.backgroundColor = self.maker.selectedBoxColor
        }
        if ((self.maker?.rightSelectedImage) != nil) {
            rightImageView.image = self.maker.rightSelectedImage
        }
        var panGesture = UIPanGestureRecognizer.init(target: self, action: Selector.init(("panGesture:")))
        panGesture.maximumNumberOfTouches = 1
        rightImageView.addGestureRecognizer(panGesture)
        return rightImageView
    }()
    
    private lazy var topLine: UIImageView = {
        var topLine = UIImageView()
        if ((self.maker?.selectedBoxColor) != nil ){
            topLine.backgroundColor = self.maker.selectedBoxColor
        }
        return topLine
    }()
    
    private lazy var bottomLine: UIImageView = {
        var bottomLine = UIImageView()
        if ((self.maker?.selectedBoxColor) != nil ){
            bottomLine.backgroundColor = self.maker.selectedBoxColor
        }
        return bottomLine
    }()
    
    private lazy var progressView: UIButton = {
        var progressView = UIButton.init(type:.custom)
        progressView.isEnabled = true
        progressView.isUserInteractionEnabled = true
        progressView.layer.cornerRadius = 3.0/2.0
        progressView.backgroundColor = UIColor.init(red: 171/255.0, green: 169/255.0, blue: 166/255.0, alpha: 0.7)
        return progressView
    }()
    
    //MARK: - Action
    
    @objc func panGesture(_ gesture: UIPanGestureRecognizer) {
        let point = gesture.translation(in: self.superview)
        switch gesture.state {
        case .began:
            self.preOriginX = 0
            self.selectedImageView = gesture.view as? UIImageView
            break
        case .changed:
            var offsetX = point.x - self.preOriginX
            self.preOriginX = point.x
            if self.selectedImageView == self.leftImageView {
                var frame = self.leftImageView.frame
                frame.origin.x += offsetX
                if frame.origin.x <= self.maker.leftMargin {
                    offsetX += self.maker.leftMargin - frame.origin.x;
                    frame.origin.x = self.maker.leftMargin;
                }
                let minLength = self.rightImageView.frame.origin.x - self.maker.clippedVideoMinDuration * self.perSecondWidth - self.maker.selectedImageWidth
                if (frame.origin.x >= minLength) {
                    offsetX -= frame.origin.x - minLength;
                    frame.origin.x = minLength;
                }
                let time = offsetX / self.perSecondWidth;
                self.maker.startTime = self.maker.startTime + time;
                self.leftImageView.frame = frame;
                if (self.delegate != nil) && (self.delegate?.responds(to: #selector(self.delegate?.gp_videoLengthDidChanged(time:))))! {
                    self.delegate?.gp_videoLengthDidChanged(time: self.maker!.startTime)
                }
            } else if self.selectedImageView == self.rightImageView {
                var frame = self.rightImageView.frame
                frame.origin.x += offsetX
                let rightImageMaxX = self.frame.size.width - self.maker.rightMargin - self.maker.selectedImageWidth
                if (frame.origin.x >= rightImageMaxX) {
                    offsetX -= frame.origin.x - rightImageMaxX;
                    frame.origin.x = rightImageMaxX;
                }
                let rightImageMinX = self.leftImageView.frame.maxX + self.maker.clippedVideoMinDuration * self.perSecondWidth;
                if (frame.origin.x <= rightImageMinX) {
                    offsetX += rightImageMinX - frame.origin.x;
                    frame.origin.x = rightImageMinX;
                }
                let time = offsetX / self.perSecondWidth;
                self.maker.endTime = self.maker.endTime + time;
                self.rightImageView.frame = frame;
                if (self.delegate != nil) && (self.delegate?.responds(to: #selector(self.delegate?.gp_videoLengthDidChanged(time:))))! {
                    self.delegate?.gp_videoLengthDidChanged(time: self.maker!.endTime)
                }
            }
            
            self.progressView.frame = CGRect.init(x: self.leftImageView.frame.maxX, y: self.progressView.frame.origin.y, width: self.progressView.frame.size.width, height: self.progressView.frame.size.height)
            self.selectedTime = self.maker.endTime - self.maker.startTime;
            self.durationLabel.text = String.init(format: "已选取%.0fs", self.selectedTime)
            
            var topLineFrame = self.topLine.frame;
            var bottomLineFrame = self.bottomLine.frame;
            topLineFrame.origin.x = self.leftImageView.frame.maxX
            bottomLineFrame.origin.x = self.leftImageView.frame.maxX
            topLineFrame.size.width = self.rightImageView.frame.minX - self.leftImageView.frame.maxX
            bottomLineFrame.size.width = self.rightImageView.frame.minX - self.leftImageView.frame.maxX
            
            self.topLine.frame = topLineFrame;
            self.bottomLine.frame = bottomLineFrame;
            break
        case .ended:
            self.selectedImageView = nil
            if (self.delegate != nil) && (self.delegate?.responds(to: #selector(self.delegate?.gp_didEndDragging)))! {
                self.delegate?.gp_didEndDragging()
            }
            break
        default:
            break
        }
    }
    
    //MARK: - <UICollectionViewDelegate, UICollectionViewDataSource>
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imageArray.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(GPVideoClipperImageCell.self), for: indexPath) as! GPVideoClipperImageCell
        cell.imageView.image = self.imageArray[indexPath.item]
        return cell
    }
    
    //MARK: - <ScrollViewDelegate>
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let time = (scrollView.contentOffset.x + self.collectionInsets.left) / self.perSecondWidth
        let startTime = time + (self.leftImageView.frame.maxX - self.collectionInsets.left) / self.perSecondWidth
        
        guard startTime < 0 else {
            self.maker.startTime = startTime
            let endTime = self.maker.startTime + self.selectedTime
            self.maker.endTime = endTime > self.maker.sourceVideoTotalDuration ? self.maker.sourceVideoTotalDuration:endTime
            self.maker.startTime = self.maker.endTime - self.selectedTime
            self.gp_updateProgressViewWithProgress(0.0)
            if (self.delegate != nil) && (self.delegate?.responds(to: #selector(self.delegate?.gp_videoLengthDidChanged(time:))))! {
                self.delegate?.gp_videoLengthDidChanged(time: self.maker!.startTime + self.progressTime)
            }
            return
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if (self.delegate != nil) && (self.delegate?.responds(to: #selector(self.delegate?.gp_didEndDragging)))! {
            self.delegate?.gp_didEndDragging()
        }
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
           if (self.delegate != nil) && (self.delegate?.responds(to: #selector(self.delegate?.gp_didEndDragging)))! {
               self.delegate?.gp_didEndDragging()
           }
        }
    }
    
    @objc func cancelButtonAction(_ button: UIButton) {
        if (self.delegate != nil) && (self.delegate?.responds(to: #selector(self.delegate?.gp_cancelButtonAction(button:))))! {
            self.delegate?.gp_cancelButtonAction(button: button)
        }
    }
    
    @objc func doneButtonAction(_ button: UIButton) {
        if (self.delegate != nil) && (self.delegate?.responds(to: #selector(self.delegate?.gp_doneButtonAction(button:))))! {
            self.delegate?.gp_doneButtonAction(button: button)
        }
    }
    
    //MARK: - Init
    
    public init(frame: CGRect, maker: GPVideoConfigMaker) {
        self.maker = maker
        super.init(frame: frame)
        self.isUserInteractionEnabled = true
        self.clipsToBounds = true
        self.backgroundColor = .clear
        
        let length = self.frame.size.width - self.maker.leftMargin - self.maker.rightMargin - self.maker.selectedImageWidth * 2
        self.cellWidth = length / CGFloat(self.maker.defaultSelectedImageCount)
        
        if self.maker.sourceVideoTotalDuration <= self.maker.clippedVideoMaxDuration {
            self.maker.endTime = self.maker.sourceVideoTotalDuration;
            self.cellCount = self.maker.defaultSelectedImageCount
        } else {
            self.maker.endTime = self.maker.clippedVideoMaxDuration;
            let temp = self.maker.endTime / CGFloat(self.maker.defaultSelectedImageCount)
            self.cellCount = UInt(self.maker.sourceVideoTotalDuration / CGFloat(temp))
        }
        
        let value = self.frame.size.width - self.maker.leftMargin - self.maker.rightMargin - self.maker.selectedImageWidth - self.maker.selectedImageWidth
        self.perSecondWidth = value / CGFloat(self.maker.endTime - self.maker.startTime)
        self.collectionInsets = UIEdgeInsets.init(top: 0, left: self.maker.leftMargin + self.maker.selectedImageWidth, bottom: 0, right: self.maker.rightMargin + self.maker.selectedImageWidth)
        self.p_configSubview()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Private
    
    func p_configSubview() {
        self.addSubview(self.collectionView)
        self.collectionView.frame = CGRect.init(x: 0, y: 35, width: self.frame.size.width, height: 60)
        
        self.addSubview(self.durationLabel)
        self.durationLabel.frame = CGRect.init(x: Int(self.frame.size.width - CGFloat(kDurationLabelWidth) - 30), y: 8, width: kDurationLabelWidth, height: 20)
        
        self.addSubview(self.leftImageView)
        self.leftImageView.frame = CGRect.init(x: self.maker.leftMargin, y: self.collectionView.frame.origin.y, width: self.maker.selectedImageWidth, height: self.collectionView.frame.size.height)
        
        self.addSubview(self.rightImageView)
        self.rightImageView.frame = CGRect.init(x: self.frame.size.width - self.maker.selectedImageWidth - self.maker.rightMargin, y: self.collectionView.frame.origin.y, width: self.maker.selectedImageWidth, height: self.collectionView.frame.size.height)
        
        self.addSubview(self.topLine)
        self.topLine.frame = CGRect.init(x: self.maker.leftMargin + self.maker.selectedImageWidth, y: self.collectionView.frame.origin.y, width: self.frame.size.width - self.maker.leftMargin - self.maker.rightMargin - self.maker.selectedImageWidth * 2, height: kLineHeight)
        
        self.addSubview(self.bottomLine)
        self.bottomLine.frame = CGRect.init(x: self.topLine.frame.origin.x, y: self.collectionView.frame.maxY - kLineHeight, width: self.topLine.frame.size.width, height: kLineHeight)
        
        self.addSubview(self.progressView)
        self.progressView.frame = CGRect.init(x: self.leftImageView.frame.maxX, y: self.topLine.frame.maxY, width: 3.0, height: 54.0)
        
        self.addSubview(self.cancelButton)
        self.cancelButton.frame = CGRect.init(x: 30.0, y: self.frame.size.height - kButtonHeight, width: kButtonWidth, height: kButtonHeight)
        
        self.addSubview(self.doneButton)
        self.doneButton.frame = CGRect.init(x: self.frame.size.width - kButtonWidth - 30.0, y: self.frame.size.height - kButtonHeight, width: kButtonWidth, height: kButtonHeight)
    }
    
    func p_loadThumbnailImages () {
        self.selectedTime = self.maker.endTime - self.maker.startTime
        self.durationLabel.text = String.init(format: "已选取%.0fs", self.selectedTime)
        var array: [NSValue] = []
        
        var startTime: CMTime = .zero
        let addTime: CMTime = CMTimeMakeWithSeconds(Float64(self.maker.sourceVideoTotalDuration/CGFloat(self.cellCount)), preferredTimescale: 1000)
        let endTime: CMTime = CMTimeMakeWithSeconds(Float64(self.maker!.sourceVideoTotalDuration), preferredTimescale: 1000)

        while startTime <= endTime {
            array.append(NSValue.init(time: startTime))
            startTime = CMTimeAdd(startTime, addTime)
        }
        weak var weakSelf = self
        var index = 0
        self.imageGenerator.generateCGImagesAsynchronously(forTimes: array) { (requestedTime, image, actualTime, result, error) in
            if result == .succeeded {
                let img = UIImage.init(cgImage: image!)
                DispatchQueue.main.async {
                    self.imageArray.append(img)
                    let indexPath = NSIndexPath.init(item: index, section: 0)
                    weakSelf?.collectionView.insertItems(at: [(indexPath as IndexPath)])
                    index += 1
                }
            }
        }
    }
    
    //MARK: - Public
    
    public func gp_updateProgressViewWithProgress(_ progress: CGFloat) {
        guard self.selectedImageView != nil else {
            let width = self.rightImageView.frame.minX - self.leftImageView.frame.maxX;
            let newX = self.leftImageView.frame.maxX + progress * width;

            UIView.animate(withDuration: 0.1, delay: 0, options:[.curveLinear, .allowUserInteraction], animations: {
                self.progressView.frame = CGRect.init(x: newX, y: self.progressView.frame.origin.y, width: self.progressView.frame.size.width, height: self.progressView.frame.size.height)
            }, completion: nil)
            return
        }
    }
}

class GPVideoClipperImageCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.imageView)
        self.contentView.backgroundColor = .clear
        self.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Getters
    
    public lazy var imageView: UIImageView = {
        var imageView = UIImageView()
        imageView.frame = self.contentView.bounds
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
}
