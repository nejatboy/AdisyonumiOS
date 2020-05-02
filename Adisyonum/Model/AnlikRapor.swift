

import Foundation

struct AnlikRapor {
    let raporId:String
    let restoranId:String
    let ciro:Double
    let garsonSatislari:[String:Double]
    let hesaplar:[String:Double]
    
    
    init(_ raporId:String, _ restoranId:String, _ ciro:Double, _ garsonSatislari:[String:Double], _ hesaplar:[String:Double]) {
        self.restoranId = restoranId
        self.ciro = ciro
        self.garsonSatislari = garsonSatislari
        self.hesaplar = hesaplar
        self.raporId = raporId
    }
}
