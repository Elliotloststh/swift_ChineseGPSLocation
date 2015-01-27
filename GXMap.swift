//
//  GXMap.swift
//  gxc
//
//  Created by gx on 14/12/3.
//  Copyright (c) 2014年 zheng. All rights reserved.
//

import Foundation
import CoreLocation

class GXMap {
    
    
    //转换过后，算经纬度
    func distanceBetweenOrderBy(lat1:Double,lat2:Double,lng1:Double,lng2:Double) ->Double
    {
        var curLocation: CLLocation = CLLocation(latitude: lat1, longitude: lng1)
        var otherLocation: CLLocation = CLLocation(latitude: lat2, longitude: lng2)
        
        let distance = curLocation.distanceFromLocation(otherLocation)
        return distance
    }
    
     
    //  // 百度坐标转谷歌坐标
    let x_pi :Double = (3.14159265358979324 * 3000.0) / 180.0
    
    //     + (void)transformatBDLat:(double)fBDLat BDLng:(double)fBDLng toGoogleLat:(double *)pfGoogleLat googleLng:(double *)pfGoogleLng
    //    {
    //    Double x = fBDLng - 0.0065f, y = fBDLat - 0.006f;
    //    Double z = sqrt(x * x + y * y) - 0.00002f * sin(y * x_pi);
    //    Double theta = atan2(y, x) - 0.000003f * cos(x * x_pi);
    //    *pfGoogleLng = z * cos(theta);
    //    *pfGoogleLat = z * sin(theta);
    //    }
    //
    //    + (CLLocationCoordinate2D)getGoogleLocFromBaiduLocLat:(double)fBaiduLat lng:(double)fBaiduLng
    //    {
    //    Double fLat;
    //    Double fLng;
    //
    //    [[self class] transformatBDLat:fBaiduLat BDLng:fBaiduLng toGoogleLat:&fLat googleLng:&fLng];
    //
    //    CLLocationCoordinate2D objLoc;
    //    objLoc.latitude = fLat;
    //    objLoc.longitude = fLng;
    //    return objLoc;
    //    }
    
    func transformatBDLat(fBDLat:Double ,fBDLng:Double , pfGoogleLat:Double, pfGoogleLng:Double)
    {
        var x = fBDLng - 0.0065
        var y = fBDLat - 0.006
        var z = sqrt(x * x + y * y) - 0.00002 * sin(y * x_pi);
        var theta = atan2(y, x) - 0.000003 * cos(x * x_pi);
       var  pfGoogleLng1 = Double(z * cos(theta))
       var  pfGoogleLat1 = Double(z * sin(theta))
    }
    
    func getGoogleLocFromBaiduLocLat(fBaiduLat:Double ,fBaiduLng:Double) -> CLLocationCoordinate2D
    {
        var fLat:Double!
        var fLng:Double!
        
        self.transformatBDLat(fBaiduLat, fBDLng: fBaiduLng, pfGoogleLat: fLat, pfGoogleLng: fLng)
        
        var objLoc:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude:fLat, longitude: fLng)
        
