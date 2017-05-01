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
    
    // プレイヤー用のproperty
    var audioPlayer:AVAudioPlayer?
    
    
    @IBOutlet weak var messageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // メッセージラベルのテキストをクリア
        messageLabel.text = ""
        messageLabel.adjustsFontForContentSizeCategory = false
        
        
        
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func back() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func pick(sender: AnyObject) {
        // MPMediaPickerControllerのインスタンスを作成
        let picker = MPMediaPickerController()
        // ピッカーのデリゲートを設定
        picker.delegate = self
        // 複数選択を不可にする。（trueにすると、複数選択できる）
        picker.allowsPickingMultipleItems = false
        // ピッカーを表示する
        present(picker, animated: true, completion: nil)
        
    }
    
    // メディアアイテムピッカーでアイテムを選択完了したときに呼び出される
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        
        // このfunctionを抜ける際にピッカーを閉じ、破棄する
        // (defer文はfunctionを抜ける際に実行される)
        defer {
            dismiss(animated: true, completion: nil)
        }
        
        
        // 選択した曲情報がmediaItemCollectionに入っている
        // mediaItemCollection.itemsから入っているMPMediaItemの配列を取得できる
        let items = mediaItemCollection.items
        if items.isEmpty {
            // itemが一つもなかったので戻る
            return
        }
        
        // 先頭のMPMediaItemを取得し、そのassetURLからプレイヤーを作成する
        let item = items[0]
        if let url = item.assetURL {
            do {
                // itemのassetURLからプレイヤーを作成する
                audioPlayer = try AVAudioPlayer(contentsOf: url)
            } catch  {
                // エラー発生してプレイヤー作成失敗
                
                // messageLabelに失敗したことを表示
                messageLabel.text = "このurlは再生できません"
                
                audioPlayer = nil
                
                
                // 戻る
                return
                
            }
            
            // 再生開始
            if let player = audioPlayer {
                player.play()
                
                // メッセージラベルに曲タイトルを表示
                // (MPMediaItemが曲情報を持っているのでそこから取得)
                let title = item.title ?? ""
                messageLabel.text = title
                // test.text = title
                
            }
        } else {
            // messageLabelに失敗したことを表示
            messageLabel.text = "アイテムのurlがnilなので再生できません"
            
            audioPlayer = nil
        }
        
    }
    
    
    //選択がキャンセルされた場合に呼ばれる
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        // ピッカーを閉じ、破棄する
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func pushPlay(sender: AnyObject) {
        // 再生
        if let player = audioPlayer {
            player.play()
        }
    }
    
    @IBAction func pushPause(sender: AnyObject) {
        // 一時停止
        if let player = audioPlayer {
            player.pause()
        }
    }
    
    
}
    
    

