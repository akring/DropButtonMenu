//
//  DropButtonMenu.swift
//  DropButtonMenuDemo
//
//  Created by 吕俊 on 15/9/29.
//  Copyright © 2015年 Akring. All rights reserved.
//

import UIKit
import CoreGraphics
import QuartzCore

// MARK: - 转换RGB颜色
func getColor(hexColor:NSString) ->UIColor{
    
    var redInt:UInt32 = 0
    var greenInt:UInt32 = 0
    var blueInt:UInt32 = 0
    var rangeNSRange:NSRange! = NSMakeRange(0, 0)
    rangeNSRange.length = 2
    
    //取红色值
    rangeNSRange.location = 0
    NSScanner(string: hexColor.substringWithRange(rangeNSRange)).scanHexInt(&redInt)
    
    //取绿色值
    rangeNSRange.location = 2
    NSScanner(string: hexColor.substringWithRange(rangeNSRange)).scanHexInt(&greenInt)
    
    //取蓝色值
    rangeNSRange.location = 4
    NSScanner(string: hexColor.substringWithRange(rangeNSRange)).scanHexInt(&blueInt)
    
    let red = CGFloat(redInt)/255.0
    let green = CGFloat(greenInt)/255.0
    let blue = CGFloat(blueInt)/255.0
    let color = UIColor(red: red, green: green, blue: blue, alpha: 1)
    
    return color
}


typealias ClickBlock = (button:UIButton) -> Void /**< 点击回调Block */

class DropButtonMenu: UIView,UITableViewDataSource,UITableViewDelegate {

    let indicatorColor:UIColor
    let textColor:UIColor        /**< 文字颜色 */
    let separatorColor:UIColor   /**< 分隔符颜色 */
    let iconImage:UIImage? = nil        /**< 按钮图标图片 */
    var clickBlock:ClickBlock? = nil    /**< 点击回调Block */
    var dataArray:NSArray = []          /**< 数据源 */
    
    let SectionHeaderHight:CGFloat = 15  /**< 标题头高度 */
    
    var currentSelectedMenudIndex:NSInteger = 0
    var show:Bool = false
    var numOfMenu:NSInteger = 1
    var originPoint:CGPoint = CGPointMake(0, 0)
    var backGroundView:UIView = UIView()
    var tableView:UITableView = UITableView()
    var maskLine:UIView = UIView()
    var blockIV:UIImageView = UIImageView()
    
    var titles:NSArray = []
    var indicators:NSArray = []
    var bgLayers:NSArray = []
    
    // MARK: - 设置页面
    
    func setUpView(){
        
        numOfMenu = 1;
        
        let textLayerInterval = self.frame.size.width/CGFloat((numOfMenu * 2))
        let separatorLineInterval = self.frame.size.width/CGFloat((numOfMenu))
        let bgLayerInterval = self.frame.size.width/CGFloat((numOfMenu))
        
        let tempTitles = NSMutableArray(capacity: numOfMenu)
        let tempIndicators = NSMutableArray(capacity: numOfMenu)
        let tempBgLayers = NSMutableArray(capacity: numOfMenu)
        
        for index in 0..<numOfMenu {
            
            let i = Float(index)
            //bgLayer
            let bgLayerPosition = CGPointMake(CGFloat(i+0.5)*bgLayerInterval, self.frame.size.height/2)
            
            let bgLayer = self.createBgLayerWithColorAndPosition(UIColor.whiteColor(), position: bgLayerPosition)
            self.layer.addSublayer(bgLayer)
            tempBgLayers.addObject(bgLayer)
            //title
            let titlePosition = CGPointMake( CGFloat(i * 2 + 1) * textLayerInterval - 8, self.frame.size.height / 2);
            let dic = dataArray.firstObject as! NSDictionary
            let arr = dic[dic.allKeys.first as! String] as! NSArray
            let str = arr.firstObject as! String
            let title = self.createTextLayerWithNSStringAndColorAndPosition(str, color: self.textColor, point: titlePosition)
            self.layer.addSublayer(title)
            tempTitles.addObject(title)
            //indicator
            let indicator = self.createIndicatorWithColorAndPostion(self.indicatorColor, point: CGPointMake(titlePosition.x + title.bounds.size.width / 2 + 8, self.frame.size.height / 2))
            self.layer.addSublayer(indicator)
            tempIndicators.addObject(indicator)
            //separator
            if index != numOfMenu-1{
                
                let separatorPosition = CGPointMake(CGFloat(i + 1) * separatorLineInterval, self.frame.size.height/2);
                let separator = self.createSeparatorLineWithColorAndPostion(self.separatorColor, point: separatorPosition)
                self.layer.addSublayer(separator)
            }
        }
        
        titles = tempTitles.copy() as! NSArray
        indicators = tempIndicators.copy() as! NSArray
        bgLayers = tempBgLayers.copy() as! NSArray
        
        //add block Icon
        let screenSize = UIScreen.mainScreen().bounds.size
        blockIV = UIImageView(frame: CGRectMake(screenSize.width-44, 0, 44, 43.5))
        
        if iconImage != nil{
            
            blockIV.image = iconImage
        }
        
        self.addSubview(blockIV)
    }
    
