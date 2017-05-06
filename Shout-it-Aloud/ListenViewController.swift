//
//  ListenViewController.swift
//  Shout-it-Aloud
//
//  Created by k15046kk on 2017/04/26.
//  Copyright © 2017年 army. All rights reserved.
//

import UIKit
import CoreMotion
import EFAutoScrollLabel
import AVFoundation
import AudioKit

class ListenViewController: UIViewController {
    var timer:Timer!
    var oscillator = AKOscillator(waveform: AKTable(AKTableType.triangle))
    var oscillator2 = AKOscillator(waveform: AKTable(AKTableType.square))
    var audioEngine: AVAudioEngine!
    override func viewDidLoad() {
        super.viewDidLoad()
        let mixer = AKMixer()
        AudioKit.output = mixer
        AudioKit.start()
        oscillator.amplitude = 0.1
        oscillator.frequency = 100
        oscillator2.amplitude = 0.5
        oscillator2.frequency = 230
        oscillator.start()
        oscillator2.start()
        
        let plot = AKNodeFFTPlot(mixer,frame:CGRect(x:0,y:0,width:250,height:500))
        //plot.backgroundColor = UIColor.black
        plot.shouldFill = true
        plot.shouldMirror = false
        plot.shouldCenterYAxis = false
        plot.color = UIColor.purple
        self.view.addSubview(plot)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func back() {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    
    

}
