//
//  ViewController.swift
//  EyeTrackingTest1
//
//  Created by Ohshima Labo on 2019/11/19.
//  Copyright © 2019 Ohshima Labo. All rights reserved.
//



import UIKit
import ARKit

class ViewController: UIViewController  {
    // ARSession
    let session = ARSession()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.backgroundColor = UIColor.black
        self.session.delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // "Reset" to run the AR session for the first time.
        resetTracking()
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