    // MARK: - Init Method
    
    init(org:CGPoint,height:CGFloat){
        
        let screenSize = UIScreen.mainScreen().bounds.size
        
        indicatorColor = getColor("177EF3")
        textColor = getColor("177EF3")
        separatorColor = UIColor(white: 0.8, alpha: 1.0)
        
        super.init(frame: CGRectMake(0, org.y, screenSize.width, height))
        
        originPoint = org
        currentSelectedMenudIndex = -1
        show = false
        
        //tableView Init
        tableView = UITableView(frame: CGRectMake(org.x, self.frame.origin.y+self.frame.size.height, self.frame.size.width, 0), style: UITableViewStyle.Plain)
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        tableView.backgroundColor = getColor("ECECEC")
        tableView.layer.masksToBounds = true
        tableView.layer.borderWidth = 1.0
        tableView.layer.borderColor = UIColor.lightGrayColor().CGColor
        tableView.rowHeight = 60
        tableView.dataSource = self
        tableView.delegate = self
        
        //self tapped
        self.backgroundColor = UIColor.whiteColor()
        let tapGesture = UITapGestureRecognizer(target: self, action: "menuTapped:")
        self.addGestureRecognizer(tapGesture)
        
        //background init and tapped
        backGroundView = UIView(frame: CGRectMake(org.x, org.y, screenSize.width, screenSize.height))
        backGroundView.backgroundColor = UIColor(white: 0, alpha: 0)
        backGroundView.opaque = false
        let gesture = UITapGestureRecognizer(target: self, action: "backgroundTapped:")
        backGroundView.addGestureRecognizer(gesture)
        
        //add bottom shadow
        let bottomShadow = UIView(frame: CGRectMake(0, self.frame.size.height-0.5, screenSize.width, 0.5))
        bottomShadow.backgroundColor = UIColor.lightGrayColor()
        self.addSubview(bottomShadow)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - init support
    /**
    创建背景
    
    - parameter color:    颜色
    - parameter position: 位置
    
    - returns: 背景layer
    */
    func createBgLayerWithColorAndPosition(color:UIColor,position:CGPoint)->CALayer{
        
        let layer = CALayer()
        
        layer.position = position
        layer.bounds = CGRectMake(0, 0, self.frame.size.width/CGFloat(self.numOfMenu), self.frame.size.height-1)
        layer.backgroundColor = color.CGColor
        
        return layer
    }
    /**
    创建指示箭头
    
    - parameter color: 颜色
    - parameter point: 位置
    
    - returns: 指示箭头layer
    */
    func createIndicatorWithColorAndPostion(color:UIColor,point:CGPoint)->CAShapeLayer{
        
        let layer = CAShapeLayer()
        
        let path = UIBezierPath()
        path.moveToPoint(CGPointMake(0, 0))
        path.addLineToPoint(CGPointMake(8, 0))
        path.addLineToPoint(CGPointMake(4, 5))
        path.closePath()
        
        layer.path = path.CGPath
        layer.lineWidth = 1.0
        layer.fillColor = color.CGColor
        
        let bound: CGPathRef = CGPathCreateCopyByStrokingPath(layer.path,nil,layer.lineWidth,CGLineCap.Round,CGLineJoin.Miter,layer.miterLimit)!
        layer.bounds = CGPathGetBoundingBox(bound)
        layer.position = point
        
        return layer
    }
    /**
    创建分割线
    
    - parameter color: 颜色
    - parameter point: 位置
    
    - returns: 分割线的layer
    */
    func createSeparatorLineWithColorAndPostion(color:UIColor,point:CGPoint)->CAShapeLayer{
        
        let layer = CAShapeLayer()
        
        let path = UIBezierPath()
        path.moveToPoint(CGPointMake(160, 0))
        path.addLineToPoint(CGPointMake(160, self.frame.size.height))
        
        layer.path = path.CGPath
        layer.lineWidth = 1.0
        layer.fillColor = color.CGColor
        
        let bound: CGPathRef = CGPathCreateCopyByStrokingPath(layer.path,nil,layer.lineWidth,CGLineCap.Round,CGLineJoin.Miter,layer.miterLimit)!
        layer.bounds = CGPathGetBoundingBox(bound)
        layer.position = point
        
        return layer
    }
    /**
    创建遮罩层
    
    - parameter frame: 遮罩frame
    */
    func createMaskLineWithFrame(frame:CGRect){
        
        maskLine = UIView(frame: frame)
        maskLine.backgroundColor = UIColor.whiteColor()
        self.addSubview(maskLine)
        self.bringSubviewToFront(maskLine)
    }
    /**
    创建文字层
    
    - parameter string: 文字字符串
    - parameter color:  颜色
    - parameter point:  位置
    
    - returns: 文字层
    */
    func createTextLayerWithNSStringAndColorAndPosition(string:NSString,color:UIColor,point:CGPoint)->CATextLayer{
        
        let size = self.calculateTitleSizeWithString(string)
        
        let layer = CATextLayer()
        let sizeWidth = (size.width < (self.frame.size.width / CGFloat(numOfMenu)) - 25) ? size.width : self.frame.size.width / CGFloat(numOfMenu) - 25;
        layer.bounds = CGRectMake(0, 0, sizeWidth, size.height)
        layer.string = string
        layer.fontSize = 14.0
        layer.alignmentMode = kCAAlignmentCenter
        layer.foregroundColor = color.CGColor
        
        layer.contentsScale = UIScreen.mainScreen().scale
        layer.position = point
        
        return layer
    }
    /**
    根据字符串计算标题尺寸
    
    - parameter string: 标题字符串
    
    - returns: 标题尺寸
    */
    func calculateTitleSizeWithString(string:NSString)->CGSize{
        
        let fontSize:CGFloat = 14.0
        
        let dic = [NSFontAttributeName:UIFont.systemFontOfSize(fontSize)]
        
        let options = unsafeBitCast(NSStringDrawingOptions.TruncatesLastVisibleLine.rawValue |
            NSStringDrawingOptions.UsesLineFragmentOrigin.rawValue |
                NSStringDrawingOptions.UsesFontLeading.rawValue,
            NSStringDrawingOptions.self)
        
        let size = string.boundingRectWithSize(CGSizeMake(280, 0), options: options, attributes: dic, context: nil).size
        
        
        return size
    }
    
    // MARK: - 手势处理
    
    func menuTapped(tapGes:UITapGestureRecognizer){
        
        maskLine.removeFromSuperview()
        
        let touchPoint = tapGes.locationInView(self)
        
        //calculate index
        let tapIndex = touchPoint.x/(self.frame.size.width/CGFloat(numOfMenu))
        
        for i in 0..<numOfMenu{
            
            if i != Int(tapIndex){
                
                
                self.animateIndicator(indicators[i] as! CAShapeLayer, forward: false, complete: { () -> Void in
                    
                    self.animateTitle(self.titles[i] as! CATextLayer, show: false, complete: { () -> Void in
                        
                        
                    })
                })
            }
        }
        
        //遮盖住当前分割线
        
        let height:CGFloat = 2.0
        let width:CGFloat = CGRectGetWidth(self.frame)/CGFloat(numOfMenu)-1
        var x:CGFloat = tapIndex * width
        if tapIndex != 0{
            x = tapIndex * width + 1
        }
        let y = self.frame.size.height-2
        
        if NSInteger(tapIndex) == currentSelectedMenudIndex && show == true{
            
            self.animateChain(indicators[currentSelectedMenudIndex] as! CAShapeLayer, background: backGroundView, tableView: tableView, title: titles[currentSelectedMenudIndex] as! CATextLayer, forward: false, complete: { () -> Void in
                
                self.currentSelectedMenudIndex = NSInteger(tapIndex)
                self.show = false
            })
        }
        else{
            
            self.currentSelectedMenudIndex = NSInteger(tapIndex)
            tableView.reloadData()
            self.createMaskLineWithFrame(CGRectMake(x, y, width, height))
            self.animateChain(indicators[NSInteger(tapIndex)] as! CAShapeLayer, background: backGroundView, tableView: tableView, title: titles[NSInteger(tapIndex)] as! CATextLayer, forward: true, complete: { () -> Void in
                
                self.show = true
            })
            
            let layer = self.bgLayers[NSInteger(tapIndex)] as! CALayer
            layer.backgroundColor = UIColor.whiteColor().CGColor
        }
    }
    
    func backgroundTapped(tapGes:UITapGestureRecognizer){
        
        maskLine .removeFromSuperview()
        
        self.animateChain(indicators[currentSelectedMenudIndex] as! CAShapeLayer, background: backGroundView, tableView: tableView, title: titles[currentSelectedMenudIndex] as! CATextLayer, forward: false, complete: { () -> Void in
            
            self.show = false
        })
        
        let layer = self.bgLayers[NSInteger(currentSelectedMenudIndex)] as! CALayer
        layer.backgroundColor = UIColor.whiteColor().CGColor
    }
    
    // MARK: - 动画效果
    /**
    箭头动画
    
    - parameter indicator: 箭头
    - parameter forward:   是否向下
    - parameter complete:  完成回调Block
    */
    func animateIndicator(indicator:CAShapeLayer,forward:Bool,complete:() -> Void){
        
        //箭头颜色
        indicator.fillColor = forward ? getColor("177EF3").CGColor:getColor("ECECEC").CGColor
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.25)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(controlPoints: 0.4, 0.0, 0.2, 1.0))
        
