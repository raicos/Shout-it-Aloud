//
//  FFT.swift
//  Shout-it-Aloud
//
//  Created by k15046kk on 2017/05/04.
//  Copyright © 2017年 army. All rights reserved.
//

import Accelerate
import AudioKit
import MediaPlayer
import AudioKit
import UIKit

class FFT: UIViewController, MPMediaPickerControllerDelegate {
    @IBOutlet var b:UIButton!
    @IBOutlet private var frequencyLabel: UILabel!
    @IBOutlet private var amplitudeLabel: UILabel!
    @IBOutlet private var noteNameWithSharpsLabel: UILabel!
    @IBOutlet private var noteNameWithFlatsLabel: UILabel!
    @IBOutlet private var audioInputPlot: EZAudioPlot!
    
    var url:URL!
    var mic: AKMicrophone!
    var kk: AKAudioPlayer!
    //var file: AVAudioFile!
    var tracker: AKFrequencyTracker!
    var silence: AKBooster!
    
    let noteFrequencies = [16.35, 17.32, 18.35, 19.45, 20.6, 21.83, 23.12, 24.5, 25.96, 27.5, 29.14, 30.87]
    let noteNamesWithSharps = ["C", "C♯", "D", "D♯", "E", "F", "F♯", "G", "G♯", "A", "A♯", "B"]
    let noteNamesWithFlats = ["C", "D♭", "D", "E♭", "E", "F", "G♭", "G", "A♭", "A", "B♭", "B"]
    
    func setupPlot() {
        let plot = AKNodeOutputPlot(kk, frame: audioInputPlot.bounds)
        plot.plotType = .buffer
        plot.shouldFill = true
        plot.shouldMirror = true
        plot.color = UIColor.blue
        audioInputPlot.addSubview(plot)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pick(sender: b)
        AKSettings.audioInputEnabled = true
        mic = AKMicrophone()
        //try! kk = AKAudioPlayer(file: AKAudioFile(forReading: url))
        tracker = AKFrequencyTracker(mic)
        silence = AKBooster(tracker, gain: 0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        AudioKit.output = silence
        AudioKit.start()
        setupPlot()
        Timer.scheduledTimer(timeInterval: 0.1,
                             target: self,
                             selector: #selector(FFT.updateUI),
                             userInfo: nil,
                             repeats: true)
    }
    
    func updateUI() {
        if tracker.amplitude > 0.1 {
            frequencyLabel.text = String(format: "%0.1f", tracker.frequency)
            
            var frequency = Float(tracker.frequency)
            while frequency > Float(noteFrequencies[noteFrequencies.count - 1]) {
                frequency /= 2.0
            }
            while frequency < Float(noteFrequencies[0]) {
                frequency *= 2.0
            }
            
            var minDistance: Float = 10_000.0
            var index = 0
            
            for i in 0..<noteFrequencies.count {
                let distance = fabsf(Float(noteFrequencies[i]) - frequency)
                if distance < minDistance {
                    index = i
                    minDistance = distance
                }
            }
            let octave = Int(log2f(Float(tracker.frequency) / frequency))
            noteNameWithSharpsLabel.text = "\(noteNamesWithSharps[index])\(octave)"
            noteNameWithFlatsLabel.text = "\(noteNamesWithFlats[index])\(octave)"
        }
        amplitudeLabel.text = String(format: "%0.2f", tracker.amplitude)
    }
    
    
    @IBAction func pick(sender: UIButton) {
        // MPMediaPickerControllerのインスタンスを作成
        let picker = MPMediaPickerController()
        picker.delegate = self
        // 複数選択(true or false)
        picker.allowsPickingMultipleItems = false
        // 読み込めない曲は非表示
        picker.showsItemsWithProtectedAssets = false
        picker.showsCloudItems = false
        // ピッカーを表示する
        present(picker, animated: true, completion: nil)
    }
    
    //選択がキャンセルされた場合に呼ばれる
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // 選択完了したときに呼ばれる
    func mediaPicker(_ mediaPicker: MPMediaPickerController,
                     didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        
        defer {
            kk.play()
            dismiss(animated: true, completion: nil)
        }
        
        let items = mediaItemCollection.items
        if items.isEmpty {
            return
        }
        
        // 先頭のMPMediaItemを取得し、そのassetURLからプレイヤーを作成する
        let item = items.first
        if let url = item?.assetURL {
            self.url = url
            try! kk = AKAudioPlayer(file: AKAudioFile(forReading: self.url))
        } else {
            
        }
    }

}
