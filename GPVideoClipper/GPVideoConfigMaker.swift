//
//  GPVideoConfigMaker.swift
//  GPVideoClipperDemo-Swift
//
//  Created by Roc Kwok on 2020/5/19.
//  Copyright © 2020 Roc Kwok. All rights reserved.
//

import UIKit

open class GPVideoConfigMaker: NSObject {
    // MARK: - Required
    /** 开始时间 */
    public var startTime: CGFloat
    /** 结束时间 */
    public var endTime: CGFloat
    /** 裁剪后视频的最小时长 */
    public var clippedVideoMinDuration: CGFloat
    /** 裁剪后视频的最长时长 */
    public var clippedVideoMaxDuration: CGFloat
    
    // MARK: - User ignore
    /** 源视频总时长（框架内部进行计算,使用者不需要关心） */
    var sourceVideoTotalDuration: CGFloat
    
    // MARK: - Optional
    /** 是否隐藏已选择时间标签 */
    var isHiddenSelectedTimeTag: Bool
    /** 选择框颜色 */
    var selectedBoxColor: UIColor
    /** 左边框图片 */
    var leftSelectedImage: UIImage
    /** 右边框图片 */
    var rightSelectedImage: UIImage
    /** 左右选择框图片的宽度 */
    var selectedImageWidth: CGFloat
    /** 初始化时选择框中选中的图片张数 */
    var defaultSelectedImageCount: UInt
    /** 选择框整体左间距 */
    var leftMargin: CGFloat
    /** 选择框整体右间距 */
    var rightMargin: CGFloat
    /** 左边按钮字体 */
    var leftButtonFont: UIFont
    /** 左边按钮文字颜色 */
    var leftButtonFontColor: UIColor
    /** 左边按钮背景色 */
    var leftButtonBackgroundColor: UIColor
    /** 左边按钮标题 */
    var leftButtonTitle: String
    /** 右边按钮字体 */
    var rightButtonFont: UIFont
    /** 右边按钮文字颜色 */
    var rightButtonFontColor: UIColor
    /** 右边按钮背景色 */
    var rightButtonBackgroundColor: UIColor
    /** 右边按钮标题 */
    var rightButtonTitle: String
    
    override init() {
        startTime = 0
        endTime = 0
        clippedVideoMinDuration = 3
        clippedVideoMaxDuration = 15
        sourceVideoTotalDuration = 0
        isHiddenSelectedTimeTag = false
        selectedBoxColor = .white
        leftSelectedImage = UIImage()
        rightSelectedImage = UIImage()
        selectedImageWidth = 15.0
        defaultSelectedImageCount = 8
        leftMargin = 30.0
        rightMargin = 30.0
        leftButtonFont = UIFont.boldSystemFont(ofSize: 16)
        leftButtonFontColor = .white
        leftButtonBackgroundColor = .clear
        leftButtonTitle = "取消"
        rightButtonFont =  UIFont.boldSystemFont(ofSize: 16)
        rightButtonFontColor = .white
        rightButtonBackgroundColor = .init(red: 65/255.0, green: 200/255.0, blue: 86/255.0, alpha: 1.0)
        rightButtonTitle = "完成"
    }
}
