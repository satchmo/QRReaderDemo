//
//  ViewController.swift
//  QRReaderDemo
//
//  Created by Simon Ng on 23/11/14.
//  Copyright (c) 2014 AppCoda. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController,AVCaptureMetadataOutputObjectsDelegate {
    
    @IBOutlet weak var messageLabel:UILabel!
    
    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var qrCoderFrameView:UIView?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
//        var error:NSError?
        do {
            //        let input: AnyObject!  = AVCaptureDeviceInput.init(device: captureDevice)

            let input: AnyObject!  = try AVCaptureDeviceInput(device: captureDevice) as AVCaptureDeviceInput
            captureSession = AVCaptureSession()
            captureSession?.addInput(input as! AVCaptureInput!)
            
        } catch let error as NSError {
            print(error)
            return
        }

        // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
        let captureMetadataOutput = AVCaptureMetadataOutput()
        captureSession?.addOutput(captureMetadataOutput)
        
        // Set delegate and use the default dispatch queue to execute the call back
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        captureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        
        // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session:captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer!)
        
        // Start video capture.
        captureSession?.startRunning()
        
        // Move the message label to the top view
        view.bringSubview(toFront:messageLabel)
        
        // Initialize QR Code Frame to highlight the QR code
        qrCoderFrameView = UIView()
        qrCoderFrameView?.layer.borderColor = UIColor.green.cgColor
        qrCoderFrameView?.layer.borderWidth = 2
        view.addSubview(qrCoderFrameView!)
        view.bringSubview(toFront: qrCoderFrameView!)

    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects == nil || metadataObjects.count == 0 {
            qrCoderFrameView?.frame = CGRect.zero
            messageLabel.text = "NO QR code is detected"
            return
        }
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        if metadataObj.type == AVMetadataObjectTypeQRCode {
            // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
             let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj
                    as AVMetadataMachineReadableCodeObject) as!
            AVMetadataMachineReadableCodeObject
            qrCoderFrameView?.frame = barCodeObject.bounds;
            
            if metadataObj.stringValue != nil {
                messageLabel.text = metadataObj.stringValue
                print("stringValue=\(metadataObj.stringValue)")
            }
        }

        
    }
//    (<#parameters#>) -> <#return type#> {
//        <#function body#>
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

