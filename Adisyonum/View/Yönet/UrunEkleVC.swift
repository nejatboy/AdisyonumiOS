
import UIKit
import Firebase

class UrunEkleVC: UIViewController {

    @IBOutlet weak var labelEylem: UILabel!
    @IBOutlet weak var textfieldUrunAd: UITextField!
    @IBOutlet weak var textfieldUrunFiyat: UITextField!
    
    var eylem = String()
    var duzenlenecekUrun:Urun?
    var eklenecekRestoranId:String?
    var eklenecekKategoriId:String?
    let referenceUrunler = Firestore.firestore().collection("Urunler")
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        labelEylem.text = eylem
        
        if let urun = duzenlenecekUrun {
            textfieldUrunAd.text = urun.urunAd
            textfieldUrunFiyat.text = String(urun.urunFiyat)
        }
    }
    
    
    
    
    func urunuVeriTabaninaYaz(_ urun:Urun)  {
        var veri = [String:Any]()
        veri["urunId"] = urun.urunId
        veri["urunAd"] = urun.urunAd
        veri["urunFiyat"] = urun.urunFiyat
        veri["restoranId"] = urun.restoranId
        veri["kategoriId"] = urun.kategoriId
        
        referenceUrunler.addDocument(data: veri)
    }
    
    
    
    
    func urunuGuncelle(_ urun:Urun, _ yeniUrunAd:String, _ yeniUrunFiyat:Double)  {
        var veri = [String:Any]()
        veri["urunAd"] = yeniUrunAd
        veri["urunFiyat"] = yeniUrunFiyat
        
        referenceUrunler.document(urun.urunId).setData(veri, merge: true)
    }
    

    
    
    @IBAction func buttonGeri(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    
    @IBAction func buttonOnay(_ sender: Any) {
        if eylem.lowercased().contains("ekle") {    //Ekle butonu ile gelindiyse
            if let restoranId = eklenecekRestoranId, let kategoriId = eklenecekKategoriId{
                if let urunAd = textfieldUrunAd.text, let urunFiyat = textfieldUrunFiyat.text {
                    if urunAd == "" || urunFiyat == "" {
                        toastMesaj("Eksik bilgi girdiniz")
                    } else {
                        if let urunFiyatDouble = Double(urunFiyat) {
                            let urun = Urun("", urunAd, urunFiyatDouble, kategoriId, restoranId)
                            urunuVeriTabaninaYaz(urun)
                            dismiss(animated: true, completion: nil)
                        } else {
                            toastMesaj("Ürün fiyatına sayı giriniz.")
                        }
                    }
                }
            }
            
        } else {        // Düzenle butonu ile gelindiyse
            if let urun = duzenlenecekUrun, let urunAd = textfieldUrunAd.text, let urunFiyat = textfieldUrunFiyat.text {
                if urunAd == "" || urunFiyat == "" {
                    toastMesaj("Eksik bilgi girdiniz.")
                } else {
                    if let urunFiyatDouble = Double(urunFiyat) {
                        urunuGuncelle(urun, urunAd, urunFiyatDouble)
                        dismiss(animated: true, completion: nil)
                    } else {
                        toastMesaj("Ürün fiyatına sayı giriniz ")
                    }
                }
            }
        }
    }
    
}
