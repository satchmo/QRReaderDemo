//
//  CodeScannerController.swift
//  QRReaderDemo
//
//  Created by Admins on 2017/1/9.
//  Copyright © 2017年 AppCoda. All rights reserved.
//

import UIKit
import AVFoundation

class CodeScannerController: UIViewController,AVCaptureMetadataOutputObjectsDelegate {
    
    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var qrCoderFrameView:UIView?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backButton:UIButton = UIButton(frame:CGRect(x:24, y:20, width:45, height:45))
        backButton.setTitle("返回", for:.normal)
        backButton.setTitleColor(UIColor.black, for: .normal) //普通状态下文字的颜色
        view.addSubview(backButton)
        backButton.addTarget(self, action:#selector(backAction(_:)), for: .touchUpInside)
        view.bringSubview(toFront:backButton)
        

        
        let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        do {
            
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession = AVCaptureSession()
            captureSession?.addInput(input)
            
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
            
            // Initialize QR Code Frame to highlight the QR code
            qrCoderFrameView = UIView()
            qrCoderFrameView?.layer.borderColor = UIColor.green.cgColor
            qrCoderFrameView?.layer.borderWidth = 2
            view.addSubview(qrCoderFrameView!)
            view.bringSubview(toFront: qrCoderFrameView!)
            
                      
        } catch let error as NSError {
            print(error)
            return
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func backAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects == nil || metadataObjects.count == 0 {
            qrCoderFrameView?.frame = CGRect.zero
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
                showMessage(title: "提示", meaasge: metadataObj.stringValue)
                if (captureSession?.isRunning)! {
                    captureSession?.stopRunning()
                }
                print("stringValue=\(metadataObj.stringValue)")
            }
        }
        
        
    }
    
    func showMessage(title:String?, meaasge:String?) {
        let alertController = UIAlertController(title: title, message:meaasge, preferredStyle: UIAlertControllerStyle.alert)
        let alertAction = UIAlertAction(title: title, style: UIAlertActionStyle.default) {
            (alertAction) in
            print("点击了确定")
            if !(self.captureSession?.isRunning)! {
                self.qrCoderFrameView?.frame = CGRect.zero
                self.captureSession?.startRunning()
            }


        }
        
        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: nil)

    }
    
    
}


