
import Foundation

struct Urun {
    var urunId:String
    var urunAd:String
    var urunFiyat:Double
    var kategoriId:String
    var restoranId:String
    
    init(_ urunId:String, _ urunAd:String, _ urunFiyat:Double, _ kategoriId:String, _ restoranId:String) {
        self.urunId = urunId
        self.urunAd = urunAd
        self.urunFiyat = urunFiyat
        self.kategoriId = kategoriId
        self.restoranId = restoranId
    }
}
