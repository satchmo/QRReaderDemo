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
    
    @IBOutlet weak var backButton: UIButton!
    @IBAction func backAction(_ sender: UIButton) {
         dismiss(animated: true, completion: nil)
    }
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
            
            // Move the message label to the top view
            view.bringSubview(toFront:messageLabel)
            view.bringSubview(toFront:backButton)
            
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
    
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        removeQRCodeFrame()
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
                drawCodeFrame(codeObject: barCodeObject)
                print("stringValue=\(metadataObj.stringValue)")
            }
        }
        
        
    }
    
    func drawCodeFrame(codeObject: AVMetadataMachineReadableCodeObject) {
        //创建边框图层
        let frameShapeLayer = CAShapeLayer()
        frameShapeLayer.fillColor = UIColor.clear.cgColor
        frameShapeLayer.strokeColor = UIColor.red.cgColor
        frameShapeLayer.lineWidth = 6
        
        //为图层设置形状的路径用以展示
        let corners = codeObject.corners
        let path = UIBezierPath()
        var index = 0
        for corner in corners! {
            let point = CGPoint.zero
            CGPoint.init(dictionaryRepresentation: corner as! CFDictionary)
//            CGPointMakeWithDictionaryRepresentation((corner as! CFDictionary), &point)
            
            // 如果第一个点, 移动路径过去, 当做起点
            if index == 0 {
                path.move(to: point)
            }else {
                path.addLine(to: point)
            }
            // 如果不是第一个点, 添加一个线到这个点
            
            index += 1
            
        }
        
        path.close()
        // 根据四个角对应的坐标, 转换成为一个path
        
        // 给layer 的path 进行赋值
        frameShapeLayer.path = path.cgPath
        
        // 添加形状图层到需要展示的图层上面
        videoPreviewLayer?.addSublayer(frameShapeLayer)
    }
    
    func removeQRCodeFrame(){
        
        guard let subLayers = videoPreviewLayer?.sublayers else {
            return
        }
        for subLayer in subLayers {
            if subLayer is CAShapeLayer {
                subLayer.removeFromSuperlayer()
            }

        }
        
    }
    
    
    
}


