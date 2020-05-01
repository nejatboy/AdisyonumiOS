
import UIKit
import Firebase



class GarsonlarVC: UIViewController {
    
    let referenceRestoranlar = Firestore.firestore().collection("Restoranlar")
    let referenceGarsonlar = Firestore.firestore().collection("Garsonlar")

    @IBOutlet weak var pickerViewRestoranlar: UIPickerView!
    @IBOutlet weak var tableViewGarsonlar: UITableView!
    
    var garsonlar = [Garson]()
    var restoranlar = [Restoran]()
    var secilenRestoran:Restoran?
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        pickerViewRestoranlar.delegate = self
        pickerViewRestoranlar.dataSource = self
        
        tableViewGarsonlar.delegate = self
        tableViewGarsonlar.dataSource = self
    }
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        restoranlariGetir()
        
        NotificationCenter.default.addObserver(self, selector: #selector(bildirimYakalaGarsonuDuzenle(notification:)), name: .garsonuDuzenle, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(bildirimYakalaGarsonuSil(notification:)), name: .garsonuSil, object: nil)
    }
    
    
    
    
    func restoranlariGetir() {
        restoranlar.removeAll()
        guard let yoneticiId = Auth.auth().currentUser?.uid else {return}
        
        referenceRestoranlar.whereField("yoneticiId", isEqualTo: yoneticiId).getDocuments { (querySnapshots, error) in
            if error == nil {
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
    
    
    
    
    func garsonlariGetirByRestoranId(_ restoranId:String)  {
        let query = referenceGarsonlar.whereField("restoranId", isEqualTo: restoranId)
        
        query.addSnapshotListener { (querySnapshots, error) in
            if error == nil && querySnapshots != nil {
                self.garsonlar.removeAll()
                for document in querySnapshots!.documents {
                    let garsonId = document.documentID
                    let garsonAd = document.get("garsonAd") as! String
                    let garsonKullaniciAd = document.get("garsonKullaniciAd") as! String
                    let garsonSifre = document.get("garsonSifre") as! String
                    
                    let garson = Garson(garsonId, garsonAd, garsonKullaniciAd, garsonSifre, restoranId)
                    self.garsonlar.append(garson)
                }
                self.tableViewGarsonlar.reloadData()
            }
        }
    }
    
    
    
    
    func garsonGetirByGarsonId(_ garsonId:String) -> Garson {
        var garson:Garson?
        for g in garsonlar{
            if g.garsonId == garsonId {
                garson = g
                break
            }
        }
        return garson!
    }
    
    
    
    
    func garsonuSil(_ garsonId:String) {
        referenceGarsonlar.document(garsonId).delete()
    }
    
    
    
    
    @objc func bildirimYakalaGarsonuSil (notification:NSNotification) {
        if let garsonId = notification.userInfo!["garsonId"] as? String {
            let alert = UIAlertController(title: "Silinecek", message: "Seçilen garson silinecek. Emin misiniz?", preferredStyle: UIAlertController.Style.alert)
            let iptalButton = UIAlertAction(title: "İptal", style: .cancel, handler: nil)
            let silButton = UIAlertAction(title: "Sil", style: .destructive) { (alertAction) in
                self.garsonuSil(garsonId)
            }
            alert.addAction(silButton)
            alert.addAction(iptalButton)
            present(alert, animated: true, completion: nil)
        }
    }
    
    
    
    
    @objc func bildirimYakalaGarsonuDuzenle(notification:NSNotification) {
        if let garsonId = notification.userInfo!["garsonId"] as? String {
            let storyboard = UIStoryboard(name: "Dialog", bundle: .main)
            let garsonEkleVC = storyboard.instantiateViewController(withIdentifier: "garsonEkleVC") as! GarsonEkleVC
            
            let garson = garsonGetirByGarsonId(garsonId)
            garsonEkleVC.eylem = "Garsonu Düzenle"
            garsonEkleVC.duzenlenecekGarson = garson
            present(garsonEkleVC, animated: true, completion: nil)
        }
    }
    
    
    
    
    @IBAction func buttonGarsonEkle(_ sender: Any) {
        if let restoranId = secilenRestoran?.restoranId {
            let storyboard = UIStoryboard(name: "Dialog", bundle: .main)
            let garsonEkleVC = storyboard.instantiateViewController(withIdentifier: "garsonEkleVC") as! GarsonEkleVC
            garsonEkleVC.eylem = "Garson Ekle"
            garsonEkleVC.eklenecekRestoranId = restoranId
            present(garsonEkleVC, animated: true, completion: nil)
        } else {
            toastMesaj("Restoran seçimi yapınız.")
        }
        
    }
}








// ------------------------ TableView--------------------------------
extension GarsonlarVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return garsonlar.count
    }
    
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "hucreGarson", for: indexPath) as! HucreGarson
        
        if !garsonlar.isEmpty {
            let garson = garsonlar[indexPath.row]
            cell.labelGarsonAd.text = garson.garsonAd
            cell.labelGizliGarsonId.text = garson.garsonId
            
        } else {
            return UITableViewCell()
        }
        
        return cell
    }
}









// ------------------------ PickerView --------------------------------
extension GarsonlarVC: UIPickerViewDelegate, UIPickerViewDataSource {
    
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
        let restoran = restoranlar[row]
        secilenRestoran = restoran
        garsonlariGetirByRestoranId(restoran.restoranId)
    }
}
