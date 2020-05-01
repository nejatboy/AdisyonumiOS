

import Foundation

struct Restoran {
    var restoranId:String
    var restoranAd:String
    var yoneticiId:String
    var kasaKullaniciAdi:String
    var kasaSifre:String
    var masaSayisi:Int
    
    init(_ restoranId:String, _ restoranAd:String, _ yoneticiId:String, _ kasaKullaniciAdi:String, _ kasaSifre:String, _ masaSayisi:Int) {
        self.restoranAd = restoranAd
        self.restoranId = restoranId
        self.kasaKullaniciAdi = kasaKullaniciAdi
        self.yoneticiId = yoneticiId
        self.masaSayisi = masaSayisi
        self.kasaSifre = kasaSifre
    }
}
