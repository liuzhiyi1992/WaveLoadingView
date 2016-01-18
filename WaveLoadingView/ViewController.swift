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
    @IBOutlet weak var borderWidthSliderBar: UISlider!
    
    @IBOutlet weak var isShowTipButton: UIButton!
    @IBOutlet weak var changeShapeButton: UIButton!
    @IBOutlet weak var exampleButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        radiusButton()
        
        waveLoadingIndicator.isShowProgressText = false
        
        self.navigationController?.navigationBar.translucent = false
        self.navigationController?.navigationBar.shadowImage = UIImage(named: "shadow")
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
        } else if sender.tag == 12 {
            waveLoadingIndicator.borderWidth = CGFloat(1) + CGFloat(3 * borderWidthSliderBar.value)
        }
    }
    
    @IBAction func clickExampleButton(sender: AnyObject) {
        let exampleController = DisplayViewController()
        self.navigationController?.pushViewController(exampleController, animated: true)
    }
    
    
    func setWaveValue(value: AnyObject) {
        waveLoadingIndicator.progress = value.doubleValue
    }
    
    func radiusButton() {
        isShowTipButton.layer.cornerRadius = isShowTipButton.bounds.size.height/2
        isShowTipButton.layer.masksToBounds = true
        changeShapeButton.layer.cornerRadius = changeShapeButton.bounds.size.height/2
        changeShapeButton.layer.masksToBounds = true
        exampleButton.layer.cornerRadius = exampleButton.bounds.size.height/2
        exampleButton.layer.masksToBounds = true

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

