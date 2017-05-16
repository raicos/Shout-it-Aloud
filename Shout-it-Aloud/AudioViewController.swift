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

class AudioViewController: UIViewController, MPMediaPickerControllerDelegate, AVAudioPlayerDelegate,AVAudioSessionDelegate {

    var audioPlayer: AVAudioPlayer!
    var audioEngine: AVAudioEngine!
    
    var isSelectMusic: Bool = false
    
    @IBOutlet weak var playButton: UIButton!
    @IBAction func onPlayButton() {
        if isSelectMusic {
            if audioPlayer.isPlaying {
                audioPlayer.pause()
                playButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            } else {
                audioPlayer.play()
                playButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
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
            inputVolumeSlider.maximumValue = 20
        }
    }
    
    @IBOutlet weak var inputMicSwitch: UISwitch!
    @IBAction func inputMicController() {
        if inputMicSwitch.isOn {
            audioEngine.inputNode?.volume = inputVolumeSlider.value
            inputVolumeSlider.isEnabled = true
            boostSwitch.isEnabled = true
            inputVolumeLabel.text = "".appendingFormat("%.2f", inputVolumeSlider.value)
        } else {
            audioEngine.inputNode?.volume = 0
            inputVolumeSlider.isEnabled = false
            boostSwitch.isEnabled = false
            inputVolumeLabel.text = "OFF"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mic()
        self.musicVolumeSlider.isEnabled = false
        
        self.playButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)

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
        self.inputMicSwitch.transform = CGAffineTransform(rotationAngle: CGFloat(Float.pi*3/2))
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
            musicVolumeSlider.isEnabled = true
            audioPlayer.volume = musicVolumeSlider.value
            playButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            
            // bluetooth のときだけにしたい
            /*
            AVAudioSession.sharedInstance().requestRecordPermission {_ in
                do {
                    // bluetooth機器として設定
                    try AVAudioSession.sharedInstance().setCategory(
                        AVAudioSessionCategoryPlayAndRecord,
                        with:AVAudioSessionCategoryOptions.allowBluetooth )
                    
                    try AVAudioSession.sharedInstance().overrideOutputAudioPort(.speaker)
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
        playButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
    }
}
