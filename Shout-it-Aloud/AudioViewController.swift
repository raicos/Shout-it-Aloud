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

class AudioViewController: UIViewController, MPMediaPickerControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var albumLabel: UILabel!
    @IBOutlet weak var songLabel: UILabel!
    
    var player = MPMusicPlayerController()
    var nowPlaying: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        player = MPMusicPlayerController.applicationMusicPlayer()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func back(){
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func pick(sender: AnyObject) {
        // MPMediaPickerControllerのインスタンスを作成
        let picker = MPMediaPickerController()
        // ピッカーのデリゲートを設定
        picker.delegate = self
        // 複数選択にする。（falseにすると、単数選択になる）
        picker.allowsPickingMultipleItems = false
        // ピッカーを表示する
        present(picker, animated: true, completion: nil)
        
    }
    
    /// メディアアイテムピッカーでアイテムを選択完了したときに呼び出される
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        
        // プレイヤーを止める
        player.stop()
        
        // 選択した曲情報がmediaItemCollectionに入っているので、これをplayerにセット。
        //player.setQueueWithItemCollection(mediaItemCollection)
        player.setQueue(with: mediaItemCollection)
        
        // 選択した曲から最初の曲の情報を表示
        if let mediaItem = mediaItemCollection.items.first {
            updateSongInformationUI(mediaItem: mediaItem)
        }
        
        // ピッカーを閉じ、破棄する
       // dismissViewControllerAnimated(true, completion: nil)
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    /// 選択がキャンセルされた場合に呼ばれる
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        // ピッカーを閉じ、破棄する
        self.dismiss(animated: true, completion: nil)
    }
    
    /// 曲情報を表示する
    func updateSongInformationUI(mediaItem: MPMediaItem) {
        
        // 曲情報表示
        // (a ?? b は、a != nil ? a! : b を示す演算子です)
        // (aがnilの場合にはbとなります)
        artistLabel.text = mediaItem.artist ?? "不明なアーティスト"
        albumLabel.text = mediaItem.albumTitle ?? "不明なアルバム"
        songLabel.text = mediaItem.title ?? "不明な曲"
        
        // アートワーク表示
        if let artwork = mediaItem.artwork {
            let image = artwork.image(at: imageView.bounds.size)
            imageView.image = image
        } else {
            // アートワークがないとき
            // (今回は灰色表示としました)
            imageView.image = nil
            imageView.backgroundColor = UIColor.gray
        }
        
    }
    
    // 再生ボタンを押した時
    @IBAction func pushPlay(sender: UIButton) {
        if nowPlaying {
            player.pause()
            sender.setTitle("再生", for: .normal)
            nowPlaying = false
        }else{
            player.play()
            sender.setTitle("一時停止", for: .normal)
            nowPlaying = true
        }
    }
    
    /// 再生中の曲が変更になったときに呼ばれる
    func nowPlayingItemChanged(notification: NSNotification) {
        
        if let mediaItem = player.nowPlayingItem {
            updateSongInformationUI(mediaItem: mediaItem)
        }
        
    }
    
    deinit {
        // 再生中アイテム変更に対する監視をはずす
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(self, name: NSNotification.Name.MPMusicPlayerControllerNowPlayingItemDidChange, object: player)
        // ミュージックプレーヤー通知の無効化
        player.endGeneratingPlaybackNotifications()
    }
    
    
}
