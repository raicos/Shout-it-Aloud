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
// import EFAutoScrollLabel

class AudioViewController: UIViewController, MPMediaPickerControllerDelegate, AVAudioPlayerDelegate {
    
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
    
    @IBOutlet weak var messageLabel: UILabel!
    
    var audioPlayer: AVAudioPlayer!
    var audioFile: AVAudioFile!
    var audioPlayerNode: AVAudioPlayerNode!
    var audioEngine: AVAudioEngine!
    var mixer: AVAudioMixerNode!
    var outref: ExtAudioFileRef?
    
    var filePath: String? = nil
    var isSelectMusic: Bool = false
    
    let format = AVAudioFormat(commonFormat: AVAudioCommonFormat.pcmFormatInt16,
                               sampleRate: 44100.0, channels: 1, interleaved: true)


    override func viewDidLoad() {
        super.viewDidLoad()
        audioEngine = AVAudioEngine()
        audioEngine.inputNode?.volume = inputVolumeSlider.value
        audioEngine.connect(audioEngine.inputNode!, to: audioEngine.mainMixerNode)
        try! audioEngine.start()
        //initialize()
        playButton.setTitle("再生", for: .normal)
        
        
    }
    

    
    func initialize() {
        self.audioEngine = AVAudioEngine()
        //self.audioPlayerNode = AVAudioPlayerNode()
        self.mixer = AVAudioMixerNode()
        //self.audioEngine.attach(audioPlayerNode)
        self.audioEngine.attach(mixer)
        
        
        self.audioEngine.inputNode?.volume = inputVolumeSlider.value
        self.audioEngine.connect(self.audioEngine.inputNode!, to: self.mixer, format: format)
        self.audioEngine.connect(self.mixer, to: self.audioEngine.mainMixerNode, format: format)
        try! self.audioEngine.start()
    }
    /*
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeAudio) != .authorized {
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeAudio,
                                          completionHandler: {(granted: Bool) in
            })
        }
    }
*/
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func back() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isSelectMusic = false
        playButton.setTitle("再生", for: .normal)
        
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
        
        // 先頭のMPMediaItemを取得し、そのassetURLからプレイヤーを作成する
        let item = items.first
        if let url = item?.assetURL {
            audioPlayer = try! AVAudioPlayer(contentsOf: url)
            audioPlayer.delegate = self
            playButton.setTitle("停止", for: .normal)
            audioPlayer.play()
            isSelectMusic = true
            // test 用
            audioPlayer.currentTime = TimeInterval(50)
            audioPlayer.updateMeters()
            let db:Float = audioPlayer.averagePower(forChannel: 0)
            print(db)
            
        } else {
            self.isSelectMusic = false
            self.playButton.setTitle("再生", for: .normal)
            
        }
    }
    // テスト用
    var tt:Float=0
    var db:Float = 0
    @IBAction func testButton() {
        audioPlayer.isMeteringEnabled = true
        audioPlayer.updateMeters()
        db = audioPlayer.averagePower(forChannel: 0)
        let db1:Float = audioPlayer.averagePower(forChannel: 1)
        // let db2:Float = audioPlayer.averagePower(forChannel: 2)
        
        tt = pow(10, 0.05*db)
        print(db,db1,audioPlayer.peakPower(forChannel: 0),tt)
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
