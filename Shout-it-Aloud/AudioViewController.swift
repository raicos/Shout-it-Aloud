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

class AudioViewController: CanvasController, MPMediaPickerControllerDelegate, AVAudioPlayerDelegate {
    
    var audioPlayer: AVAudioPlayer!
    var audioEngine: AVAudioEngine!
    var timer = Timer()
    @IBOutlet var canvasView: UIView!

    var isSelectMusic: Bool = false
    
    @IBOutlet weak var playButton: UIButton!
    @IBAction func onPlayButton() {
        if isSelectMusic {
            if audioPlayer.isPlaying {
                audioPlayer.pause()
                playButton.setTitle("再生", for: .normal)
                timer.invalidate()
            }else{
                audioPlayer.play()
                playButton.setTitle("停止", for: .normal)
                timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(drawingView), userInfo: nil, repeats: true)
            }
        }
    }
    
    @IBOutlet weak var musicVolumeSlider: UISlider!
    @IBAction func musicVolumeController() {
        audioPlayer.volume = musicVolumeSlider.value
    }
    
    @IBOutlet weak var inputVolumeSlider: UISlider!
    @IBAction func inputVolumeController() {
        audioEngine.inputNode?.volume = inputVolumeSlider.value
    }
    
    @IBOutlet weak var boostSwitch: UISwitch!
    @IBAction func boostVolumeController() {
        if boostSwitch.isOn {
            inputVolumeSlider.maximumValue = 50
        }else{
            inputVolumeSlider.maximumValue = 10
        }
    }
    
    // 使用するかわからない
    @IBOutlet weak var messageLabel: UILabel!
    

    var audioFile: AVAudioFile!
    var audioPlayerNode: AVAudioPlayerNode!

    var mixer: AVAudioMixerNode!
    var outref: ExtAudioFileRef?
    
    var filePath: String? = nil

    
    let format = AVAudioFormat(commonFormat: AVAudioCommonFormat.pcmFormatInt16,
                               sampleRate: 44100.0, channels: 1, interleaved: true)
//

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.audioEngine = AVAudioEngine()
        self.audioEngine.inputNode?.volume = self.inputVolumeSlider.value
        self.audioEngine.connect(self.audioEngine.inputNode!, to: self.audioEngine.mainMixerNode)
        try! self.audioEngine.start()
        
        self.playButton.setTitle("再生", for: .normal)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func back() {
        self.audioPlayer.stop()
        self.dismiss(animated: true, completion: nil)
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
            //playButton.setTitle("停止", for: .normal)
            //audioPlayer.play()
            audioPlayer.isMeteringEnabled = true
            isSelectMusic = true
            
            
        } else {
            self.isSelectMusic = false
            self.playButton.setTitle("再生", for: .normal)
            
        }
        
    }
    
    // 曲が終了した時に呼ばれる
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isSelectMusic = false
        playButton.setTitle("再生", for: .normal)
        timer.invalidate()
    }
    
    func getLevelwithChannel(ch: Int) -> Float{
        if audioPlayer.isPlaying {
            audioPlayer.updateMeters()
            let db: Float = audioPlayer.averagePower(forChannel: ch)
            let power: Float = pow(10, (0.05 * db))
            return power
        } else {
            return 0.0
        }
    }
    
    let circle = Circle(center: Point(5,5), radius: 10)
    override func setup() {
        
        circle.fillColor = Color(red: 50, green: 50, blue: 50, alpha: 1)
        circle.center = Point(canvasView.center)
        canvasView.add(circle)
    }
    
    //: Float = audio.getLevelwithChannel(ch: 1)
    
    
    

    func drawingView() {
        let levelL: Float = getLevelwithChannel(ch: 0)
        let animation = ViewAnimation(){
            self.circle.transform = Transform.makeScale(Double(levelL*30), Double(levelL*30))
            //self.circle.fillColor = Color(red: 0, green: 0, blue: 0, alpha: 0)
        }
        
        /*
         */
        print(levelL*40)
        animation.animate()
        
    }
}
