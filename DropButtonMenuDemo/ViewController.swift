//
//  ViewController.swift
//  DropButtonMenuDemo
//
//  Created by 吕俊 on 15/9/29.
//  Copyright © 2015年 Akring. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.lightGrayColor()
        
        let firstArr = ["解决情况最好的建言","我为公司点个赞"];
        let secondArr = ["系统支撑类建言","产品营销类建言","流程规范类建言","终端营销类建言","授权管理类建言","其他类型建言"];
        
        let dataArray = [["123":firstArr],["456":secondArr]];
        
        let menu:DropButtonMenu = DropButtonMenu(org: CGPointMake(0, 20), height: 44)
        menu.dataArray = dataArray
        menu.setUpView()
        
        menu.clickBlock = {(button) -> Void in
            
            let string = button.currentTitle
            
            let alert:UIAlertView = UIAlertView(title: "提示", message: string, delegate: self, cancelButtonTitle: "确定")
            alert.show()
        }
        
        self.view.addSubview(menu)
        self.view.bringSubviewToFront(menu)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}