


import UIKit
import Firebase

class GirisVC: UIViewController {

    @IBOutlet weak var viewYonetici: UIView!
    @IBOutlet weak var viewGarsonVeKasa: UIView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var textFieldYoneticiEmail: UITextField!
    @IBOutlet weak var textFieldYoneticiSifre: UITextField!
    @IBOutlet weak var textFieldKasaGarsonRestoranKodu: UITextField!
    @IBOutlet weak var textFieldKasaGarsonKullaniciAdi: UITextField!
    @IBOutlet weak var textFieldKasaGarsonSifre: UITextField!
    
    var garsonSecildi = false
    var kasaSecildi = false
    
    let referenceRestoranlar = Firestore.firestore().collection("Restoranlar")
    let referenceKategoriler = Firestore.firestore().collection("Kategoriler")
    let referenceUrunler = Firestore.firestore().collection("Urunler")
    let referenceGarsonlar = Firestore.firestore().collection("Garsonlar")
    
    var tumRestoranlarFirebase = [Restoran]()
    var tumGarsonlarFirebase = [Garson]()
    var kategorilerByRestoranId = [Kategori]()
    var urunlerByRestoranId = [Urun]()
    
    var singleton = Singleton.getInstance
    var urunlerHafizayaAlindi = false
    var kategorilerHafizayaAlindi = false
    var garsonlarHafizayaAlindi = false
    
    var timerGarsonGirisi = Timer()
    var timerKasaGirisi = Timer()
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        segmentedControlGarsonuSec()
        
