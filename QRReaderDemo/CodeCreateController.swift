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
    override func viewDidLoad() {
        super.viewDidLoad()
        view.bringSubview(toFront:backButton)
        createCode()
        // Do any additional setup after loading the view.
    }
    
    private func createCode() {
        
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
        
        // 显示结果
        codeImageView.image = image
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
