
import Foundation

struct Kategori {
    var kategoriId:String
    var kategoriAd:String
    var restoranId:String
    
    init(_ kategoriId:String, _ kategoriAd:String, _ restoranId:String) {
        self.kategoriAd = kategoriAd
        self.kategoriId = kategoriId
        self.restoranId = restoranId
    }
}
