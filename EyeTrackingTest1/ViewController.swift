//
//  ViewController.swift
//  EyeTrackingTest1
//
//  Created by Ohshima Labo on 2019/11/19.
//  Copyright © 2019 Ohshima Labo. All rights reserved.
//



import UIKit
import ARKit
import AVFoundation
import Photos

class ViewController: UIViewController,AVCaptureFileOutputRecordingDelegate  {
    
    let fileOutput = AVCaptureMovieFileOutput()
    var recordButton: UIButton!
    
    // ARSession
    let session = ARSession()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.session.delegate = self
        self.setUpCamera()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // "Reset" to run the AR session for the first time.
        
    }
    
    func setUpCamera() {
        let captureSession: AVCaptureSession = AVCaptureSession()
        let videoDevice: AVCaptureDevice? = AVCaptureDevice.default(for: AVMediaType.video)
        let audioDevice: AVCaptureDevice? = AVCaptureDevice.default(for: AVMediaType.audio)
        // video input setting
                let videoInput: AVCaptureDeviceInput = try! AVCaptureDeviceInput(device: videoDevice!)
                captureSession.addInput(videoInput)
                
                // audio input setting
                let audioInput = try! AVCaptureDeviceInput(device: audioDevice!)
                captureSession.addInput(audioInput)
                
                //出力をsessionに追加
                captureSession.addOutput(fileOutput)
                
                captureSession.startRunning()
                
        //        // video preview layer
                let videoLayer : AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                videoLayer.frame = self.view.bounds
                videoLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
                self.view.layer.addSublayer(videoLayer)
                
                // recording button
                self.recordButton = UIButton(frame: CGRect(x: 0, y: 0, width: 120, height: 50))
                self.recordButton.backgroundColor = UIColor.gray
                self.recordButton.layer.masksToBounds = true
                self.recordButton.setTitle("Record", for: .normal)
                self.recordButton.layer.cornerRadius = 20
                self.recordButton.layer.position = CGPoint(x: self.view.bounds.width / 2, y:self.view.bounds.height - 100)
                self.recordButton.addTarget(self, action: #selector(self.onClickRecordButton(sender:)), for: .touchUpInside)
                self.view.addSubview(recordButton)
    }
    
    @objc func onClickRecordButton(sender: UIButton) {
            if self.fileOutput.isRecording {
                // stop recording
                fileOutput.stopRecording()
                
                self.recordButton.backgroundColor = .gray
                self.recordButton.setTitle("Record", for: .normal)
            } else {
                // start recording
                let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
                let documentsDirectory = paths[0] as String
                let filePath : String? = "\(documentsDirectory)/temp.mp4"
                let fileURL : NSURL = NSURL(fileURLWithPath: filePath!)
                
                
                
                fileOutput.startRecording(to: fileURL as URL, recordingDelegate: self)
    //            let tempDirectory: URL = URL(fileURLWithPath: NSTemporaryDirectory())
    //            let fileURL: URL = tempDirectory.appendingPathComponent("mytemp1.mov")
    //            fileOutput.startRecording(to: fileURL, recordingDelegate: self)
                
                self.recordButton.backgroundColor = .red
                self.recordButton.setTitle("●Recording", for: .normal)
                self.resetTracking()
            }
    }
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        // ライブラリへ保存
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputFileURL)
        }) { completed, error in
            if completed {
                print("Video is saved!")
            }
        }
    }
}

//MARK:- ARSession
extension ViewController: ARSessionDelegate {

    func resetTracking() {
        guard ARFaceTrackingConfiguration.isSupported else {
            print("Not supported ARFaceTracking process.")
            
            return
        }
        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        self.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }

    //MARK:- ARSessionDelegate
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        frame.anchors.forEach { anchor in
            guard #available(iOS 12.0, *), let faceAnchor = anchor as? ARFaceAnchor else { return }

            // FaceAnchorから左、右目の位置や向きが取得可能。
            let left = faceAnchor.leftEyeTransform
            print("left:\(left)")
            let right = faceAnchor.rightEyeTransform
            print("right:\(right)")
        }
    }

    func session(_ session: ARSession, didFailWithError error: Error) {}
}


