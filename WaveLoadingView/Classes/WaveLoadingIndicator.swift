//
//  WaveLoadingIndicator.swift
//  WaveLoadingView
//
//  Created by lzy on 15/12/30.
//  Copyright © 2015年 lzy. All rights reserved.
//

//正弦函数公式  y = amplitude * sin((2 * π / term) * x +- phasePosition)
import UIKit


let π = M_PI

enum ShapeModel {
    case shapeModelCircle
    case shapeModelRect
}


class WaveLoadingIndicator: UIView {
    
    var originX = 0.0//X坐标起点, the x origin of wave
    static private let amplitude_min = 16.0//波幅最小值
    static private let amplitude_span = 26.0//波幅可调节幅度
    
    private let cycle = 1.0//循环次数, num of circulation
    private var term = 60.0//周期（在代码中重新计算）, recalculate in layoutSubviews
    private var phasePosition = 0.0//相位必须为0(画曲线机制局限), phase Must be 0
    private var amplitude = 29.0//波幅
    private var position = 40.0//X轴所在的Y坐标（在代码中重新计算）, where the x axis of wave position
    
    private let waveMoveSpan = 5.0//波浪移动单位跨度, the span wave move in a unit time
    private let animationUnitTime = 0.08//重画单位时间, redraw unit time
    
    private let heavyColor = UIColor(red: 38/255.0, green: 227/255.0, blue: 198/255.0, alpha: 1.0)
    private let lightColor = UIColor(red: 121/255.0, green: 248/255.0, blue: 221/255.0, alpha: 1.0)
    private let clipCircleColor = UIColor(red: 38/255.0, green: 227/255.0, blue: 198/255.0, alpha: 1.0)
    
    private var clipCircleLineWidth: CGFloat = 1
    
    private let progressTextFontSize: CGFloat = 15.0
    
    private var waving: Bool = true
    
    
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
    
    var borderWidth: CGFloat {
        get { return clipCircleLineWidth }
        set {
            clipCircleLineWidth = newValue
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        animationWave()
        self.backgroundColor = UIColor.clearColor()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
//        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
    }
    
    override func drawRect(rect: CGRect) {
        position =  (1 - progress) * Double(rect.height)
        
        //circle clip
        clipWithCircle()
        
        //draw wave
        drawWaveWater(originX - term / 5, fillColor: lightColor)
        drawWaveWater(originX, fillColor: heavyColor)
        
        //Let clipCircle above the waves
        clipWithCircle()
        
        //draw the tip text of progress
        if isShowProgressText {
            drawProgressText()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //计算周期calculate the term
        term =  Double(self.bounds.size.width) / cycle
    }

    override func removeFromSuperview() {
        super.removeFromSuperview()
        waving = false
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
        
        //循环，画波浪wave path
        var tempPoint = originX
        for _ in 1...rounding(4 * cycle) {//(2 * cycle)即可充满屏幕，即一个循环,为了移动画布使波浪移动，我们要画两个循环
            curvePath.addQuadCurveToPoint(keyPoint(tempPoint + term / 2, originX: originX), controlPoint: keyPoint(tempPoint + term / 4, originX: originX))
            tempPoint += term / 2
        }
        
        //close the water path
        curvePath.addLineToPoint(CGPoint(x: curvePath.currentPoint.x, y: self.bounds.size.height))
        curvePath.addLineToPoint(CGPoint(x: CGFloat(originX), y: self.bounds.size.height))
        curvePath.closePath()
        
        fillColor.setFill()
        curvePath.lineWidth = 10
        curvePath.fill()
    }
    
    
    func drawProgressText() {
        //Avoid negative
        var validProgress = progress * 100
        validProgress = validProgress < 1 ? 0 : validProgress
        
        let progressText = (NSString(format: "%.0f", validProgress) as String) + "%"
        
        var attribute: [String : AnyObject]!
        if progress > 0.45 {
            attribute = [NSFontAttributeName : UIFont.systemFontOfSize(progressTextFontSize), NSForegroundColorAttributeName : UIColor.whiteColor()]
        } else {
            attribute = [NSFontAttributeName : UIFont.systemFontOfSize(progressTextFontSize), NSForegroundColorAttributeName : heavyColor]
        }
        
        let textSize = progressText.sizeWithAttributes(attribute)
        let textRect = CGRectMake(self.bounds.width/2 - textSize.width/2, self.bounds.height/2 - textSize.height/2, textSize.width, textSize.height)
        
        progressText.drawInRect(textRect, withAttributes: attribute)
    }
    
    
    func animationWave() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { [weak self]() -> Void in
            if self != nil {
                let tempOriginX = self!.originX
                while self != nil && self!.waving {
                    if self!.originX <= tempOriginX - self!.term {
                        self!.originX = tempOriginX - self!.waveMoveSpan
                    } else {
                        self!.originX -= self!.waveMoveSpan
                    }
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self!.setNeedsDisplay()
                    })
                    NSThread.sleepForTimeInterval(self!.animationUnitTime)
                }
            }
        }
    }
    
    
    //determine the key point of curve
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

// 版权属于原作者
// 个人博客 zyden.vicp.cc
