
import Foundation

struct Rapor {
    let raporId:String
    let hesaplar:[String:Any]
    let garsonSatislari:[String:Any]
    let tarih:Date
    let ciro:Double
    let restoranId:String
    
    init(_ raporId:String, _ hesaplar:[String:Any], _ garsonSatislari:[String:Any], _ tarih:Date, _ ciro:Double, _ restoranId:String) {
        self.raporId = raporId
        self.restoranId = restoranId
        self.hesaplar = hesaplar
        self.garsonSatislari = garsonSatislari
        self.ciro = ciro
        self.tarih = tarih
    }
}
