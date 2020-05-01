

import UIKit
import Firebase

class AcikMasalarVC: UIViewController {
    
    @IBOutlet weak var labelLoginGarson: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var viewMasaTasima: UIView!
    @IBOutlet weak var labelTasinacakMasaNo: UILabel!
    @IBOutlet weak var pickerViewMusaitMasalar: UIPickerView!
    
    let singleton = Singleton.getInstance
    let referenceMasalar = Firestore.firestore().collection("Masalar")
    var acikMasalar = [Masa]()
    
    var musaitMasaNumaralari = [Int]()
    var secilenHedefMasaNumarasi:Int?
    var secilenMasaId = String()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        labelLoginGarson.text = singleton.loginGarson!.garsonAd
        acikMasalarimiGetir(singleton.loginGarson!.garsonId)
        
        tableView.delegate = self
        tableView.dataSource = self

        pickerViewMusaitMasalar.delegate = self
        pickerViewMusaitMasalar.dataSource = self
    }
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        veriDegisirseArayuzuGuncelle(singleton.loginGarson!.restoranId)
        
        NotificationCenter.default.addObserver(self, selector: #selector(bildirimiYakala(notification:)), name: .masaTasimasiYapilacak, object: nil)    //HucreAcikMasa'dan gelen bildirimi yakala
    }
    
    
    
    
    func acikMasalarimiGetir(_ garsonId:String) {
        acikMasalar.removeAll()
        
        let query = referenceMasalar.whereField("garsonId", isEqualTo: garsonId).order(by: "masaNo")
        query.addSnapshotListener { (queySnapshots, error) in
            if error == nil && queySnapshots != nil {
                for document in queySnapshots!.documents {
                    let masaId = document.documentID
                    let masaNo = document.get("masaNo") as! Int
                    let masaTutar = document.get("masaTutar") as! Double
                    let masaAcik = document.get("masaAcik") as! Bool
                    let masaYazdirildi = document.get("masaYazdirildi") as! Bool
                    let garsonId = document.get("garsonId") as! String
                    let urunler = document.get("urunler") as! [String]
                    let restoranId = document.get("restoranId") as! String
                
                    let masa = Masa(masaId, masaNo, masaTutar, masaAcik, masaYazdirildi, garsonId, restoranId, urunler)
                    self.acikMasalar.append(masa)
                }
                self.tableView.reloadData()
            }
        }
    }
    
    
    
    
    func musaitMasalariGetir(_ restoranId:String)  {
        musaitMasaNumaralari.removeAll()
        let query = referenceMasalar.whereField("restoranId", isEqualTo: restoranId)
        
        query.getDocuments { (querySnapshots, error) in
            if error == nil && querySnapshots != nil {
                var doluMasaNumaralari = [Int]()
                
                for document in querySnapshots!.documents {
                    let masaNo = document.get("masaNo") as! Int
                    doluMasaNumaralari.append(masaNo)
                }
                
                if let masaSayisi = self.singleton.loginRestoran?.masaSayisi {
                    for i in 1...masaSayisi {
                        if !doluMasaNumaralari.contains(i) {
                            self.musaitMasaNumaralari.append(i)
                        }
                    }
                }
                self.pickerViewMusaitMasalar.reloadAllComponents()
            }
        }
    }
    
    
    
    
    func veriDegisirseArayuzuGuncelle(_ restoranId:String) {
        referenceMasalar.whereField("restoranId", isEqualTo: restoranId).addSnapshotListener { (querySnapshot, error) in
            self.acikMasalarimiGetir(self.singleton.loginGarson!.garsonId)
        }
    }
    
    
    
    
    func masaGetirByMasaId(_ masaId:String) -> Masa{
        for masa in acikMasalar {
            if masa.masaId == masaId {
                return masa
            }
        }
        return Masa("", 0, 0.0, false, false, "", "", [String]())
    }
    
    
    
    
    func masaNumarasiniDegistir(_ masaId:String, _ masaNo:Int) {
        var veri = [String:Any]()
        veri["masaNo"] = masaNo
        referenceMasalar.document(masaId).setData(veri, merge: true) { (error) in
            if error == nil {
                self.viewMasaTasima.isHidden = true
                self.secilenHedefMasaNumarasi = nil
            }
        }
    }
    
    
    
    
    @objc func bildirimiYakala(notification:NSNotification) {
        secilenMasaId = notification.userInfo!["masaId"] as! String
        musaitMasalariGetir(singleton.loginGarson!.restoranId)
        viewMasaTasima.isHidden = false
        let secilenMasaNo = masaGetirByMasaId(secilenMasaId).masaNo
        labelTasinacakMasaNo.text = "Masa: \(secilenMasaNo)"
    }

    
    
    
    @IBAction func buttonMasayiTasi(_ sender: Any) {
        if let hedefMasaNo = secilenHedefMasaNumarasi {
            masaNumarasiniDegistir(secilenMasaId, hedefMasaNo)
        }
    }
    
    
    
    
    @IBAction func buttonMasaTasimaViewGizle(_ sender: Any) {
        viewMasaTasima.isHidden = true
    }
    
    
}





// ------------------------------ TableView --------------------
extension AcikMasalarVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return acikMasalar.count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "hucreAcikMasa", for: indexPath) as! HucreAcikMasa
        
        if acikMasalar.count > 0 {
            let masa = acikMasalar[indexPath.row]
            if masa.masaYazdirildi {
                cell.backgroundColor = UIColor(named: "yazdirilmisMasaHucreRengi")
            } else {
                cell.backgroundColor = UIColor(named: "bosMasaHucreRengi")
            }
            
            cell.labelMasaNo.text = "Masa: \(masa.masaNo)"
            cell.labelHesap.text = "\(masa.masaTutar) TL"
            cell.labelGizliMasaId.text = masa.masaId
        }
        
        return cell
    }
}






// ------------------------ PickerView -------------------------------
extension AcikMasalarVC: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return musaitMasaNumaralari.count
    }
    
    
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(musaitMasaNumaralari[row])"
    }
    
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        secilenHedefMasaNumarasi = musaitMasaNumaralari[row]
    }
}








