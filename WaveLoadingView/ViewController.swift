//
//  ViewController.swift
//  WaveLoadingView
//
//  Created by lzy on 15/12/30.
//  Copyright © 2015年 lzy. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    
    @IBOutlet weak var waveLoadingIndicator: WaveLoadingIndicator!
    @IBOutlet weak var progressSliderBar: UISlider!
    @IBOutlet weak var amplitudeSliderBar: UISlider!
    
    @IBOutlet weak var isShowTipButton: UIButton!
    @IBOutlet weak var changeShapeButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        waveLoadingIndicator.isShowProgressText = false
        isShowTipButton.layer.cornerRadius = isShowTipButton.bounds.size.height/2
        isShowTipButton.layer.masksToBounds = true
        changeShapeButton.layer.cornerRadius = isShowTipButton.bounds.size.height/2
        isShowTipButton.layer.masksToBounds = true
    }
    

    @IBAction func clickIsShowTipButton(sender: UIButton) {
        waveLoadingIndicator.isShowProgressText = !waveLoadingIndicator.isShowProgressText
    }
    
    @IBAction func clickChangeShapeButton(sender: UIButton) {
        waveLoadingIndicator.shapeModel = (waveLoadingIndicator.shapeModel == ShapeModel.shapeModelCircle) ? ShapeModel.shapeModelRect : ShapeModel.shapeModelCircle
    }
    
    @IBAction func sliderBarValueDidChanged(sender: AnyObject) {
        if sender.tag == 10 {
            self.performSelector("setWaveValue:", withObject: progressSliderBar.value, afterDelay: 0.3)
        } else if sender.tag == 11 {
            waveLoadingIndicator.waveAmplitude = WaveLoadingIndicator.amplitudeMin + Double(amplitudeSliderBar.value) * WaveLoadingIndicator.amplitudeSpan
        }
    }
    
    func setWaveValue(value: AnyObject) {
        waveLoadingIndicator.progress = value.doubleValue
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

