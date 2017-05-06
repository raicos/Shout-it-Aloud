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
        
        //ShapeLayer.disableActions = true
        canvas.backgroundColor = C4Grey
        let blue = Circle(center: Point.init(5, 5), radius: 50)
        blue.fillColor = Color(red: 226/255, green: 122/255, blue: 4/255, alpha: 1)
        blue.center = self.canvas.center
        self.canvas.add(blue)
        
        //ShapeLayer.disableActions = false
        let blueAnimation = ViewAnimation(duration: 0.7) {
            blue.transform = Transform.makeScale(100, 100)
            blue.fillColor = Color(red: 0, green: 0, blue: 0, alpha: 0)
        }
        
        blueAnimation.addCompletionObserver {
            blue.removeFromSuperview()
        }
        wait(3.0){
             blueAnimation.animate()
        }
       
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func back() {
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
            playButton.setTitle("停止", for: .normal)
            audioPlayer.play()
            audioPlayer.isMeteringEnabled = true
            isSelectMusic = true
            
            // test 用
            audioPlayer.currentTime = TimeInterval(50)

            
        } else {
            self.isSelectMusic = false
            self.playButton.setTitle("再生", for: .normal)
            
        }
    }
    
    // 曲が終了した時に呼ばれる
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isSelectMusic = false
        playButton.setTitle("再生", for: .normal)
        
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
    
    // 曲の録音　no use
    func record(item: MPMediaItem) {
        self.filePath = nil
        
        let url = item.assetURL
        audioPlayer = try! AVAudioPlayer(contentsOf: url!)
        audioPlayer.delegate = self
        /*self.audioFile = try! AVAudioFile(forReading: url!)
        
        self.audioEngine.connect(self.audioPlayerNode, to: self.mixer, format: self.audioFile.processingFormat)
        self.audioPlayerNode.scheduleSegment(audioFile, startingFrame: AVAudioFramePosition(0),
                                             frameCount: AVAudioFrameCount(self.audioFile.length),
                                             at: nil, completionHandler: nil)
        */
        let dir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! as String
        self.filePath =  dir.appending("/temp.wav")
        
        _ = ExtAudioFileCreateWithURL(URL(fileURLWithPath: self.filePath!) as CFURL,
                                      kAudioFileWAVEType,
                                      format.streamDescription,
                                      nil,
                                      AudioFileFlags.eraseFile.rawValue,
                                      &outref)
        
        self.mixer.installTap(onBus: 0, bufferSize: AVAudioFrameCount(format.sampleRate * 0.4), format: format, block: { (buffer: AVAudioPCMBuffer!, time: AVAudioTime!) -> Void in
            
            let audioBuffer : AVAudioBuffer = buffer
            _ = ExtAudioFileWrite(self.outref!, buffer.frameLength, audioBuffer.audioBufferList)
        })
    }

}
