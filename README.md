# swift_ChineseGPSLocation
ios 获取火星坐标后.直接转换成对的

原来的oc代码是github上找的. 地址等我找找贴出来..感谢他的奉献
后来花了十分钟改成了swift . 

###作用:
百度搜索 iOS 火星坐标

###用法:

``` 
  sss = GXMap().distanceBetweenOrderBy(GXViewState.community.Latitude!, lat2:shopCell.Latitude! , lng1: GXViewState.community.Longitude!, lng2: shopCell.Longitude!)
  
  cell.locationLengthLabel.text = "\(Int(sss))米"
```
