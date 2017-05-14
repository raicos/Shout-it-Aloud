//
//  Record.swift
//  Shout-it-Aloud
//
//  Created by k15046kk on 2017/04/29.
//  Copyright © 2017年 army. All rights reserved.
//

import UIKit
import AudioKit
// import AudioUnit
import MediaPlayer
import C4

class Record: UIViewController, MPMediaPickerControllerDelegate, EZAudioFileDelegate {
    
    var fft = [Float](repeating: 0.0, count: 0)
    
    var audioFile:EZAudioFile!
    var audioPlot:EZAudioPlot!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //波形
        self.audioPlot = EZAudioPlot(frame: self.view.frame)
        self.audioPlot.backgroundColor = UIColor.orange
        self.audioPlot.color = UIColor.white
        self.audioPlot.plotType = EZPlotType.buffer
        self.audioPlot.shouldFill = true
        self.audioPlot.shouldMirror = true
        self.audioPlot.shouldOptimizeForRealtimePlot = false
        let fileURL:URL = Bundle.main.url(forResource: "test", withExtension: "m4a")!
        self.openFileWithFilePathURL(filePathURL: fileURL)
        self.view.addSubview(self.audioPlot)
        
    }
    
    //ファイルの読み込みと波形の読み込み
    func openFileWithFilePathURL(filePathURL:URL){
        self.audioFile = EZAudioFile(url: filePathURL)
        self.audioFile.delegate = self
        
        var buffer = self.audioFile.getWaveformData().buffer(forChannel: 0)
        var bufferSize = self.audioFile.getWaveformData().bufferSize
        self.audioPlot.updateBuffer(buffer, withBufferSize: bufferSize)
        
    }
    
    

    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    @IBAction func touch() {
        let fileURL:URL = Bundle.main.url(forResource: "test", withExtension: "m4a")!
        let audioFile = try! AVAudioFile(forReading: fileURL)
        let frameCount = UInt32(audioFile.length)
        print("aa")
        let buffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat, frameCapacity: frameCount)
        do {
            try audioFile.read(into: buffer, frameCount:frameCount)
        } catch {
            
        }
        let log2n = UInt(round(log2(Double(frameCount))))
        print("bb")
        let bufferSizePOT = Int(1 << log2n)
        print("c")
        // Set up the transform
        let fftSetup = vDSP_create_fftsetup(log2n, Int32(kFFTRadix2))
        print("a")
        // create packed real input
        var realp = [Float](repeating: 0, count: bufferSizePOT/2)
        var imagp = [Float](repeating: 0, count: bufferSizePOT/2)
        var output = DSPSplitComplex(realp: &realp, imagp: &imagp)
        let unsafepoint = UnsafeRawPointer(buffer.floatChannelData?.pointee)
        let src = unsafepoint?.bindMemory(to: DSPComplex.self, capacity: bufferSizePOT/2)
        //var src = UnsafeRawPointer(buffer).bindMemory(to: DSPComplex.self, capacity: UInt(bufferSizePOT/2))
        vDSP_ctoz(src!, 2, &output, 1, UInt(bufferSizePOT/2))
        //vDSP_ctoz(UnsafePointer<DSPComplex>((buffer.floatChannelData?.pointee)!), 2, &output, 1, UInt(bufferSizePOT / 2))
        print("b")
        // Do the fast Fourier forward transform, packed input to packed output
        vDSP_fft_zrip(fftSetup!, &output, 1, log2n, Int32(FFT_FORWARD))
        print("c")
        
        // you can calculate magnitude squared here, with care
        // as the first result is wrong! read up on packed formats
        fft = [Float](repeating:0.0, count:Int(bufferSizePOT / 2))
        let bufferOver2: vDSP_Length = vDSP_Length(bufferSizePOT / 2)
        vDSP_zvmags(&output, 1, UnsafeMutablePointer(mutating: fft), 1, bufferOver2)
        
        
        // Release the setup
        vDSP_destroy_fftsetup(fftSetup)
        
        for i in 0...3{
            
            let real = output.realp[Int(i)]
            let imag = output.imagp[Int(i)]
            let distance = sqrt(pow(real, 2) + pow(imag, 2))
            print("[\(i)], \(distance)\n")
            
        }
        
    }
}