        tumRestoranlariGetirFirebase()
        tumGarsonlariGetirFirebase()
        
    }

    
    
    
    func segmentedControlGarsonuSec() {
        segmentedControl.selectedSegmentIndex = 0
        viewYonetici.isHidden = true
        viewGarsonVeKasa.isHidden = false
        garsonSecildi = true
    }
    
    
    
    
    func tumRestoranlariGetirFirebase() {
        referenceRestoranlar.getDocuments { (querySnapshots, error) in
            if error == nil && querySnapshots != nil {
                for document in querySnapshots!.documents {
                    let restoranId = document.documentID
                    let restoranAd = document.get("restoranAd") as! String
                    let yoneticiId = document.get("yoneticiId") as! String
                    let kasaKullaniciAdi = document.get("kasaKullaniciAdi") as! String
                    let kasaSifre = document.get("kasaSifre") as! String
                    let masaSayisi = document.get("masaSayisi") as! Int
                    
                    self.tumRestoranlarFirebase.append(Restoran(restoranId, restoranAd, yoneticiId, kasaKullaniciAdi, kasaSifre, masaSayisi))
                }
            }
        }
    }
    
    
    
    
    func tumGarsonlariGetirFirebase() {
        tumGarsonlarFirebase.removeAll()
        referenceGarsonlar.getDocuments { (queySnapshots, error) in
            if error == nil && queySnapshots != nil {
                for document in queySnapshots!.documents {
                    let garsonId = document.documentID
                    let garsonAd = document.get("garsonAd") as! String
                    let garsonKullaniciAd = document.get("garsonKullaniciAd") as! String
                    let garsonSifre = document.get("garsonSifre") as! String
                    let restoranId = document.get("restoranId") as! String
                    
                    self.tumGarsonlarFirebase.append(Garson(garsonId, garsonAd, garsonKullaniciAd, garsonSifre, restoranId))
                }
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
            }
        }
    }
    
    
    
    
    func kategorileriGetirByRestoranId(_ restoranId:String) {
        kategorilerByRestoranId.removeAll()
        let query = referenceKategoriler.whereField("restoranId", isEqualTo: restoranId)
        
        query.getDocuments { (querySnapshots, error) in
            if error == nil && querySnapshots != nil {
                for document in querySnapshots!.documents {
                    let kategoriId = document.documentID
                    let kategoriAd = document.get("kategoriAd") as! String
                    
                    self.kategorilerByRestoranId.append(Kategori(kategoriId, kategoriAd, restoranId))
                }
                self.kategorilerHafizayaAlindi = true
                self.singleton.restoranKategorileri = self.kategorilerByRestoranId
            }
        }
    }
    
    
    
    
    func urunleriGetirByRestoranId(_ restoranId:String) {
        urunlerByRestoranId.removeAll()
        let query = referenceUrunler.whereField("restoranId", isEqualTo: restoranId)
        
        query.getDocuments { (querySnapshots, error) in
            if error == nil && querySnapshots != nil {
                for document in querySnapshots!.documents {
                    let urunId = document.documentID
                    let kategoriId = document.get("kategoriId") as! String
                    let urunAd = document.get("urunAd") as! String
                    let urunFiyat = document.get("urunFiyat") as! Double
                    
                    self.urunlerByRestoranId.append(Urun(urunId, urunAd, urunFiyat, kategoriId, restoranId))
                }
                self.urunlerHafizayaAlindi = true
                self.singleton.restoranUrunleri = self.urunlerByRestoranId
            }
        }
    }
    
    
    
    
    func garsonlariGetirByRestoranId(_ restoranId:String) {
        var garsonlar = [Garson]()
        for garson in tumGarsonlarFirebase {
            if garson.restoranId == restoranId {
                garsonlar.append(garson)
            }
            singleton.restoranGarsonlari = garsonlar
            garsonlarHafizayaAlindi = true
        }
    }
    
    
    
    
    func restoranIdGecerli(_ restoranId:String) -> Bool {
        for restoran in tumRestoranlarFirebase {
            if restoran.restoranId == restoranId {
                return true
            }
        }
        return false
    }
    
    
    
    
    func garsonGecerli(_ restoranId:String, _ kullaniciAdi:String, _ sifre:String) -> Bool {
        for garson in tumGarsonlarFirebase {
            if garson.restoranId == restoranId && garson.garsonKullaniciAd == kullaniciAdi && garson.garsonSifre == sifre {
                singleton.loginGarson = garson
                for restoran in tumRestoranlarFirebase {
                    if restoran.restoranId == restoranId {
                        singleton.loginRestoran = restoran
                    }
                }
                return true
            }
        }
        return false
    }
    
    
    
    
    func kasaGecerli (_ restoranId:String, _ kullaniciAdi:String, _ sifre:String) -> Bool{
        for restoran in tumRestoranlarFirebase {
            if restoran.restoranId == restoranId && restoran.kasaKullaniciAdi == kullaniciAdi && restoran.kasaSifre == sifre {
                singleton.loginKasa = restoran
                return true
            }
        }
        return false
    }
    
    
    
    
    @objc func timerGarsonGirisiMetodu () {
        if kategorilerHafizayaAlindi && urunlerHafizayaAlindi && garsonlarHafizayaAlindi {
            activityIndicator.stopAnimating()
            activityIndicator.isHidden = true
            self.dismiss(animated: true, completion: nil)       //GirisVC'yi bitir
            performSegue(withIdentifier: "fromGirisVCtoGarsonVC", sender: nil)
            
        } else {
            timerGarsonGirisi = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerGarsonGirisiMetodu), userInfo: nil, repeats: false)
        }
    }
    
    
    
    
    @objc func timerKasaGirisMetodu () {
        if kategorilerHafizayaAlindi && urunlerHafizayaAlindi && garsonlarHafizayaAlindi {
            activityIndicator.stopAnimating()
            activityIndicator.isHidden = true
            self.dismiss(animated: true, completion: nil)       //GirisVC'yi bitir
            performSegue(withIdentifier: "fromGirisVCtoKasaVC", sender: nil)
            
        } else {
            timerKasaGirisi = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerKasaGirisMetodu), userInfo: nil, repeats: false)
        }
    }
    
    
    
    
    @IBAction func segmentedControlDurum(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {   //Garson seçilir
            viewYonetici.isHidden = true
            viewGarsonVeKasa.isHidden = false
            kasaSecildi = false
            garsonSecildi = true
            
        } else if sender.selectedSegmentIndex == 1 {        //Yönetici seçilir
            viewGarsonVeKasa.isHidden = true
            viewYonetici.isHidden = false
            
        } else {        //Kasa seçilir
            viewYonetici.isHidden = true
            viewGarsonVeKasa.isHidden = false
            kasaSecildi = true
            garsonSecildi = false
        }
    }
    
    
    
    
    @IBAction func buttonYoneticiGirisYap(_ sender: Any) {
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
        
        if let email = textFieldYoneticiEmail.text, let sifre = textFieldYoneticiSifre.text {
            if email == "" || sifre == "" {
                activityIndicator.stopAnimating()
                activityIndicator.isHidden = true
                alertGoster("Hata oluştu", "Email ve şifre boş olamaz.")

                
            } else {
                Auth.auth().signIn(withEmail: email, password: sifre) { (auth, error) in
                    if error != nil {
                        self.activityIndicator.stopAnimating()
                        self.activityIndicator.isHidden = true
                        self.alertGoster("Hata oluştu", error!.localizedDescription)
                        
                    } else {
                        self.dismiss(animated: true, completion: nil)       //GirisVC'yi bitir
                        self.performSegue(withIdentifier: "fromGirisVCtoYoneticiVC", sender: nil)
                        self.activityIndicator.stopAnimating()
                        self.activityIndicator.isHidden = true
                    }
                }
            }
        }
    }
    
    
    
    
    @IBAction func buttonYoneticiKayitOl(_ sender: Any) {
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
        
        if let email = textFieldYoneticiEmail.text, let sifre = textFieldYoneticiSifre.text {
            if email == "" || sifre == "" {
                activityIndicator.stopAnimating()
                activityIndicator.isHidden = true
                alertGoster("Hata oluştu", "Email ve şifre boş olamaz.")
                
            } else {
                Auth.auth().createUser(withEmail: email, password: sifre) { (auth, error) in
                    if error != nil {
                        self.activityIndicator.stopAnimating()
                        self.activityIndicator.isHidden = true
                        self.alertGoster("Hata Oluştu", error!.localizedDescription)
                        
                    } else {
                        self.dismiss(animated: true, completion: nil)       //GirisVC'yi bitir
                        self.performSegue(withIdentifier: "fromGirisVCtoYoneticiVC", sender: nil)
                        self.activityIndicator.stopAnimating()
                        self.activityIndicator.isHidden = true
                    }
                }
            }
        }
        
    }
    
    
    
    @IBAction func buttonKasaGarsonGirisYap(_ sender: Any) {
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
        
        if garsonSecildi{
            if let restoranId = textFieldKasaGarsonRestoranKodu.text, let kullaniciAdi = textFieldKasaGarsonKullaniciAdi.text, let sifre = textFieldKasaGarsonSifre.text {
                if restoranIdGecerli(restoranId) {
                    if garsonGecerli(restoranId, kullaniciAdi, sifre) {
                        kategorileriGetirByRestoranId(restoranId)
                        urunleriGetirByRestoranId(restoranId)
                        garsonlariGetirByRestoranId(restoranId)
                        timerGarsonGirisi = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerGarsonGirisiMetodu), userInfo: nil, repeats: false)
                        
                    } else {
                        activityIndicator.stopAnimating()
                        activityIndicator.isHidden = true
                        alertGoster("Hata", "Garson bulunamadı.")
                    }
                    
                } else {
                    activityIndicator.stopAnimating()
                    activityIndicator.isHidden = true
                    alertGoster("Hata", "Restoran bulunamadı.")
                }
            }
            
        } else if kasaSecildi{
            if let restoranId = textFieldKasaGarsonRestoranKodu.text, let kullaniciAdi = textFieldKasaGarsonKullaniciAdi.text, let sifre = textFieldKasaGarsonSifre.text {
                if restoranIdGecerli(restoranId) {
                    if kasaGecerli(restoranId, kullaniciAdi, sifre) {
                        kategorileriGetirByRestoranId(restoranId)
                        urunleriGetirByRestoranId(restoranId)
                        garsonlariGetirByRestoranId(restoranId)
                        timerKasaGirisi = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerKasaGirisMetodu), userInfo: nil, repeats: false)
                        
                    } else {
                        activityIndicator.stopAnimating()
                        activityIndicator.isHidden = true
                        alertGoster("Hata", "Kasa bulunamadı.")
                    }
                    
                } else {
                    activityIndicator.stopAnimating()
                    activityIndicator.isHidden = true
                    alertGoster("Hata", "Restoran bulunamadı.")
                }
            }
        }
    }
    
    
}








