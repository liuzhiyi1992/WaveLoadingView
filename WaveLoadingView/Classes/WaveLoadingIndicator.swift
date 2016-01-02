//
//  WaveLoadingIndicator.swift
//  WaveLoadingView
//
//  Created by lzy on 15/12/30.
//  Copyright © 2015年 lzy. All rights reserved.
//

import UIKit


let π = M_PI

private let amplitude_min = 16.0//波幅最小值
private let amplitude_span = 26.0//波幅可调节幅度

private let cycle = 1.0//循环次数
private var term = 60.0//周期（在代码中重新计算）
private var phasePosition = 0.0//相位必须为0(画曲线机制局限)
private var amplitude = 29.0//波幅
private var position = 40.0//X轴所在的Y坐标（在代码中重新计算）
private var originX = 0.0//X坐标起点
private let waveMoveSpan = 5.0//波浪移动单位跨度

private let heavyColor = UIColor(red: 38/255.0, green: 227/255.0, blue: 198/255.0, alpha: 1.0)
private let lightColor = UIColor(red: 121/255.0, green: 248/255.0, blue: 221/255.0, alpha: 1.0)
private let clipCircleColor = heavyColor

private let clipCircleLineWidth = CGFloat(1)

private let progressTextFontSize: CGFloat = 15.0

enum ShapeModel {
    case shapeModelCircle
    case shapeModelRect
}


class WaveLoadingIndicator: UIView {
    
    
    class var amplitudeMin: Double {
        get { return amplitude_min }
    }
    class var amplitudeSpan: Double {
        get { return amplitude_span }
    }
    
    var progress: Double = 0.5 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    var waveAmplitude: Double {
        get { return amplitude }
        set {
            amplitude = newValue
            self.setNeedsDisplay()
        }
    }
    
    var isShowProgressText = true
    
    var shapeModel:ShapeModel = .shapeModelCircle
    
    
    
    //if use not in xib, create an func init
    override func awakeFromNib() {
        animationWave()
        self.backgroundColor = UIColor.clearColor()
    }
    
    
    //正弦函数公式  y = Asin(wt +_ $)
    override func drawRect(rect: CGRect) {
        position =  (1 - progress) * Double(rect.height)
        
        //圆形clip
        clipWithCircle()
        
        //水波
        drawWaveWater(originX - term / 5, fillColor: lightColor)
        drawWaveWater(originX, fillColor: heavyColor)
        
        //为了让clipCircle在水波之上
        clipWithCircle()
        
        //进度文字提示
        if isShowProgressText {
            drawProgressText()
        }
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //计算周期
        term =  Double(self.bounds.size.width) / cycle
    }
    
    
    func clipWithCircle() {
        let circleRectWidth = min(self.bounds.size.width, self.bounds.size.height) - 2 * clipCircleLineWidth
        let circleRectOriginX = (self.bounds.size.width - circleRectWidth) / 2
        let circleRectOriginY = (self.bounds.size.height - circleRectWidth) / 2
        let circleRect = CGRectMake(circleRectOriginX, circleRectOriginY, circleRectWidth, circleRectWidth)
        
        var clipPath: UIBezierPath!
        if shapeModel == .shapeModelCircle {
            clipPath = UIBezierPath(ovalInRect: circleRect)
        } else if shapeModel == .shapeModelRect {
            clipPath = UIBezierPath(rect: circleRect)
        }
        
        clipCircleColor.setStroke()
        clipPath.lineWidth = clipCircleLineWidth
        clipPath.stroke()
        clipPath.addClip()
    }
    
    
    func drawWaveWater(originX: Double, fillColor: UIColor) {
        let curvePath = UIBezierPath()
        curvePath.moveToPoint(CGPoint(x: originX, y: position))
        
        //循环，画波浪
        var tempPoint = originX
        for _ in 1...rounding(4 * cycle) {//(2 * cycle)即可充满屏幕，即一个循环,为了移动画布使波浪移动，我们要画两个循环
            curvePath.addQuadCurveToPoint(keyPoint(tempPoint + term / 2, originX: originX), controlPoint: keyPoint(tempPoint + term / 4, originX: originX))
            tempPoint += term / 2
        }
        
        //封闭整个颜色范围
        curvePath.addLineToPoint(CGPoint(x: curvePath.currentPoint.x, y: self.bounds.size.height))
        curvePath.addLineToPoint(CGPoint(x: CGFloat(originX), y: self.bounds.size.height))
        curvePath.closePath()
        
        fillColor.setFill()
        curvePath.lineWidth = 10
        curvePath.fill()
    }
    
    
    func drawProgressText() {
        let progressText = (NSString(format: "%.0f", (progress * 100)) as String) + "%"
        
        var attribute: [String : AnyObject]!
        if progress > 0.45 {
            attribute = [NSFontAttributeName : UIFont.systemFontOfSize(progressTextFontSize), NSForegroundColorAttributeName : UIColor.whiteColor()]
        } else {
            attribute = [NSFontAttributeName : UIFont.systemFontOfSize(progressTextFontSize), NSForegroundColorAttributeName : heavyColor]
        }
        
        
        let textSize = progressText.sizeWithAttributes(attribute)
        let textRect = CGRectMake(self.bounds.width/2 - textSize.width/2, self.bounds.height/2 - textSize.height/2, textSize.width, textSize.height)
        
//        let textRect = CGRectMake(self.bounds.width/2 - textSize.width/2, CGFloat(position), textSize.width, textSize.height)
        
        progressText.drawInRect(textRect, withAttributes: attribute)
        
    }
    
    
    func animationWave() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
            let tempOriginX = originX
            while true {
                NSThread.sleepForTimeInterval(0.08)
                if originX <= tempOriginX - term {
                    originX = tempOriginX - waveMoveSpan
                } else {
                    originX -= waveMoveSpan
                }
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.setNeedsDisplay()
                })
            }
        }
    }
    
    
    //确定曲线的关键点
    func keyPoint(x: Double, originX: Double) -> CGPoint {
        //x为当前取点x坐标，columnYPoint的参数为相对于正弦函数原点的x坐标
        return CGPoint(x: x, y: columnYPoint(x - originX))
    }
    
    
    func columnYPoint(x: Double) -> Double {
        //三角正弦函数
        let result = amplitude * sin((2 * π / term) * x + phasePosition)
        return result + position
    }
    
    //四舍五入
    func rounding(value: Double) -> Int {
        let tempInt = Int(value)
        let tempDouble = Double(tempInt) + 0.5
        if value > tempDouble {
            return tempInt + 1
        } else {
            return tempInt
        }
    }
    
    
}
