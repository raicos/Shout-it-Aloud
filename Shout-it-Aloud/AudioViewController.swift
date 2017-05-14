//
//  AudioViewController.swift
//  Shout-it-Aloud
//
//  Created by k15046kk on 2017/04/26.
//  Copyright © 2017年 army. All rights reserved.
//


import UIKit
import AudioKit
import AudioUnit
import MediaPlayer
import Accelerate
import C4
// import EFAutoScrollLabel

class AudioViewController: UIViewController, MPMediaPickerControllerDelegate,AVAudioPlayerDelegate,AVAudioSessionDelegate {

    var audioPlayer: AVAudioPlayer!
    var audioEngine: AVAudioEngine!
    
    var isSelectMusic: Bool = false
    
    @IBOutlet weak var playButton: UIButton!
    @IBAction func onPlayButton() {
        if isSelectMusic {
            if audioPlayer.isPlaying {
                audioPlayer.pause()
                playButton.setTitle("再生", for: .normal)
            }else{
                audioPlayer.play()
                playButton.setTitle("停止", for: .normal)
            }
        }
    }
    
    @IBOutlet weak var musicVolumeSlider: UISlider!
    @IBAction func musicVolumeController() {
        audioPlayer.volume = musicVolumeSlider.value
    }
    
    @IBOutlet weak var inputVolumeLabel: UILabel!
    @IBOutlet weak var inputVolumeSlider: UISlider!
    @IBAction func inputVolumeController() {
        audioEngine.inputNode?.volume = inputVolumeSlider.value
        inputVolumeLabel.text = "".appendingFormat("%.2f", inputVolumeSlider.value)
    }
    
    @IBOutlet weak var boostSwitch: UISwitch!
    @IBAction func boostVolumeController() {
        if boostSwitch.isOn {
            inputVolumeSlider.maximumValue = 50
        } else {
            inputVolumeSlider.maximumValue = 10
        }
    }
    
    @IBOutlet weak var inputMicSwitch: UISwitch!
    @IBAction func inputMicController() {
        if inputMicSwitch.isOn {
            audioEngine.inputNode?.volume = inputVolumeSlider.value
            inputVolumeLabel.text = "".appendingFormat("%.2f", inputVolumeSlider.value)
        } else {
            audioEngine.inputNode?.volume = 0
            inputVolumeLabel.text = "MicOff"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mic()
        
        self.playButton.setTitle("再生", for: .normal)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func back() {
        //self.audioPlayer.stop()
        self.dismiss(animated: true, completion: nil)
    }

    func mic(){
        let format = AVAudioFormat(commonFormat: AVAudioCommonFormat.pcmFormatInt16,
                                   sampleRate: 44100.0, channels: 1, interleaved: true)
        self.audioEngine = AVAudioEngine()
        self.audioEngine.inputNode?.volume = self.inputVolumeSlider.value
        self.audioEngine.connect(self.audioEngine.inputNode!, to: self.audioEngine.mainMixerNode, format: format)
        try! self.audioEngine.start()
        self.inputVolumeLabel.text = "".appendingFormat("%.2f", inputVolumeSlider.value)
    }

    @IBAction func pick(sender: UIButton) {
        let picker = MPMediaPickerController()
        picker.delegate = self
        picker.allowsPickingMultipleItems = false
        picker.showsItemsWithProtectedAssets = false
        picker.showsCloudItems = false
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
            dismiss(animated: true, completion: nil)
        }
        
        let items = mediaItemCollection.items
        if items.isEmpty {
            return
        }
        
        
        let item = items.first
        if let url = item?.assetURL {
            audioPlayer = try! AVAudioPlayer(contentsOf: url)
            audioPlayer.delegate = self
            audioPlayer.isMeteringEnabled = true
            isSelectMusic = true
            /*
            AVAudioSession.sharedInstance().requestRecordPermission {_ in
                print("permission 要求")
                
                do {
                    // bluetooth機器として設定
                    try AVAudioSession.sharedInstance().setCategory(
                        AVAudioSessionCategoryPlayAndRecord,
                        with:AVAudioSessionCategoryOptions.allowBluetooth )
                    
                    try AVAudioSession.sharedInstance().overrideOutputAudioPort(.none)
                    
                    try AVAudioSession.sharedInstance().setActive(true)
                    
                } catch {
                    
                }
                
            }*/
            
        } else {
            self.isSelectMusic = false
            
        }
    }
    
    // 曲が終了した時に呼ばれる
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isSelectMusic = false
        playButton.setTitle("再生", for: .normal)
    }
    

}
