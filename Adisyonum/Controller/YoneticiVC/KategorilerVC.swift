

import UIKit
import Firebase

class KategorilerVC: UIViewController {
    
    @IBOutlet weak var tableViewKategoriler: UITableView!
    @IBOutlet weak var pickerViewRestoranlar: UIPickerView!
    
    let referenceRestoranlar = Firestore.firestore().collection("Restoranlar")
    let referenceKategoriler = Firestore.firestore().collection("Kategoriler")
    var restoranlar = [Restoran]()
    var kategoriler = [Kategori]()
    var secilenRestoran:Restoran?
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableViewKategoriler.delegate = self
        tableViewKategoriler.dataSource = self
        
        pickerViewRestoranlar.delegate = self
        pickerViewRestoranlar.dataSource = self

    }
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        restoranlariGetir()
        
        NotificationCenter.default.addObserver(self, selector: #selector(bildirimYakalaKategoriyiSil(notification:)), name: .kategoriyiSil, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(bildirimYakalaKategoriyiDuzenle(notification:)), name: .kategoriyiDuzenle, object: nil)
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
                self.tableViewKategoriler.reloadData()
            }
        }
    }
    
    
    
    
    func kategoriyiGetirByKategoriId(_ kategoriId:String) -> Kategori {
        var kategori:Kategori?
        for k in kategoriler {
            if k.kategoriId == kategoriId {
                kategori = k
                break
            }
        }
        return kategori!
    }
    
    
    
    
    func kategoriyiSil(_ kategoriId:String) {
        referenceKategoriler.document(kategoriId).delete()
    }
    
    
    
    
    @objc func bildirimYakalaKategoriyiDuzenle (notification:NSNotification) {
        if let kategoriId = notification.userInfo!["kategoriId"] as? String {
            let storyboard = UIStoryboard(name: "Dialog", bundle: .main)
            let kategoriEkleVC = storyboard.instantiateViewController(withIdentifier: "kategoriEkleVC") as! KategoriEkleVC
            
            let kategori = kategoriyiGetirByKategoriId(kategoriId)
            kategoriEkleVC.eylem = "Kategoriyi Düzenle"
            kategoriEkleVC.duzenlenecekKategori = kategori
            present(kategoriEkleVC, animated: true, completion: nil)
        }
    }
    
    
    
    
    @objc func bildirimYakalaKategoriyiSil (notification:NSNotification) {
        if let kategoriId = notification.userInfo!["kategoriId"] as? String {
            let alert = UIAlertController(title: "Silinecek", message: "Seçilen kategori silinecek. Emin misiniz?", preferredStyle: UIAlertController.Style.alert)
            let iptalButton = UIAlertAction(title: "İptal", style: .cancel, handler: nil)
            let silButton = UIAlertAction(title: "Sil", style: .destructive) { (alertAction) in
                self.kategoriyiSil(kategoriId)
            }
            alert.addAction(silButton)
            alert.addAction(iptalButton)
            present(alert, animated: true, completion: nil)
        }
    }
    

    
    
    @IBAction func buttonKategoriEkle(_ sender: Any) {
        if let restoranId = secilenRestoran?.restoranId {
            let storyboard = UIStoryboard(name: "Dialog", bundle: .main)
            let kategoriEkleVC = storyboard.instantiateViewController(withIdentifier: "kategoriEkleVC") as! KategoriEkleVC
            
            kategoriEkleVC.eklenecekRestoranId = restoranId
            kategoriEkleVC.eylem = "Kategori Ekle"
            present(kategoriEkleVC, animated: true, completion: nil)
            
        } else {
            toastMesaj("Restoran seçimi yapınız.")
        }
    }
    
}






// -------------------------- TableView ----------------------------
extension KategorilerVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return kategoriler.count
    }
    
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "hucreKategori", for: indexPath) as! HucreKategori
        
        if kategoriler.isEmpty {
            return UITableViewCell()
            
        } else {
            let kategori = kategoriler[indexPath.row]
            cell.labelKategoriAd.text = kategori.kategoriAd
            cell.labelGizliKategoriId.text = kategori.kategoriId
            return cell
        }
    }
}







// -------------------------- PickerView ----------------------------
extension KategorilerVC: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return restoranlar.count
    }
    
    
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return restoranlar[row].restoranAd
    }
    
    
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        secilenRestoran = restoranlar[row]
        kategorileriGetirByRestoranId(secilenRestoran!.restoranId)
    }
}



