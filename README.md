# WaveLoadingView
A loading indicator like water wave

###You can play a demo with [appetize.io](https://appetize.io/app/9upnjbk9hwjaz9hjyzuz41788c?device=iphone5s&scale=75&orientation=portrait&osVersion=9.2)


<br>
#**Features：**

![](https://raw.githubusercontent.com/liuzhiyi1992/WaveLoadingView/master/WaveLoadingView/2016-01-19%2010_26_10.gif)

<br>
#**Property：**
- cycle —— 循环次数，在控件宽度范围内，该正弦函数图形循环的次数，数值越大控件范围内看见的正弦函数图形周期数越多，波长约短波浪也越陡。  
- term —— 正弦周期，在layoutSubviews中根据cycle重新计算，==修改无效==  
- phasePosition —— 正弦函数相位，==不可修改==，否则图形错乱  
- amplitude —— 波幅，数值越大，波浪幅度越大，波浪越陡，反之越平缓，可通过代码调用`waveAmplitude`修改  
- position —— 正弦曲线的X轴 相对于 控件Y坐标的位置，在-drawRect中通过progress计算，==修改无效==  
- waveMoveSpan —— 波浪移动的单位跨度，数值越大波浪移动越快，数值过大会出现不连续动画现象  
- animationUnitTime —— 重画单位时间，数值越小，重画速度越快频率越大  
- heavyColor —— demo中较深的绿色部分  
- lightColor —— demo中较浅的绿色部分  
- clipCircleColor —— 玻璃球边界颜色  
- clipCircleLineWidth —— 玻璃球边线宽度，可通过代码调用`borderWidth`修改  
- progressTextFontSize —— 中央进度提示百分比字号大小


<br>
#**Usage：**
1. include the file WaveLoadingView.swift to your project, and about objectiveC, you can create a bridge Header and import it
2. creat a waveLoadingIndicator instance
```swift
let waveLoadingIndicator: WaveLoadingIndicator = WaveLoadingIndicator(frame: CGRectZero)
```
3. add waveLoadingIndicator to your imageView, equal bounds here i do , and FlexibleWidth,height
```swift
self.displayImageView.addSubview(self.waveLoadingIndicator)  
self.waveLoadingIndicator.frame = self.displayImageView.bounds  
self.waveLoadingIndicator.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
```
4. and your can used combine with SDWebImage:
```swift
self.displayImageView.sd_setImageWithURL(url, placeholderImage: nil, options: .CacheMemoryOnly, progress: {
    [weak self](receivedSize, expectedSize) -> Void in
    
    guard let weakSelf = self else {
        return
    }
    
    weakSelf.waveLoadingIndicator.progress = Double(CGFloat(receivedSize)/CGFloat(expectedSize))
    }) {
        [weak self](image, error, _, _) -> Void in
        // 不要忘记在完成下载回调中，移除waveLoadingIndicator
        guard let weakSelf = self else {
            return
        }
        
        weakSelf.waveLoadingIndicator.removeFromSuperview()
}
```
> <br>
> Don't worry， after -removeFromSuperview(), the animation have been stop

<br>
#**License：** 
WaveLoadingIndicator is available under the MIT license. See the LICENSE file for more info.