       return objLoc;
     }
    
    
    
    // 谷歌坐标转百度坐标
    func getBaiduLocFromGoogleLocLat(fGoogleLat:Double , fGoogleLng:Double) -> CLLocationCoordinate2D
    {
        var x = fGoogleLng
        var y = fGoogleLat
        
        var z = sqrt(x * x + y * y) + Double(0.00002 * Double(sin(y * x_pi)))
        
        var theta = atan2(y, x) + Double(0.000003 * cos(x * x_pi))
        
        var objLoc:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude:(z * sin(theta)) + 0.006, longitude: (z * cos(theta)) + 0.0065)
  
        return objLoc;
    }
    
    
    /*******************       === GPS-Google  END  ===    *******************/
    // GPS坐标转谷歌坐标
    func GPSLocToGoogleLoc(objGPSLoc :CLLocationCoordinate2D) -> CLLocationCoordinate2D
    {
        return self.transformFromWGSCoord2MarsCoord(objGPSLoc)
    }
    
    
    /*******************       === GPS-Google  BEGIN  ===    *******************/
    /*               在网上看到的根据这个 c# 代码改的 GPS坐标转火星坐标               */
    /*  https://on4wp7.codeplex.com/SourceControl/changeset/view/21483#353936  */
    /***************************************************************************/
    
    let   pi:Double = 3.14159265358979324
    //
    // Krasovsky 1940
    //
    // a = 6378245.0, 1/f = 298.3
    // b = a * (1 - f)
    // ee = (a^2 - b^2) / a^2;
    let  a:Double = 6378245.0
    let  ee:Double = 0.00669342162296594323
    
    
    // World Geodetic System ==> Mars Geodetic System
    func transformFromWGSCoord2MarsCoord(wgsCoordinate:CLLocationCoordinate2D) -> CLLocationCoordinate2D
    {
        var wgLat:Double = wgsCoordinate.latitude
        var wgLon:Double = wgsCoordinate.longitude
        
        
        if (self.outOfChina(wgLat, lon: wgLon))
        {
            return wgsCoordinate
        }
        
        var dLat: Double = self.transformLat(wgLon - 105.0, y: wgLat - 35.0)
        var dLon: Double = self.transformLon(wgLon - 105.0, y: wgLat - 35.0)
        
        var radLat :Double = wgLat / 180.0 * pi
        var magic :Double = sin(radLat)
        magic = 1 - ee * magic * magic
        var sqrtMagic:Double = sqrt(magic)
        
        dLat = (dLat * 180.0) / ((a * (1 - ee)) / (magic * sqrtMagic) * pi)
        dLon = (dLon * 180.0) / (a / sqrtMagic * cos(radLat) * pi)
        
        var marsCoordinate:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: wgLat + dLat, longitude: wgLon + dLon)
        
        return marsCoordinate
    }
    
    
    
    func outOfChina(lat :Double,lon:Double) -> Bool
    {
        if (lon < 72.004 || lon > 137.8347)
        {
            return true
        }
        if (lat < 0.8293 || lat > 55.8271)
        {
            return true
        }
        return false
    }
    
    func transformLat(x:Double,y:Double) ->Double
    {
        var temp1 :Double = 0.2 * sqrt(abs(x))
        var temp2 :Double = 0.1 * x * y
        var temp3 :Double = 0.2 * y * y
        var temp4 :Double = 3.0 * y
        var temp5 :Double = 2.0 * x
        
        var ret :Double = -100.0 +  temp1 + temp2 + temp3 + temp4 + temp5
        
        
        ret += ((20.0 * sin(6.0 * x * pi) + 20.0 * sin(2.0 * x * pi)) * 2.0 ) / 3.0
        
        ret += (20.0 * sin(y * pi) + 40.0 * sin(y / 3.0 * pi)) * 2.0 / 3.0
        
        ret += (160.0 * sin(y / 12.0 * pi) + 320 * sin(y * pi / 30.0)) * 2.0 / 3.0
        
        return ret
        
    }
    
    func transformLon(x:Double,y:Double) ->Double
    {
        var ret:Double = 300.0 + x + (2.0 * y) + (0.1 * x * x) + ( 0.1 * x * y ) + Double(0.1 * sqrt(abs(x)))
        
        ret += ((20.0 * sin(6.0 * x * pi) + 20.0 * sin(2.0 * x * pi)) * 2.0) / 3.0
        
        ret += (20.0 * sin(x * pi) + 40.0 * sin(x / 3.0 * pi)) * 2.0 / 3.0
        
        ret += (150.0 * sin(x / 12.0 * pi) + 300.0 * sin(x / 30.0 * pi)) * 2.0 / 3.0
        
        return ret
        
    }
    
}


























