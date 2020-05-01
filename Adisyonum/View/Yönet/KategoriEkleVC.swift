

import UIKit
import Firebase

class KategoriEkleVC: UIViewController {

    @IBOutlet weak var labelEylem: UILabel!
    @IBOutlet weak var textFieldKategoriAd: UITextField!
    
    let referenceKategoriler = Firestore.firestore().collection("Kategoriler")
    var eklenecekRestoranId:String?
    var duzenlenecekKategori:Kategori?
    var eylem = String()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        labelEylem.text = eylem
        if let kategori = duzenlenecekKategori {
            textFieldKategoriAd.text = kategori.kategoriAd
        }
    }
    
    
    
    
    func kategoriyiVeriTabaninaYaz(_ kategori:Kategori) {
        var veri = [String:Any]()
        veri["kategoriId"] = kategori.kategoriId
        veri["restoranId"] = kategori.restoranId
        veri["kategoriAd"] = kategori.kategoriAd
        referenceKategoriler.addDocument(data: veri)
    }
    
    
    
    
    func kategoriyiGuncelle(_ kategori:Kategori, _ yeniKategoriAd:String)  {
        var veri = [String:Any]()
        veri["kategoriAd"] = yeniKategoriAd
        referenceKategoriler.document(kategori.kategoriId).setData(veri, merge: true)
    }
    
    
    

    @IBAction func buttonGeri(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    
    @IBAction func buttonOnayla(_ sender: Any) {
        if eylem.lowercased().contains("ekle") {        //Ekleme ile gelindiyse
            if let kategoriAd = textFieldKategoriAd.text {
                if kategoriAd == "" {
                    toastMesaj("Kategori adı giriniz.")
                } else {
                    let kategori = Kategori("", kategoriAd, eklenecekRestoranId!)
                    kategoriyiVeriTabaninaYaz(kategori)
                    dismiss(animated: true, completion: nil)
                }
            }
            
        } else {    //Düzenleme ile gelindiyse
            if let kategori = duzenlenecekKategori, let yeniKategoriAd = textFieldKategoriAd.text {
                if yeniKategoriAd == "" {
                    toastMesaj("Boş bırakılamaz")
                } else {
                    kategoriyiGuncelle(kategori, yeniKategoriAd)
                    dismiss(animated: true, completion: nil)
                }
            }
        }
    }
}
