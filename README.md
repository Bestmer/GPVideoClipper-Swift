![](https://tva1.sinaimg.cn/large/007S8ZIlly1geqmdc0g5yj30r007gt96.jpg)

[![CocoaPods](https://img.shields.io/badge/pod-1.0.1-blue)](https://cocoapods.org/pods/GPVideoClipper)&nbsp;
[![CocoaPods](https://img.shields.io/badge/plaform-iOS8.0+-brightgreen)](https://github.com/Bestmer/GPVideoClipper)&nbsp;
[![License](https://img.shields.io/badge/License-MIT-red)](https://github.com/Bestmer/GPVideoClipper)&nbsp;
 
**iOS long video clip tool, similar to WeChat moments select and edit videos larger than 15s from albums, and support saving as a local album.**

##### Related Articles：
##### [GPVideoClipper裁剪原理](https://www.jianshu.com/p/8c8dfd041f94)
# Contents

* [Preview](#Preview)
* [Feature](#Feature)
* [Installation](#Installation)
* [Usage](#Usage)
* [Objective-C Version](#Objective-C)

# <span id="Preview">Preview</span>
![](https://tva1.sinaimg.cn/large/007S8ZIlly1geqyw8w1n4g30a00hmb2b.gif)

# <span id="Feature">Feature</span>

- Support custom UI.
- Simple to use, only need to pass in the URL of the video.
- Small size, low memory.

# <span id="Installation">Installation</span>

## CocoaPods

1. Specify it in your Podfile:：
```
pod 'GPVideoClipper-Swift'
```
2. then `pod install` or `pod update`。
3. `import GPVideoClipper_Swift`。

if you can't search this repository，try update CocoaPods version or 

1.`pod cache clean --all`

2.`rm -rf ~/Library/Caches/CocoaPods` 

3.`pod repo update`



## Manuel

Download GPVideoClipper and drag all files to your project. 

# <span id="Usage">Usage</span>

Init `GPVideoClipperController` ,then set videoURL and maker,in callback handle new video info .

```
let clipperController = GPVideoClipperController.clipperWithVideoURL(info[UIImagePickerController.InfoKey.mediaURL] as! URL, makerBlock: { (maker) in
    maker.startTime = 0
    maker.endTime = 15
    maker.clippedVideoMinDuration = 3
    maker.clippedVideoMaxDuration = 15
}) { (videoURL, videoAsset, coverImage) in
    // handle videoURL，videoAsset，coverImage
    let alertController = UIAlertController.init(title: "提示", message: "视频保存成功，请前往相册中查看!", preferredStyle: .alert)
    let doneAction = UIAlertAction.init(title: "确定", style: .default) { (action) in
        alertController.dismiss(animated: true, completion: nil)
    }
    alertController.addAction(doneAction)
    self.present(alertController, animated: true, completion: nil)
}
self.navigationController?.pushViewController(clipperController, animated: false)
```
# <span id="Objective-C">Objective-C Version</span>
- [GPVideoClipper Objective-C Version](https://github.com/Bestmer/GPVideoClipper)
---

![](https://tva1.sinaimg.cn/large/007S8ZIlly1geqmdc0g5yj30r007gt96.jpg)

[![CocoaPods](https://img.shields.io/badge/pod-1.0.1-blue)](https://cocoapods.org/pods/GPVideoClipper)&nbsp;
[![CocoaPods](https://img.shields.io/badge/plaform-iOS8.0+-brightgreen)](https://github.com/Bestmer/GPVideoClipper)&nbsp;
[![License](https://img.shields.io/badge/License-MIT-red)](https://github.com/Bestmer/GPVideoClipper)&nbsp;

## 中文版本

**iOS长视频裁剪工具,类似于微信朋友圈从手机相册选择大于15s的视频后进行裁剪,支持另存为至本地相册。**

##### 相关文章：
##### [GPVideoClipper裁剪原理](https://www.jianshu.com/p/8c8dfd041f94)
# 目录

* [预览](#预览)
* [特性](#特性)
* [安装](#安装)
* [用法](#用法)
* [Objective-C版本](#OC)


# 预览

![](https://tva1.sinaimg.cn/large/007S8ZIlly1geqyw8w1n4g30a00hmb2b.gif)

# 特性

- 支持自定义UI。
- 使用简单，仅需要传入视频的URL。
- 体积小巧，不占用内存空间。


# 安装

## CocoaPods

1. 在 Podfile 中添加：
```
pod 'GPVideoClipper-Swift'
```
2. 执行 `pod install` 或 `pod update`。
3. 导入 `import GPVideoClipper_Swift`。

如果搜不到这个库，试着更新CocoaPods版本或者执行下面的操作：

1.`pod cache clean --all`

2.`rm -rf ~/Library/Caches/CocoaPods` 

3.`pod repo update`

## 手动导入

下载 GPVideoClipper 文件夹所有内容并拖入你的工程中即可.


# 用法

初始化`GPVideoClipperController`,然后赋值videoURL和maker，最后在回调中处理新的视频信息。

```
let clipperController = GPVideoClipperController.clipperWithVideoURL(info[UIImagePickerController.InfoKey.mediaURL] as! URL, makerBlock: { (maker) in
    maker.startTime = 0
    maker.endTime = 15
    maker.clippedVideoMinDuration = 3
    maker.clippedVideoMaxDuration = 15
}) { (videoURL, videoAsset, coverImage) in
    // handle videoURL，videoAsset，coverImage
    let alertController = UIAlertController.init(title: "提示", message: "视频保存成功，请前往相册中查看!", preferredStyle: .alert)
    let doneAction = UIAlertAction.init(title: "确定", style: .default) { (action) in
        alertController.dismiss(animated: true, completion: nil)
    }
    alertController.addAction(doneAction)
    self.present(alertController, animated: true, completion: nil)
}
self.navigationController?.pushViewController(clipperController, animated: false)
```
# <span id="OC">Objective-C 版本</span>

- [GPVideoClipper Objective-C ](https://github.com/Bestmer/GPVideoClipper)

