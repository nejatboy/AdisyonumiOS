

import UIKit
import Firebase

class UrunlerVC: UIViewController {

    @IBOutlet weak var pickerViewRestoranlar: UIPickerView!
    @IBOutlet weak var pickerViewKategoriler: UIPickerView!
    @IBOutlet weak var tableViewUrunler: UITableView!
    
    let referenceRestoranlar = Firestore.firestore().collection("Restoranlar")
    let referenceKategoriler = Firestore.firestore().collection("Kategoriler")
    let referenceUrunler = Firestore.firestore().collection("Urunler")
    
    var restoranlar = [Restoran]()
    var kategoriler = [Kategori]()
    var urunler = [Urun]()
    var secilenRestoranId:String?
    var secilenKategoriId:String?
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerViewRestoranlar.dataSource = self
        pickerViewRestoranlar.delegate = self
        
        pickerViewKategoriler.dataSource = self
        pickerViewKategoriler.delegate = self
        
        tableViewUrunler.delegate = self
        tableViewUrunler.dataSource = self
        
    }
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        restoranlariGetir()
        
        NotificationCenter.default.addObserver(self, selector: #selector(bildirimYakalaUrunSil(notification:)), name: .urunuSil, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(bildirimYakalaUrunDuzenle(notification:)), name: .urunuDuzenle, object: nil)
    }
    
    
    
    
    func restoranlariGetir() {
        guard let yoneticiId = Auth.auth().currentUser?.uid else {return}
        
        referenceRestoranlar.whereField("yoneticiId", isEqualTo: yoneticiId).getDocuments { (querySnapshots, error) in
            if error == nil {
                self.restoranlar.removeAll()
                
                for document in querySnapshots!.documents {
                    let restoranId = document.documentID
                    let restoranAd = document.get("restoranAd") as! String
                    let kasaKullaniciAdi = document.get("kasaKullaniciAdi") as! String
                    let kasaSifre = document.get("kasaSifre") as! String
                    let masaSayisi = document.get("masaSayisi") as! Int
                    
                    let restoran = Restoran(restoranId, restoranAd, yoneticiId, kasaKullaniciAdi, kasaSifre, masaSayisi)
                    self.restoranlar.append(restoran)
                }
                self.pickerViewRestoranlar.reloadAllComponents()
            }
        }
    }
    
    
    
    
    func kategorileriGetirByRestoranId(_ restoranId:String) {
        referenceKategoriler.whereField("restoranId", isEqualTo: restoranId).addSnapshotListener { (queySnapshots, error) in
            if error == nil && queySnapshots != nil {
                self.kategoriler.removeAll()
                
                for document in queySnapshots!.documents {
                    let kategoriId = document.documentID
                    let kategoriAd = document.get("kategoriAd") as! String
                    
                    let kategori = Kategori(kategoriId, kategoriAd, restoranId)
                    self.kategoriler.append(kategori)
                }
                self.pickerViewKategoriler.reloadAllComponents()
            }
        }
    }
    
    
    
    
    func urunleriGetirByKategoriId(_ kategoriId:String) {
        referenceUrunler.whereField("kategoriId", isEqualTo: kategoriId).addSnapshotListener { (queySnapshots, error) in
            if error == nil && queySnapshots != nil {
                self.urunler.removeAll()
                
                for document in queySnapshots!.documents {
                    let urunId = document.documentID
                    let urunAd = document.get("urunAd") as! String
                    let urunFiyat = document.get("urunFiyat") as! Double
                    let restoranId = document.get("restoranId") as! String
                    
                    let urun = Urun(urunId, urunAd, urunFiyat, kategoriId, restoranId)
                    self.urunler.append(urun)
                }
                
                self.tableViewUrunler.reloadData()
            }
        }
    }
    
    
    
    
    func urunuSil(_ urunId:String) {
        referenceUrunler.document(urunId).delete()
    }
    
    
    
    
    func urunGetirByUrunId(_ urunId:String) -> Urun {
        var urun:Urun?
        for u in urunler {
            if u.urunId == urunId {
                urun = u
                break
            }
        }
        return urun!
    }
    
    
    
    
    @objc func bildirimYakalaUrunSil (notification:NSNotification) {
        if let urunId = notification.userInfo!["urunId"] as? String {
            let alert = UIAlertController(title: "Silinecek", message: "Seçilen ürün silinecek. Emin misiniz?", preferredStyle: UIAlertController.Style.alert)
            let iptalButton = UIAlertAction(title: "İptal", style: .cancel, handler: nil)
            let silButton = UIAlertAction(title: "Sil", style: .destructive) { (alertAction) in
                self.urunuSil(urunId)
            }
            alert.addAction(silButton)
            alert.addAction(iptalButton)
            present(alert, animated: true, completion: nil)
        }
    }
    
    
    
    
    @objc func bildirimYakalaUrunDuzenle (notification:NSNotification) {
        if let urunId = notification.userInfo!["urunId"] as? String {
            let storyboard = UIStoryboard(name: "Dialog", bundle: .main)
            let urunEkleVC = storyboard.instantiateViewController(withIdentifier: "urunEkleVC") as! UrunEkleVC
            
            let urun = urunGetirByUrunId(urunId)
            urunEkleVC.duzenlenecekUrun = urun
            urunEkleVC.eylem = "Ürünü Düzenle"
            present(urunEkleVC, animated: true, completion: nil)
        }
    }
    

    

    @IBAction func buttonUrunEkle(_ sender: Any) {
        if let restoranId = secilenRestoranId {
            if let kategoriId = secilenKategoriId {
                let storyboard = UIStoryboard(name: "Dialog", bundle: .main)
                let urunEkleVC = storyboard.instantiateViewController(withIdentifier: "urunEkleVC") as! UrunEkleVC
                
                urunEkleVC.eylem = "Ürün Ekle"
                urunEkleVC.eklenecekRestoranId = restoranId
                urunEkleVC.eklenecekKategoriId = kategoriId
                present(urunEkleVC, animated: true, completion: nil)
                
            } else {
                toastMesaj("Kategori seçimi yapınız")
            }
        } else {
            toastMesaj("Restoran seçimi yapınız.")
        }
    }
    
    
}






// ---------------------------- PickerView ------------------------------
extension UrunlerVC: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == pickerViewRestoranlar {
            return restoranlar.count
        } else {
            return kategoriler.count
        }
    }
    
    
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == pickerViewRestoranlar {
            return restoranlar[row].restoranAd
        } else {
            return kategoriler[row].kategoriAd
        }
    }
    
    
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == pickerViewRestoranlar {
            kategorileriGetirByRestoranId(restoranlar[row].restoranId)
            secilenRestoranId = restoranlar[row].restoranId
            
        } else if pickerView == pickerViewKategoriler {
            if kategoriler.isEmpty {
                urunler.removeAll()
                tableViewUrunler.reloadData()
            } else {
                urunleriGetirByKategoriId(kategoriler[row].kategoriId)
                secilenKategoriId = kategoriler[row].kategoriId
            }
            
        }
    }
}









// ---------------------------- TableView ------------------------------
extension UrunlerVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return urunler.count
    }
    
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if urunler.isEmpty {
            return UITableViewCell()
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "hucreUrun_Yonetici", for: indexPath) as! HucreUrun_Yonetici
            let urun = urunler[indexPath.row]
            cell.labelUrunAd.text = urun.urunAd
            cell.labelGizliUrunId.text = urun.urunId
            cell.labelUrunFiyat.text = "\(urun.urunFiyat) TL"
            return cell
        }
    }
}
