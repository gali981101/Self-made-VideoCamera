//
//  ViewController.swift
//  SelfmadeVideoCam
//
//  Created by Terry Jason on 2024/1/4.
//

import UIKit
import AVFoundation
import AVKit

class VideoCamViewController: UIViewController {
    
    let captureSession = AVCaptureSession()
    
    var currentDevice: AVCaptureDevice!
    var videoFileOutput: AVCaptureMovieFileOutput!
    
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    
    var isRecording: Bool = false
    
    // MARK: - @IBOulet
    
    @IBOutlet var cameraButton: UIButton!
    
}

// MARK: - Life cycle

extension VideoCamViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
}

// MARK: - @IBAction

extension VideoCamViewController {
    
    @IBAction func capture(sender: AnyObject) {
        
        if !isRecording {
            isRecording = true
            
            UIView.animate(withDuration: 0.5, delay: 0.0, options: [.repeat, .autoreverse, .allowUserInteraction], animations: { () -> Void in
                self.cameraButton.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            }, completion: nil)
            
            let outputPath = NSTemporaryDirectory() + "output.mov"
            let outputFileURL = URL(fileURLWithPath: outputPath)
            videoFileOutput?.startRecording(to: outputFileURL, recordingDelegate: self)
        } else {
            isRecording = false
            
            UIView.animate(withDuration: 0.5, delay: 1.0, options: [], animations: { () -> Void in
                self.cameraButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }, completion: nil)
            cameraButton.layer.removeAllAnimations()
            videoFileOutput?.stopRecording()
        }
        
    }
    
    @IBAction func unwindToCamera(segue:UIStoryboardSegue) {
    }
    
}

// MARK: - Set Up

extension VideoCamViewController {
    
    private func configure() {
        captureSession.sessionPreset = AVCaptureSession.Preset.high
        
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else { fatalError("Failed to get the camera device") }
        currentDevice = device
        
        guard let captureDeviceInput = try? AVCaptureDeviceInput(device: currentDevice) else { return }
        
        videoFileOutput = AVCaptureMovieFileOutput()
        
        captureSession.addInput(captureDeviceInput)
        captureSession.addOutput(videoFileOutput)
        
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(cameraPreviewLayer!)
        
        cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        cameraPreviewLayer?.frame = view.layer.frame
        
        view.bringSubviewToFront(cameraButton)
        
        DispatchQueue.global().async {
            self.captureSession.startRunning()
        }
    }
    
}

// MARK: - Prepare Segue

extension VideoCamViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "playVideo" {
            let destinationVC = segue.destination as! AVPlayerViewController
            
            let videoFileURL = sender as! URL
            destinationVC.player = AVPlayer(url: videoFileURL)
        }
    }
    
}

// MARK: - Helper Methods

extension VideoCamViewController {
}

// MARK: - AVCaptureFileOutputRecordingDelegate

extension VideoCamViewController: AVCaptureFileOutputRecordingDelegate {
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        guard error == nil else { fatalError(error?.localizedDescription ?? "擷取資料至影片檔中發生錯誤") }
        performSegue(withIdentifier: "playVideo", sender: outputFileURL)
    }
    
}
