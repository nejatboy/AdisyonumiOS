
import Foundation

class Singleton {
    
    static var getInstance = Singleton()
    
    var loginGarson: Garson?
    var loginKasa: Restoran?
    var loginRestoran:Restoran?
    var restoranKategorileri =  [Kategori]()
    var restoranGarsonlari = [Garson]()
    var restoranUrunleri = [Urun]()
    
    private init() {
        
    }
}