        let anim = CAKeyframeAnimation(keyPath: "transform.rotation")
        anim.values = forward ? [ 0, (M_PI) ] : [ (M_PI), 0 ];
        
        if !anim.removedOnCompletion{
            
            indicator.addAnimation(anim, forKey: anim.keyPath)
        }else{
            indicator.addAnimation(anim, forKey: anim.keyPath)
            indicator.setValue(anim.values?.last, forKeyPath: anim.keyPath!)
        }
        
        CATransaction.commit()
        
        complete()
    }
    /**
    背景动画
    
    - parameter view:     背景
    - parameter show:     展示状态
    - parameter complete: 完成回调Block
    */
    func animateBackGroundView(view:UIView,show:Bool,complete:()->Void){
        
        if show{
            
            self.superview?.addSubview(view)
            view.superview?.addSubview(self)
            
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                
                view.backgroundColor = UIColor(white: 0.0, alpha: 0.3)
            })
        }
        else{
            
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                
                view.backgroundColor = UIColor(white: 0.0, alpha: 0.0)
                
                }, completion: { (Bool) -> Void in
                    
                    view .removeFromSuperview()
            })
        }
        
        complete()
    }
    /**
    TableView动画
    
    - parameter tableView: TableView
    - parameter show:      是否显示
    - parameter complete:  完成回调
    */
    func animateTableView(tableView:UITableView,show:Bool,complete:()->Void){
        
        if show{
            
            tableView.frame = CGRectMake(0, self.frame.origin.y+self.frame.size.height, self.frame.size.width, 0)
            self.superview?.addSubview(tableView)
            
            let section = tableView.numberOfSections
            var rows = 0
            
            for i in 0..<section{
                
                rows = rows + tableView.numberOfRowsInSection(i)
            }
            
            var tableViewHeight:CGFloat = 0
            
            if rows>5{
                
                tableViewHeight = (CGFloat(5) * tableView.rowHeight)+CGFloat(CGFloat(section) * SectionHeaderHight)+1
            }else{
                tableViewHeight = (CGFloat(rows) * tableView.rowHeight)+CGFloat(CGFloat(section) * SectionHeaderHight)+1
            }
            
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                
                tableView.frame = CGRectMake(0, self.frame.origin.y + self.frame.size.height, self.frame.size.width, tableViewHeight+3)
            })
        }
        else{
            
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                
                tableView.frame = CGRectMake(0, self.frame.origin.y + self.frame.size.height, self.frame.size.width, 0)
                
                }, completion: { (Bool) -> Void in
                    
                    tableView.removeFromSuperview()
            })
        }
        
        complete()
    }
    /**
    标题动画
    
    - parameter title:    标题
    - parameter show:     是否显示
    - parameter complete: 完成回调
    */
    func animateTitle(title:CATextLayer,show:Bool,complete:()->Void){
        
        title.foregroundColor = show ? getColor("177EF3").CGColor : getColor("177EF3").CGColor
        
        let size = self.calculateTitleSizeWithString(String(title.string))
        let sizeWidth = (size.width < (self.frame.size.width / CGFloat(numOfMenu)) - 25) ? size.width : self.frame.size.width / CGFloat(numOfMenu) - 25;
        title.bounds = CGRectMake(0, 0, sizeWidth, size.height)
        complete()
    }
    /**
    触发动画链
    
    - parameter indicator:  箭头
    - parameter background: 背景
    - parameter tableView:  TableView
    - parameter title:      标题
    - parameter forward:    方向
    - parameter complete:   完成回调
    */
    func animateChain(indicator:CAShapeLayer,background:UIView,tableView:UITableView,title:CATextLayer,forward:Bool,complete:()->Void){
        
        self.animateIndicator(indicator, forward: forward) { () -> Void in
            
            self.animateTitle(title, show: forward, complete: { () -> Void in
                
                self.animateBackGroundView(background, show: forward, complete: { () -> Void in
                    
                    self.animateTableView(tableView, show: forward, complete: { () -> Void in
                        
                    })
                })
            })
        }
        
        complete()
    }
    
    // MARK: - TableView DataSource
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return SectionHeaderHight
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let bgView = UIView(frame: CGRectMake(0, 0, CGRectGetWidth(self.frame), 15))
        bgView.backgroundColor = getColor("ECECEC")
        
        let titleLabel = UILabel(frame: CGRectMake(10, 0, CGRectGetWidth(bgView.frame), CGRectGetHeight(bgView.frame)))
        titleLabel.textColor = UIColor.darkGrayColor()
        titleLabel.font = UIFont.systemFontOfSize(13)
        titleLabel.textAlignment = NSTextAlignment.Left
        
        if dataArray.count != 0{
            
            let dic = dataArray[section] as! NSDictionary
            let title = dic.allKeys.first as! String
            titleLabel.text = title
        }
        bgView.addSubview(titleLabel)
        
        return bgView
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        if dataArray.count != 0{
            return dataArray.count
        }
        else{
            return 0
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if dataArray.count != 0{
            let dic = dataArray[section] as! NSDictionary
            let key = dic.allKeys.first as! String
            let arr = dic[key] as! NSArray
            
            if arr.count > 0{
                
                if arr.count%2==0{
                    return  arr.count/2
                }else{
                    return (arr.count+1)/2
                }
            }else{
                return 0
            }
        }
        else{
            return 0
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return 60
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let identifier: String = "DropDownMenuCell"
        var cell:UITableViewCell? = tableView.dequeueReusableCellWithIdentifier(identifier)
        
        if cell == nil{
            
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: identifier)
            
            let width = CGRectGetWidth(self.frame)/2-31
            
            let leftButton = UIButton(frame: CGRectMake(27, 10, width, 40))
            leftButton.tag = 1
            leftButton.backgroundColor = getColor("1194f6")
            leftButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            leftButton.layer.masksToBounds = true
            leftButton.layer.cornerRadius = 5.0;
            leftButton.titleLabel?.font = UIFont.systemFontOfSize(15)
            leftButton.addTarget(self, action: "ButtonClicked:", forControlEvents: UIControlEvents.TouchUpInside)
            cell?.contentView.addSubview(leftButton)
            
            let rightButton = UIButton(frame: CGRectMake(CGRectGetMaxX(leftButton.frame)+8, 10, width, 40))
            rightButton.tag = 2
            rightButton.backgroundColor = getColor("1194f6")
            rightButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            rightButton.layer.masksToBounds = true
            rightButton.layer.cornerRadius = 5.0;
            rightButton.titleLabel?.font = UIFont.systemFontOfSize(15)
            rightButton.addTarget(self, action: "ButtonClicked:", forControlEvents: UIControlEvents.TouchUpInside)
            cell?.contentView.addSubview(rightButton)
        }
        
        let leftButton = cell?.viewWithTag(1) as! UIButton
        let rightButton = cell?.viewWithTag(2) as! UIButton
        
        if dataArray.count != 0{
            
            let dic = dataArray[indexPath.section] as! NSDictionary
            let key = dic.allKeys.first as! String
            let arr = dic[key] as! NSArray
            
            let leftNum = indexPath.row*2
            let rightNum = leftNum + 1
            
            let leftString = arr[leftNum] as! String
            leftButton.setTitle(leftString, forState: UIControlState.Normal)
            
            if arr.count <= rightNum{
                
                rightButton.hidden = true
                rightButton.setTitle("", forState: UIControlState.Normal)
            }
            else{
                
                rightButton.hidden = false
                let rightString = arr[rightNum] as! String
                rightButton.setTitle(rightString, forState: UIControlState.Normal)
            }
        }
        
        cell?.backgroundColor = UIColor.clearColor()
        cell?.textLabel?.font = UIFont.systemFontOfSize(14)
        cell?.separatorInset = UIEdgeInsetsZero
        cell?.selectionStyle = UITableViewCellSelectionStyle.None
        
        return cell!
    }
    
    // MARK: - TableView Delegate
    
    func confiMenuWithTitle(titleString:NSString){
        
        let title = titles[currentSelectedMenudIndex] as! CATextLayer
        title.string = titleString
        
        self.animateChain(indicators[currentSelectedMenudIndex] as! CAShapeLayer, background: backGroundView, tableView: tableView, title: titles[currentSelectedMenudIndex] as! CATextLayer, forward: false) { () -> Void in
            
            self.show = false
        };
        
        let layer = self.bgLayers[currentSelectedMenudIndex] as! CALayer
        layer.backgroundColor = UIColor.whiteColor().CGColor
        
        let indicator = indicators[currentSelectedMenudIndex] as! CAShapeLayer
        indicator.position = CGPointMake(title.position.x + title.frame.size.width / 2 + 8, indicator.position.y)
    }
    
    // MARK: - 按钮点击
    
    func ButtonClicked(sender:UIButton){
        
        let currentTitle = sender.currentTitle
        
        self.confiMenuWithTitle(currentTitle!)
        
        if clickBlock != nil{
            
            self.clickBlock!(button: sender)
        }
    }
}
