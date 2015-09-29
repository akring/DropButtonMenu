# DropButtonMenu
下拉菜单组件

基于[DOPDropDownMenu](https://github.com/dopcn/DOPDropDownMenu)修改，做了很多自定义的修改并转换到Swift 2.0

![enter image description here](http://7te7sy.com1.z0.glb.clouddn.com/DropButtonMenuQQ20150929-1@2x.png)

##安装

简单拖拽`DropButtonMenu.swift`到项目中即可

##使用

* 准备数据源

```
let firstArr = ["解决情况最好的建言","我为公司点个赞"];
let secondArr = ["系统支撑类建言","产品营销类建言","流程规范类建言","终端营销类建言","授权管理类建言","其他类型建言"];
        
let dataArray = [["分类1":firstArr],["分类2":secondArr]];
```

* 调用
```
let menu:DropButtonMenu = DropButtonMenu(org: CGPointMake(0, 20), height: 44)
        menu.dataArray = dataArray
        menu.iconImage = UIImage(named: "MyAdvice_Block")
        menu.clickBlock = {(button) -> Void in
            
            let string = button.currentTitle
            
            //回调Block
        }
        menu.setUpView()
```
