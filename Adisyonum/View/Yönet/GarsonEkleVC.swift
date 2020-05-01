

import UIKit
import Firebase

class GarsonEkleVC: UIViewController {

    @IBOutlet weak var labelEylem: UILabel!
    @IBOutlet weak var textfieldGarsonAd: UITextField!
    @IBOutlet weak var textfieldGarsonKullaniciAdi: UITextField!
    @IBOutlet weak var textfieldGarsonSifre: UITextField!
    
    var eylem = String()
    var duzenlenecekGarson:Garson?
    var eklenecekRestoranId:String?
    
    let referenceGarsonlar = Firestore.firestore().collection("Garsonlar")
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        labelEylem.text = eylem
        if let garson = duzenlenecekGarson {
            textfieldGarsonAd.text = garson.garsonAd
            textfieldGarsonSifre.text = garson.garsonSifre
            textfieldGarsonKullaniciAdi.text = garson.garsonKullaniciAd
        }
        
    }
    
    
    
    
    func garsonuVeriTabaninaYaz(_ garson:Garson) {
        var veri = [String:Any]()
        veri["garsonId"] = garson.garsonId
        veri["garsonAd"] = garson.garsonAd
        veri["garsonKullaniciAd"] = garson.garsonKullaniciAd
        veri["garsonSifre"] = garson.garsonSifre
        veri["restoranId"] = garson.restoranId
        
        referenceGarsonlar.addDocument(data: veri)
    }
    
    
    
    
    func garsonuGuncelle(_ garsonAd:String, _ garsonKullaniciAd:String, _ garsonSifre:String)  {
        var veri = [String:Any]()
        veri["garsonAd"] = garsonAd
        veri["garsonKullaniciAd"] = garsonKullaniciAd
        veri["garsonSifre"] = garsonSifre
        
        referenceGarsonlar.document(duzenlenecekGarson!.garsonId).setData(veri, merge: true)
    }
    

    
    
    @IBAction func buttonIptal(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    
    @IBAction func buttonEkle(_ sender: Any) {
        if self.eylem.lowercased().contains("ekle") {        //Garson Ekle Buttonu ile gelindiyse
            if let garsonAd = self.textfieldGarsonAd.text, let garsonSifre = self.textfieldGarsonSifre.text, let garsonKullaniciAdi = self.textfieldGarsonKullaniciAdi.text {
                if garsonSifre == "" || garsonAd == "" || garsonKullaniciAdi == "" {
                    self.toastMesaj("Eksik bilgi girdiniz.")
                } else {
                    if Int(garsonSifre) != nil {    //Ekleme yapılır
                        let garson = Garson("", garsonAd, garsonKullaniciAdi, garsonSifre, eklenecekRestoranId!)
                        garsonuVeriTabaninaYaz(garson)
                        self.dismiss(animated: true, completion: nil)
                        
                    } else {
                        self.toastMesaj("Garson şifresi rakamlardan oluşmalıdır.")
                    }
                }
            }
            
        } else {        //Garson Düzenle Buttonu ile gelindiyse
            if let garsonAd = self.textfieldGarsonAd.text, let garsonSifre = self.textfieldGarsonSifre.text, let garsonKullaniciAdi = self.textfieldGarsonKullaniciAdi.text {
                if garsonSifre == "" || garsonAd == "" || garsonKullaniciAdi == "" {
                    self.toastMesaj("Eksik bilgi girdiniz.")
                } else {
                    if Int(garsonSifre) != nil {    //Güncelleme yapılır
                        garsonuGuncelle(garsonAd, garsonKullaniciAdi, garsonSifre)
                        self.dismiss(animated: true, completion: nil)
                        
                    } else {
                        self.toastMesaj("Garson şifresi rakamlardan oluşmalıdır.")
                    }
                }
            }
        }
    }
}
