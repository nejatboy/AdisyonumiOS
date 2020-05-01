

import Foundation

struct Masa {
    var masaId:String
    var masaNo:Int
    var masaTutar:Double
    var masaAcik:Bool
    var masaYazdirildi:Bool
    var garsonId:String
    var restoranId:String
    var urunler:[String]
    
    init(_ masaId:String, _ masaNo:Int, _ masaTutar:Double, _ masaAcik:Bool, _ masaYazdirildi:Bool, _ garsonId:String, _ restoranId:String, _ urunler: [String]) {
        self.masaId = masaId
        self.masaNo = masaNo
        self.masaTutar = masaTutar
        self.masaAcik = masaAcik
        self.masaYazdirildi = masaYazdirildi
        self.garsonId = garsonId
        self.urunler = urunler
        self.restoranId = restoranId
    }
}
