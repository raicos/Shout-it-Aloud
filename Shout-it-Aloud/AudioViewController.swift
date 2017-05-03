//
//  AudioViewController.swift
//  Shout-it-Aloud
//
//  Created by k15046kk on 2017/04/26.
//  Copyright © 2017年 army. All rights reserved.
//


import UIKit
import AudioKit
import MediaPlayer
import AudioUnit
import EFAutoScrollLabel

class AudioViewController: UIViewController, MPMediaPickerControllerDelegate {
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    
    var audioFile: AVAudioFile!
    var audioPlayerNode: AVAudioPlayerNode!
    var audioEngine: AVAudioEngine!
    var mixer: AVAudioMixerNode!
    var outref: ExtAudioFileRef?
    
    var filePath: String? = nil
    var isSelectMusic: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        initialize()
        playButton.setTitle("再生", for: .normal)
    }
    
    func initialize() {
        self.audioEngine = AVAudioEngine()
        self.audioPlayerNode = AVAudioPlayerNode()
        self.mixer = AVAudioMixerNode()
        self.audioEngine.attach(audioPlayerNode)
        self.audioEngine.attach(mixer)
        
        let format = AVAudioFormat(commonFormat: AVAudioCommonFormat.pcmFormatInt16,
                                   sampleRate: 44100.0,
                                   channels: 1,
                                   interleaved: true)
        
        self.audioEngine.connect(self.audioEngine.inputNode!, to: self.mixer, format: format)
        self.audioEngine.connect(self.mixer, to: self.audioEngine.mainMixerNode, format: format)
        try! self.audioEngine.start()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeAudio) != .authorized {
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeAudio,
                                          completionHandler: {(granted: Bool) in
            })
        }
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
    
    // 選択完了したときに呼ばれる
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        
        defer {
            dismiss(animated: true, completion: nil)
        }
        
        // 選択した曲情報がmediaItemCollectionに入っている
        // mediaItemCollection.itemsから入っているMPMediaItemの配列を取得できる
        let items = mediaItemCollection.items
        if items.isEmpty {
            return
        }
        
        // 先頭のMPMediaItemを取得し、そのassetURLからプレイヤーを作成する
        if let item = items.first {
            record(item: item)
            
            
            
            
        } else {
            // messageLabelに失敗したことを表示
            messageLabel.text = "アイテムのurlがnilなので再生できません"
            //audioPlayerNode = nil
        }
    }
    
    //選択がキャンセルされた場合に呼ばれる
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func record(item: MPMediaItem) {
        self.audioEngine.reset()
        self.initialize()
        self.filePath = nil
        
        let url = item.assetURL
        self.audioFile = try! AVAudioFile(forReading: url!)
        
        
        let format = AVAudioFormat(commonFormat: AVAudioCommonFormat.pcmFormatInt16,
                                   sampleRate: 44100.0,
                                   channels: 1,
                                   interleaved: true)

        self.audioEngine.connect(self.audioEngine.inputNode!, to: self.mixer, format: format)
        self.audioEngine.connect(self.audioPlayerNode,
                                 to: self.mixer,
                                 format: self.audioFile.processingFormat)
        self.audioEngine.connect(self.mixer, to: self.audioEngine.mainMixerNode, format: format)
        
        self.audioPlayerNode.scheduleSegment(audioFile,
                                             startingFrame: AVAudioFramePosition(0),
                                             frameCount: AVAudioFrameCount(self.audioFile.length),
                                             at: nil,
                                             completionHandler: nil)
        
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
        
        try! self.audioEngine.start()
        // すぐ再生
        //self.audioPlayerNode.play()
        self.playButton.setTitle("再生", for: .normal)
        isSelectMusic = true
    }
    
    @IBAction func onPlayButton() {
        if isSelectMusic {
            if audioPlayerNode.isPlaying {
                audioPlayerNode.pause()
                playButton.setTitle("再生", for: .normal)
            }else{
                audioPlayerNode.play()
                playButton.setTitle("停止", for: .normal)
            }
        }
    }
    
    
    
}
    
    

