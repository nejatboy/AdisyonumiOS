

import UIKit
import Firebase
import DropDown

class RestoranlarVC: UIViewController {

    @IBOutlet weak var tableViewRestoranlar: UITableView!
    @IBOutlet weak var buttonToolbarMenuAc: UIButton!
    
    @IBOutlet weak var viewRestoranEkleDuzenle: DialogView!
    @IBOutlet weak var labelDialogEylem: UILabel!
    @IBOutlet weak var textfieldRestoranAd: UITextField!
    @IBOutlet weak var textFieldKasaKullaniciAdi: UITextField!
    @IBOutlet weak var textFieldMasaSayisi: UITextField!
    @IBOutlet weak var textFieldKasaSifre: UITextField!
    
    var restoranlar = [Restoran]()
    let referenceRestoranlar = Firestore.firestore().collection("Restoranlar")
    
    let dropDownMenu:DropDown = {
        let menu = DropDown()
        menu.dataSource = ["Çıkış Yap"]
        return menu
    }()
    
    var dialogEylem = ""
    var secilenRestoranId = ""
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableViewRestoranlar.delegate = self
        tableViewRestoranlar.dataSource = self

        
    }
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        restoranlariGetir()
        
        NotificationCenter.default.addObserver(self, selector: #selector(bildirimYakalaRestoranKoduKopyala(notification:)), name: .restoranKoduKopyalama, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(bildirimYakalaRestoranSil(notification:)), name: .restoraniSil, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(bildirimYakalaRestoranDuzenle(notification:)), name: .restoraniDuzenle, object: nil)
    }
    
    
    
    
    func restoranlariGetir() {
        guard let yoneticiId = Auth.auth().currentUser?.uid else {return}
        
        referenceRestoranlar.whereField("yoneticiId", isEqualTo: yoneticiId).addSnapshotListener{ (querySnapshots, error) in
            if error == nil && querySnapshots != nil{
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
                self.tableViewRestoranlar.reloadData()
            }
        }
    }
    
    
    
    
    func degisiklikOlursaArayuzuGuncelle() {
        guard let yoneticiId = Auth.auth().currentUser?.uid else {return}
        referenceRestoranlar.whereField("yoneticiId", isEqualTo: yoneticiId).addSnapshotListener { (querySnapshots, error) in
            self.restoranlariGetir()
        }
    }
    
    
    
    
    func restoraniGetirByResotanId(_ restoranId:String) -> Restoran {
        for restoran in restoranlar {
            if restoran.restoranId == restoranId {
                return restoran
            }
        }
        return Restoran("", "", "", "", "", 0)
    }
    
    
    
    
    func cikisYap() {
        do {
            try Auth.auth().signOut()
            dismiss(animated: false, completion: nil)
            performSegue(withIdentifier: "fromYoneticiVCtoGirisVC", sender: nil)
        } catch  {
            toastMesaj(error.localizedDescription)
        }
    }
    
    
    
    func restoranEkle(_ restoran:Restoran)  {
        var veri = [String:Any]()
        veri["restoranId"] = ""
        veri["restoranAd"] = restoran.restoranAd
        veri["kasaKullaniciAdi"] = restoran.kasaKullaniciAdi
        veri["kasaSifre"] = restoran.kasaSifre
        veri["masaSayisi"] = restoran.masaSayisi
        veri["yoneticiId"] = restoran.yoneticiId
        
        referenceRestoranlar.addDocument(data: veri) { (error) in
            if error == nil {
                self.toastMesaj("Restoran Eklendi.")
                self.restoranlariGetir()
            } else {
                self.toastMesaj(error!.localizedDescription)
            }
        }
    }
    
    
    
    
    func restoraniGuncelle(_ restoran:Restoran) {
        var veri = [String:Any]()
        veri["restoranAd"] = restoran.restoranAd
        veri["kasaKullaniciAdi"] = restoran.kasaKullaniciAdi
        veri["kasaSifre"] = restoran.kasaSifre
        veri["masaSayisi"] = restoran.masaSayisi
        
        referenceRestoranlar.document(restoran.restoranId).setData(veri, merge: true) { (error) in
            if error == nil {
                self.toastMesaj("Restoran Güncellendi.")
                self.restoranlariGetir()
                self.secilenRestoranId = ""
            } else {
                self.toastMesaj(error!.localizedDescription)
            }
        }
    }
    
    
    
    
    @objc func bildirimYakalaRestoranKoduKopyala (notification:NSNotification) {
        if let restoranId = notification.userInfo!["restoranId"] as? String {
            UIPasteboard.general.string = restoranId
            toastMesaj("Restoran kodu kopyalandı.")
        }
        
    }
    
    
    
    
    @objc func bildirimYakalaRestoranSil (notification:NSNotification) {
        if let restoranId = notification.userInfo!["restoranId"] as? String {
            toastMesaj("Restoran Silinecek: \(restoranId)")
        }
    }
    
    
    
    
    @objc func bildirimYakalaRestoranDuzenle (notification:NSNotification) {
        if let restoranId = notification.userInfo!["restoranId"] as? String {
            let restoran = restoraniGetirByResotanId(restoranId)
            secilenRestoranId = restoranId
            
            labelDialogEylem.text = "Restoranı Düzenle"
            textfieldRestoranAd.text = restoran.restoranAd
            textFieldMasaSayisi.text = String(restoran.masaSayisi)
            textFieldKasaSifre.text = restoran.kasaSifre
            textFieldKasaKullaniciAdi.text = restoran.kasaKullaniciAdi
            viewRestoranEkleDuzenle.isHidden = false
            dialogEylem = "duzenleme"
        }
    }
    

    
    
    @IBAction func buttonRestoranEkle(_ sender: Any) {
        labelDialogEylem.text = "Restoran Ekle"
        textfieldRestoranAd.text = ""
        textFieldMasaSayisi.text = ""
        textFieldKasaSifre.text = ""
        textFieldKasaKullaniciAdi.text = ""
        viewRestoranEkleDuzenle.isHidden = false
        dialogEylem = "ekleme"
    }
    
    
    
    
    @IBAction func buttonRestoranEkleDuzenleOnay(_ sender: Any) {
        if let restoranAd = textfieldRestoranAd.text, let kasaSifre = textFieldKasaSifre.text, let kasaKullaniciAdi = textFieldKasaKullaniciAdi.text, let masaSayisi = textFieldMasaSayisi.text {
            if restoranAd == "" || kasaSifre == "" || kasaKullaniciAdi == "" || masaSayisi == "" {
                toastMesaj("Bilgiler boş bırakılamaz.")
            } else {
                if let _ = Int(kasaSifre), let masaSayisiInt = Int(masaSayisi) {
                    if dialogEylem == "duzenleme" {
                        let restoran = Restoran(secilenRestoranId, restoranAd, Auth.auth().currentUser!.uid, kasaKullaniciAdi, kasaSifre, masaSayisiInt)
                        restoraniGuncelle(restoran)
                        viewRestoranEkleDuzenle.isHidden = true
                        
                    } else if dialogEylem == "ekleme" {
                        let restoran = Restoran("", restoranAd, Auth.auth().currentUser!.uid, kasaKullaniciAdi, kasaSifre, masaSayisiInt)
                        restoranEkle(restoran)
                        viewRestoranEkleDuzenle.isHidden = true
                    }
                    
                } else {
                    toastMesaj("Kasa şifresi ve masa sayısı rakamlardan oluşmalıdır.")
                }
            }
        }
    }
    
    
    
    
    
    @IBAction func buttonViewRestoranEkleDuzenleGizle(_ sender: Any) {
        viewRestoranEkleDuzenle.isHidden = true
    }
    
    
    
    
    @IBAction func buttonToolbarMenuAc(_ sender: Any) {
        dropDownMenu.anchorView = buttonToolbarMenuAc
        dropDownMenu.selectionAction = {index, title in
            if index == 0 {     //Çıkış Yap
                self.cikisYap()
            }
        }
        dropDownMenu.show()
    }
}






// --------------------------- TableView ---------------------------------
extension RestoranlarVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return restoranlar.count
    }
    
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "hucreRestoran", for: indexPath) as! HucreRestoran
        let restoran = restoranlar[indexPath.row]
        
        cell.labelRestoranAdi.text = restoran.restoranAd
        cell.labelGizliRestoranId.text = restoran.restoranId
        
        return cell
    }
}
