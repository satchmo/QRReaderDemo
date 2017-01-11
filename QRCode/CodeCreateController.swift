//
//  CodeCreateController.swift
//  QRReaderDemo
//
//  Created by Admins on 2017/1/9.
//  Copyright © 2017年 AppCoda. All rights reserved.
//

import UIKit

class CodeCreateController: UIViewController {
    
    @IBOutlet weak var backButton: UIButton!
    @IBAction func backAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    @IBOutlet weak var codeImageView: UIImageView!
    
    @IBOutlet weak var inputTextView: UITextView!
    
    @IBAction func createAction(_ sender: UIButton) {
        createCode()
    }
    
    var activityView:UIActivityIndicatorView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.bringSubview(toFront:backButton)
        
        // Do any additional setup after loading the view.
    }
    
    private func createCode() {
        inputTextView.resignFirstResponder()
        //设备启动状态提示
        if (activityView == nil)
        {
            self.activityView = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
            
            activityView?.center = view.center
            activityView?.frame.origin.y = self.codeImageView.frame.origin.y - 35
            activityView?.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
            activityView?.color = UIColor.lightGray
            
            self.view.addSubview(activityView!)
//            view.addSubview(qrCoderFrameView!)
            
            
//            let labelReadyRect = CGRect(x: activityView!.frame.origin.x + activityView!.frame.size.width + 10, y: activityView!.frame.origin.y, width: 100, height: 30);
//            //print("%@",NSStringFromCGRect(labelReadyRect))
//            self.labelReadying = UILabel(frame: labelReadyRect)
//            labelReadying?.text = readyStr
//            labelReadying?.backgroundColor = UIColor.clear
//            labelReadying?.textColor = UIColor.white
//            labelReadying?.font = UIFont.systemFont(ofSize: 18.0)
//            addSubview(labelReadying!)
        }
//         view.bringSubview(toFront:activityView!)
         activityView?.startAnimating()

        //创建一个二维码滤镜
        let codeFilter = CIFilter(name:"CIQRCodeGenerator")
        
        //重新设置滤镜默认值
        codeFilter?.setDefaults()

        //通过 KVC 设置滤镜的输入文本内容
        let data = inputTextView.text.data(using: String.Encoding.utf8)
        codeFilter?.setValue(data, forKey: "inputMessage")
        
        //从滤镜里面取出结果图片
        // 取出的图片是CIImage, 大小是23* 23 需要单独处理
        guard let outputImage = codeFilter?.outputImage  else{
            return
        }
        
        // 图片处理，使用这种方式把图片做放大处理, 保证不失真
        let transform = CGAffineTransform(scaleX: 5, y: 5)
        let resultImage = outputImage.applying(transform)
        
        //将CIImage 转换为UIImage
        let image = UIImage(ciImage:resultImage)
         print(image.size)
        
        if activityView != nil
        {
            activityView?.stopAnimating()
            activityView?.removeFromSuperview()
            
            activityView = nil
            
        }
        // 显示结果
        codeImageView.image = image
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
