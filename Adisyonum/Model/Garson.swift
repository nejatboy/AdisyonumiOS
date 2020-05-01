

import Foundation

struct Garson {
    var garsonId:String
    var garsonAd:String
    var garsonKullaniciAd:String
    var garsonSifre:String
    var restoranId:String
    
    init(_ garsonId:String, _ garsonAd:String, _ garsonKullaniciAd:String, _ garsonSifre:String, _ restoranId:String) {
        self.garsonAd = garsonAd
        self.garsonId = garsonId
        self.garsonKullaniciAd = garsonKullaniciAd
        self.garsonSifre = garsonSifre
        self.restoranId = restoranId
    }
}
