//
//  ViewController.swift
//  VoiceRecordingApp
//
//  Created by Abduraxmon on 09/04/23.
//

import UIKit
import Lottie
import AVFoundation

func getDocumentDirectory() -> URL {
    let path = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask)
    return path[0]
}

class ViewController: UIViewController {
    
    private var animationView: LottieAnimationView?
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!

    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var recordingView: UIView!
    @IBOutlet weak var recordingBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpBtns()
        
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission { [unowned self] allowed in
                if allowed {
                    self.loadRecordingUI()
                } else {
                    //failed to record
                }
            }
        } catch {
            
        }
    }
    
    func loadRecordingUI() {
        playBtn.setTitle("", for: .normal)
        playBtn.setImage(UIImage(systemName: "play.fill"), for: .normal)
        recordingBtn.setTitle("", for: .normal)
    }
    
    func setUpBtns() {
        recordingBtn.layer.borderWidth = 10
        recordingBtn.layer.borderColor = UIColor.white.cgColor
        playBtn.layer.borderWidth = 10
        playBtn.layer.borderColor = UIColor.systemGray4.cgColor
    }
    
    func playAnimation() {
        
        let animetionHeight = view.frame.height / 3
        // 2. Start AnimationView with animation name (without extension)
          animationView = .init(name: "97021-recording")
        animationView!.frame = CGRect(x: 0, y: view.frame.height / 2 - animetionHeight / 2, width: view.frame.width, height: animetionHeight)
          // 3. Set animation content mode
          animationView!.contentMode = .scaleAspectFit
          // 4. Set animation loop mode
          animationView!.loopMode = .loop
          // 5. Adjust animation speed
          animationView!.animationSpeed = 0.5
          view.addSubview(animationView!)
          // 6. Play animation
          animationView!.play()
    }


    @IBAction func recordingPressed(_ sender: Any) {
        if recordingBtn.layer.borderWidth == 10 {
            startRecording()
            UIView.animate(withDuration: 0.5) { [self] in
                playBtn.isHidden = true
                playBtn.setImage(UIImage(systemName: "play.fill"), for: .normal)
                recordingBtn.backgroundColor = .white
                recordingBtn.setImage(UIImage(systemName: "pause.fill" ), for: .normal)
                recordingBtn.layer.borderWidth = 15
                playAnimation()
            }
        } else {
            finishRecording(success: true)
            UIView.animate(withDuration: 0.5) { [self] in
                playBtn.isHidden = false
                recordingBtn.backgroundColor = .systemRed
                recordingBtn.setImage(UIImage(), for: .normal)
                recordingBtn.layer.borderWidth = 10
                animationView?.stop()
                animationView?.isHidden = true
            }
        }
    }
    
    
    @IBAction func playBtnPressed(_ sender: Any) {
        if audioPlayer == nil {
            startPlayback()
            playBtn.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            playBtn.backgroundColor = .green
        } else {
            finishPlayback()
            playBtn.setImage(UIImage(systemName: "play.fill"), for: .normal)
            playBtn.backgroundColor = .systemGreen
        }
    }
    
    //MARK: - Recording
    
    func startRecording() {
        let audioFileName = getDocumentDirectory().appendingPathExtension("recording.m4a")
        
        let setting = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFileName, settings: setting)
            audioRecorder.delegate = self
            audioRecorder.record()
        } catch {
            finishRecording(success: false)
        }
    }
    
    func finishRecording(success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil
        
        if success {
            playBtn.isHidden = false
        } else {
            playBtn.isHidden = true
        }
    }
    
    //MARK: - PlayBack
    
    func startPlayback() {
        let audioFileName = getDocumentDirectory().appendingPathExtension("recording.m4a")
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioFileName)
            audioPlayer.delegate = self
            audioPlayer.play()
        } catch {
            playBtn.isHidden = true
        }
    }
    
    func finishPlayback() {
        audioPlayer = nil
    }
}

extension ViewController: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
}

extension ViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        finishPlayback()
    }
}

