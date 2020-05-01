

import UIKit
import Firebase

class KasaVC: UIViewController {
    
    @IBOutlet weak var collectionViewMasalar: UICollectionView!
    
    let referenceMasalar = Firestore.firestore().collection("Masalar")
    let singleton = Singleton.getInstance
    var tumMasalar = [Masa]()
    
    
    
    
    
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
    }
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        masalariGetir(singleton.loginKasa!.restoranId)
        
        NotificationCenter.default.addObserver(self, selector: #selector(bildirimYakalaHesabiAl(notification:)), name: .hesabiAl, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(bildirimYakalaAdisyonuYazdir(notification:)), name: .adisyonuYazdir, object: nil)
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
            toastMesaj("Hesap alınır \(masaId)")
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
