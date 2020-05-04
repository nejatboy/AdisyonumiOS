

import UIKit
import Firebase

class KasaVC: UIViewController {
    
    @IBOutlet weak var collectionViewMasalar: UICollectionView!
    @IBOutlet weak var viewSideMenu: UIView!
    @IBOutlet weak var viewSideMenuLeftConstraint: NSLayoutConstraint!
    
    let referenceMasalar = Firestore.firestore().collection("Masalar")
    let referenceAnlikRaporlar = Firestore.firestore().collection("AnlikRaporlar")
    let referenceGunlukRaporlar = Firestore.firestore().collection("GunlukRaporlar")
    let singleton = Singleton.getInstance
    var tumMasalar = [Masa]()
    
    var sideMenuAcik = false
    
    
    
    
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
        
        collectionViewMasalar.delegate = self
        collectionViewMasalar.dataSource = self
        hucreTasariminiAyarla()
        
        UIApplication.shared.isIdleTimerDisabled = true      //Keep screen on
    }
    
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        masalariGetir(singleton.loginKasa!.restoranId)
        
        NotificationCenter.default.addObserver(self, selector: #selector(bildirimYakalaHesabiAl(notification:)), name: .hesabiAl, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(bildirimYakalaAdisyonuYazdir(notification:)), name: .adisyonuYazdir, object: nil)
        
        sideMenuAc()
    }
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "kasaVCtoAnlikRaporlarVC" {
            let rapor = sender as! AnlikRapor
            let anlikRaporVC = segue.destination as! AnlikRaporalarVC
            anlikRaporVC.rapor = rapor
        }
    }
    
    
    
    
    func hucreTasariminiAyarla() {
        let tasarim = UICollectionViewFlowLayout()  
        let genislik = collectionViewMasalar.frame.size.width  //CollectionView'ın yayıldığı alanın genişliğini aldım
        tasarim.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)   //Hücre ile collectionView arası boşluklar
        tasarim.minimumInteritemSpacing = 10     //yatayda hücreler arası boşluk
        tasarim.minimumLineSpacing = 10  //Dikeyde hücreler arası boşluk
        let hucreKenarUzunluk = (genislik - 70) / 6
        tasarim.itemSize = CGSize(width: hucreKenarUzunluk,  height: hucreKenarUzunluk)
        tasarim.scrollDirection = UICollectionView.ScrollDirection.vertical
        collectionViewMasalar.collectionViewLayout = tasarim   //Hazırladığım tasarımı aktardım
    }
    
    
    
    
    func masalariGetir(_ restoranId:String) {
        let query = referenceMasalar.whereField("restoranId", isEqualTo: restoranId)
        query.addSnapshotListener { (querySnapshots, error) in
            if error == nil && querySnapshots != nil {
                self.tumMasalar.removeAll()
                self.masalariOlustur()
                
                for document in querySnapshots!.documents {
                    let masaId = document.documentID
                    let masaNo = document.get("masaNo") as! Int
                    let masaTutar = document.get("masaTutar") as! Double
                    let masaAcik = document.get("masaAcik") as! Bool
                    let masaYazdirildi = document.get("masaYazdirildi") as! Bool
                    let garsonId = document.get("garsonId") as! String
                    let urunler = document.get("urunler") as! [String]
                    
                    self.tumMasalar[masaNo - 1] = Masa(masaId, masaNo, masaTutar, masaAcik, masaYazdirildi, garsonId, restoranId, urunler)
                }
                self.collectionViewMasalar.reloadData()
            }
        }
    }
    
    
    
    
    func garsonGetirByGarsonId(_ garsonId:String) -> Garson {
        var garson:Garson?
        for g in singleton.restoranGarsonlari {
            if g.garsonId == garsonId {
                garson = g
                break
            }
        }
        return garson!
    }
    
    
    
    
    func masalariOlustur() {
        for i in 1...singleton.loginKasa!.masaSayisi {
            tumMasalar.append(Masa("", i, 0.0, false, false, "", "", [String]()))
        }
        collectionViewMasalar.reloadData()
    }
    
    
    
    
    func masaGetirByMasaId(_ masaId:String) -> Masa {
        var masa:Masa?
        for m in tumMasalar {
            if m.masaId == masaId {
                masa = m
                break
            }
        }
        return masa!
    }
    
    
    
    
    func adisyonuYazdirYadaGeriAl(_ masaId:String, islem:Bool)  {
        var veri = [String:Any]()
        veri["masaYazdirildi"] = islem
        referenceMasalar.document(masaId).setData(veri, merge: true)
    }
    
    
    
    
    func sideMenuAc() {
        viewSideMenuLeftConstraint.constant = -10
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
        sideMenuAcik = true
    }
    
    
    
    
    func sideMenuKapat() {
        viewSideMenuLeftConstraint.constant = -185
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
        sideMenuAcik = false
    }
    
    
    
    
    func anlikRaporuKapat(_ anlikRapor:AnlikRapor) {
        let alert = UIAlertController(title: "Kasa Kapatılacak", message: "Bugünkü alınan hesaplar raporlanacak. Emin misiniz?", preferredStyle: .alert)
        let evetButton = UIAlertAction(title: "Evet", style: .destructive) { (alertAction) in
            var veri = [String:Any]()
            veri["raporId"] = ""
            veri["hesaplar"] = anlikRapor.hesaplar
            veri["garsonSatislari"] = anlikRapor.garsonSatislari
            veri["tarih"] = Date()
            veri["ciro"] = anlikRapor.ciro
            veri["restoranId"] = anlikRapor.restoranId
            
            self.referenceGunlukRaporlar.addDocument(data: veri) { (error) in   //Günlük raporu oluştur
                if error == nil {
                    self.referenceAnlikRaporlar.document(anlikRapor.raporId).delete()   //Anlık raporu sil
                    self.toastMesaj("Rapor oluşturuldu.")
                    self.sideMenuKapat()
                }
            }
        }
        let iptalButton = UIAlertAction(title: "İptal", style: .cancel, handler: nil)
        alert.addAction(evetButton)
        alert.addAction(iptalButton)
        present(alert, animated: true, completion: nil)
    }
    


    
    
    @objc func bildirimYakalaAdisyonuYazdir (notification:NSNotification) {
        if let masaId = notification.userInfo!["masaId"] as? String {
            if masaId == "" {       //masa boş ise
                toastMesaj("Masa boş!")
                
            } else {
                let masa = masaGetirByMasaId(masaId)
                if masa.masaYazdirildi {
                    adisyonuYazdirYadaGeriAl(masa.masaId, islem: false)     //Geri al
                } else {
                    adisyonuYazdirYadaGeriAl(masa.masaId, islem: true)      //Yazdır
                }
            }
        }
    }
    
    
    
    
    @objc func bildirimYakalaHesabiAl (notification:NSNotification) {
        if let masaId = notification.userInfo!["masaId"] as? String {
            if masaId == "" {   //Masa boş ise
                toastMesaj("Masa boş!")
                
            } else {
                let masa = masaGetirByMasaId(masaId)
                if masa.masaYazdirildi {
                    let storyboard = UIStoryboard(name: "Dialog", bundle: .main)
                    let hesapAlVC = storyboard.instantiateViewController(withIdentifier: "hesapAlVC") as! HesapAlVC
                    hesapAlVC.masa = masa
                    present(hesapAlVC, animated: true, completion: nil)
                } else {
                    toastMesaj("Önce adisyonu yazdırınız.")
                }
            }
            
        }
    }
    
    
    
    
    @IBAction func buttonBugunkuRaporlar(_ sender: Any) {
        referenceAnlikRaporlar.whereField("restoranId", isEqualTo: singleton.loginKasa!.restoranId).getDocuments { (querySnapshots, error) in
            if error == nil && querySnapshots != nil {
                if querySnapshots!.isEmpty {
                    self.toastMesaj("Henüz hesap alınmadı.")
                    self.sideMenuKapat()
                    
                } else {
                    var rapor:AnlikRapor?
                    if let document = querySnapshots?.documents[0] {
                        let raporId = document.documentID
                        let ciro = document.get("ciro") as! Double
                        let hesaplar = document.get("hesaplar") as! [String:Double]
                        let garsonSatislari = document.get("garsonSatislari") as! [String:Double]
                        let restoranId = document.get("restoranId") as! String
                        
                        rapor = AnlikRapor(raporId, restoranId, ciro, garsonSatislari, hesaplar)
                    }
                    self.performSegue(withIdentifier: "kasaVCtoAnlikRaporlarVC", sender: rapor!)
                    self.sideMenuKapat()
                }
            }
        }
    }
    
    
    
    
    @IBAction func buttonTumRaporlar(_ sender: Any) {
        toastMesaj("Tüm raporlar")
    }
    
    
    
    
    @IBAction func buttonKasayiKapat(_ sender: Any) {
        var acikMasaVar = false
        for masa in tumMasalar {
            if masa.masaAcik {
                acikMasaVar = true
                break
            }
        }
        
        if acikMasaVar {
            toastMesaj("Açık masa var")
            sideMenuKapat()
        } else {
            referenceAnlikRaporlar.whereField("restoranId", isEqualTo: singleton.loginKasa!.restoranId).getDocuments { (querySnapshots, error) in
                if error == nil && querySnapshots != nil {
                    if !querySnapshots!.isEmpty {    //Rapor varsa
                        if let document = querySnapshots?.documents[0] {
                            let raporId = document.documentID
                            let ciro = document.get("ciro") as! Double
                            let hesaplar = document.get("hesaplar") as! [String:Double]
                            let garsonSatislari = document.get("garsonSatislari") as! [String:Double]
                            let restoranId = document.get("restoranId") as! String
                            
                            let anlikRapor = AnlikRapor(raporId, restoranId, ciro, garsonSatislari, hesaplar)
                            self.anlikRaporuKapat(anlikRapor)
                        }
                        
                    } else {        //Rapor yoksa
                        self.toastMesaj("Alınmış hesap yok.")
                        self.sideMenuKapat()
                    }
                }
            }
        }
    }
    
    
    
    
    @IBAction func buttonCikisYap(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    
    @IBAction func slideHareketi(_ sender: UIPanGestureRecognizer) {
        
        if sender.state == .changed {
            let transition = sender.translation(in: self.view).x
            if transition > 50 && !sideMenuAcik{
                sideMenuAc()
                
            } else if transition < -50 && sideMenuAcik{
                sideMenuKapat()
            }
        }
    }
}










// --------------------------- CollectionView -------------------------
extension KasaVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tumMasalar.count
    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if tumMasalar.isEmpty {
            return UICollectionViewCell()
            
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "hucreMasa_KasaVC", for: indexPath) as! HucreMasa_KasaVC
            let masa = tumMasalar[indexPath.item]
            
            if masa.masaAcik && masa.masaYazdirildi {
                cell.backgroundColor = UIColor(named: "yazdirilmisMasaHucreRengi")
                
            } else if masa.masaAcik {
                cell.backgroundColor = UIColor(named: "doluMasaHucreRengi")
                
            } else {
                cell.backgroundColor = UIColor(named: "bosMasaHucreRengi")
            }
            
            cell.labelHesap.text = "\(masa.masaTutar) TL"
            cell.labelMasaNo.text = String(masa.masaNo)
            cell.labelGizliMasaId.text = masa.masaId
            if masa.garsonId == "" {
                cell.labelGarsonAd.text = ""
            } else {
                cell.labelGarsonAd.text = garsonGetirByGarsonId(masa.garsonId).garsonAd
            }
            
            return cell
        }
    }
}
