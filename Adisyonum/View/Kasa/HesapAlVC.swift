

import UIKit
import Firebase

class HesapAlVC: UIViewController {
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var labelMasaNo: UILabel!
    @IBOutlet weak var labelKalanTutar: UILabel!
    @IBOutlet weak var textfieldGirilenTutar: UITextField!
    
    let referenceAnlikRaporlar = Firestore.firestore().collection("AnlikRaporlar")
    let referenceMasalar = Firestore.firestore().collection("Masalar")
    
    let singleton = Singleton.getInstance
    var masa:Masa?
    var alinanTutar = 0.0
    var odemeTurleri = [String:Double]()
    var odemeTuru = String()
    var rapor:AnlikRapor?
    
    
    
    
    override var shouldAutorotate: Bool {       //Yatay mod için
        return true
    }
    
    
    
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {       //Yatay mod için
        return .landscapeRight
    }
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        //Yatay mod için
        let value = UIInterfaceOrientation.landscapeRight.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        
        if let masa = masa {
            labelMasaNo.text = "Masa: \(masa.masaNo)"
            labelKalanTutar.text = String(masa.masaTutar)
            textfieldGirilenTutar.text = String(masa.masaTutar)
        } else {
            dismiss(animated: true, completion: nil)
        }
        
        segmentedControl.selectedSegmentIndex = 0       //İlk nakit seçilsin
        odemeTuru = "nakit"
        
        hesaplariOlustur()
        
        raporKontrol()
    }
    
    
    
    
    override func viewDidDisappear(_ animated: Bool) {
        masa = nil
        alinanTutar = 0.0
        rapor = nil
    }
    
    
    
    
    func raporKontrol() {
        let query = referenceAnlikRaporlar.whereField("restoranId", isEqualTo: singleton.loginKasa!.restoranId)
        query.getDocuments { (querySnapshots, error) in
            if error == nil && querySnapshots != nil {
                if !querySnapshots!.isEmpty {        //Rapor yok
                    if let document = querySnapshots?.documents[0] {
                        let raporId = document.documentID
                        let ciro = document.get("ciro") as! Double
                        let hesaplar = document.get("hesaplar") as! [String:Double]
                        let garsonSatislari = document.get("garsonSatislari") as! [String:Double]
                        let restoranId = document.get("restoranId") as! String
                        
                        self.rapor = AnlikRapor(raporId, restoranId, ciro, garsonSatislari, hesaplar)
                    }
                }
            }
        }
    }
    
    
    
    
    func hesabiRaporla() {
        if rapor == nil {
            raporOlustur()
            
        } else {
            raporGuncelle(rapor!)
        }
    }
    
    
    
    
    func raporOlustur() {
        print("rapor oluştur çalıştı")
        var veri = [String:Any]()
        veri["ciro"] = alinanTutar
        veri["hesaplar"] = odemeTurleri
        veri["garsonSatislari"] = [masa!.garsonId:alinanTutar]
        veri["restoranId"] = singleton.loginKasa!.restoranId
        veri["raporId"] = ""
        
        referenceAnlikRaporlar.addDocument(data: veri) { (error) in
            if error == nil {
                self.masayiSil(masaId: self.masa!.masaId)
            }
        }
    }
    
    
    
    
    func raporGuncelle(_ rapor:AnlikRapor) {
        print("Rapor güncell çalıştı")
        var hesaplar = rapor.hesaplar
        var garsonSatislari = rapor.garsonSatislari
        let ciro = rapor.ciro
        
        hesaplar["nakit"] = hesaplar["nakit"]! + odemeTurleri["nakit"]!
        hesaplar["krediKarti"] = hesaplar["krediKarti"]! + odemeTurleri["krediKarti"]!
        hesaplar["multinet"] = hesaplar["multinet"]! + odemeTurleri["multinet"]!
        hesaplar["ticket"] = hesaplar["ticket"]! + odemeTurleri["ticket"]!
        hesaplar["sodexo"] = hesaplar["sodexo"]! + odemeTurleri["sodexo"]!
        hesaplar["setcard"] = hesaplar["setcard"]! + odemeTurleri["setcard"]!
        hesaplar["metropol"] = hesaplar["metropol"]! + odemeTurleri["metropol"]!
        
        if garsonSatislari[masa!.garsonId] == nil {     //Garson daha önce satış yapmamışsa
            garsonSatislari[masa!.garsonId] = alinanTutar
        } else {
            garsonSatislari[masa!.garsonId] = garsonSatislari[masa!.garsonId]! + alinanTutar
        }
        
        var veri = [String:Any]()
        veri["hesaplar"] = hesaplar
        veri["garsonSatislari"] = garsonSatislari
        veri["ciro"] = ciro + alinanTutar
        
        referenceAnlikRaporlar.document(rapor.raporId).setData(veri, merge: true) { (error) in
            if error == nil {
                self.masayiSil(masaId: self.masa!.masaId)
            }
        }
    }
    
    
    
    
    func masayiSil(masaId:String)  {
        referenceMasalar.document(masaId).delete()
    }
    
    
    
    
    func hesaplariOlustur() {
        odemeTurleri["nakit"] = 0.0
        odemeTurleri["krediKarti"] = 0.0
        odemeTurleri["multinet"] = 0.0
        odemeTurleri["ticket"] = 0.0
        odemeTurleri["sodexo"] = 0.0
        odemeTurleri["setcard"] = 0.0
        odemeTurleri["metropol"] = 0.0
    }
    
    
    
    
    @IBAction func buttonGeri(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    
    @IBAction func segmentedControl(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            odemeTuru = "nakit"
        } else if sender.selectedSegmentIndex == 1 {
            odemeTuru = "krediKarti"
        } else if sender.selectedSegmentIndex == 2 {
            odemeTuru = "multinet"
        } else if sender.selectedSegmentIndex == 3 {
            odemeTuru = "ticket"
        } else if sender.selectedSegmentIndex == 4 {
            odemeTuru = "sodexo"
        } else if sender.selectedSegmentIndex == 5 {
            odemeTuru = "setcard"
        } else if sender.selectedSegmentIndex == 6 {
            odemeTuru = "metropol"
        }
    }
    
    
    

    @IBAction func buttonTutariAl(_ sender: Any) {
        if let girilenTutarString = textfieldGirilenTutar.text {
            if girilenTutarString == "" {
                toastMesaj("Tutar giriniz.")
            } else if Double(girilenTutarString) == nil {
                toastMesaj("Sayı girişi yapınız.")
            } else {
                if  let girilenTutar = Double(girilenTutarString) {
                    alinanTutar = alinanTutar + girilenTutar
                    labelKalanTutar.text = "\(masa!.masaTutar - alinanTutar)"
                    textfieldGirilenTutar.text = "\(masa!.masaTutar - alinanTutar)"
                    
                    odemeTurleri[odemeTuru] = odemeTurleri[odemeTuru]! + girilenTutar
                    
                    if alinanTutar >= masa!.masaTutar {
                        hesabiRaporla()
                        dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }
}