// ------------------------ Alert & Toast Mesaj ------------------------
extension UIViewController {
    func alertGoster(_ baslik:String, _ mesaj:String)  {
        let alert = UIAlertController(title: baslik, message: mesaj, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "Tamam", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okButton)
        present(alert, animated: true, completion: nil)
    }
    
    
    func toastMesaj(_ mesaj:String)  {
        let toastLabel = UILabel()
        self.view.addSubview(toastLabel)
        toastLabel.text = "  \(mesaj)  "
        toastLabel.numberOfLines = 0
        toastLabel.textAlignment = .center
        toastLabel.backgroundColor = UIColor.black
        toastLabel.textColor = UIColor.white
        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        toastLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        toastLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        toastLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100).isActive = true
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 5
        toastLabel.clipsToBounds = true
        toastLabel.bringSubviewToFront(view)
        UIView.animate(withDuration: 1.0, delay: 1.0, options: .curveEaseInOut, animations: {
            toastLabel.alpha = 0.0
        }) { (isShowed) in
            toastLabel.removeFromSuperview()
        }
    }
}






// ------------------- Notification Center --------------------
extension Notification.Name {
    static let masaTasimasiYapilacak = Notification.Name("masaTasimasiYapilacak")
    static let restoranKoduKopyalama = Notification.Name("restoranKoduKopyalama")
    static let restoraniSil = Notification.Name("restoraniSil")
    static let restoraniDuzenle = Notification.Name("restoraniDuzenle")
    static let garsonuDuzenle = Notification.Name("garsonuDuzenle")
    static let garsonuSil = Notification.Name("garsonuSil")
    static let kategoriyiDuzenle = Notification.Name("kategoriyiDuzenle")
    static let kategoriyiSil = Notification.Name("kategoriyiSil")
    static let urunuDuzenle = Notification.Name("urunuDuzenle")
    static let urunuSil = Notification.Name("urunuSil")
    static let adisyonuYazdir = Notification.Name("adisyonuYazdir")
    static let hesabiAl = Notification.Name("hesabiAl")
}
