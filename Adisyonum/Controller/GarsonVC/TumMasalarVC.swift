

import UIKit
import DropDown
import Firebase

class TumMasalarVC: UIViewController {

    @IBOutlet weak var labelLoginGarson: UILabel!
    @IBOutlet weak var buttonDropDownMenu: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var viewUrunEkle: UIView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var tableViewUrunler: UITableView!
    @IBOutlet weak var tableViewSiparisler: UITableView!
    @IBOutlet weak var pickerViewKategoriler: UIPickerView!
    
    @IBOutlet weak var viewUrunGoruntule: UIView!
    @IBOutlet weak var tableViewUrunGoruntule: UITableView!
    @IBOutlet weak var buttonUrunEkle: UIButton!
    
    let singleton = Singleton.getInstance
    let dropDownMenu:DropDown = {
        let menu = DropDown()
        menu.dataSource = ["Masa Transferi Yap", "Çıkış Yap"]
        return menu
    }()
    
    let referenceMasalar = Firestore.firestore().collection("Masalar")
    var tumMasalar = [Masa]()
    var secilenMasa:Masa?
    
    var urunler = [Urun]()
    var siparisler = [Urun]()
    var kategoriler = [Kategori]()
    
    var goruntulenenUrunler = [Urun]()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        labelLoginGarson.text = singleton.loginGarson!.garsonAd
        kategoriler = singleton.restoranKategorileri
        acikMasalariGetirByRestoranId(singleton.loginGarson!.restoranId)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        hucreTasariminiAyarla()
        
        tableViewUrunler.dataSource = self
        tableViewUrunler.delegate = self
        
        tableViewSiparisler.dataSource = self
        tableViewSiparisler.delegate = self
        
        pickerViewKategoriler.dataSource = self
        pickerViewKategoriler.delegate = self
        
        tableViewUrunGoruntule.delegate = self
        tableViewUrunGoruntule.dataSource = self
        
        
    }
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        veriDegisirseArayuzuGuncelle(singleton.loginGarson!.restoranId)
    }
    
    
    
    
    func masalariOlustur()  {
        if let masaSayisi = singleton.loginRestoran?.masaSayisi {
            for i in 1...masaSayisi {
                let masa = Masa("", i, 0.0, false, false, "", "", [String]())
                tumMasalar.append(masa)
            }
        }
    }
    
    
    
    
    func acikMasalariGetirByRestoranId(_ restoranId:String) {
        tumMasalar.removeAll()
        self.masalariOlustur()
        
        let query = referenceMasalar.whereField("restoranId", isEqualTo: restoranId)
        query.getDocuments { (querySnapshots, error) in
            if querySnapshots != nil {
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
                self.collectionView.reloadData()
            }
        }
    }
    
    
    
    
    func veriDegisirseArayuzuGuncelle(_ restoranId:String) {
        referenceMasalar.whereField("restoranId", isEqualTo: restoranId).addSnapshotListener { (querySnapshots, error) in
            self.acikMasalariGetirByRestoranId(restoranId)
        }
    }
    
    
    
    
    func garsonAdiGetirByGarsonId(_ garsonId:String) -> String {
        for garson in singleton.restoranGarsonlari {
            if garson.garsonId == garsonId {
                return garson.garsonAd
            }
        }
        return ""
    }
    
    
    
    
    func hucreTasariminiAyarla() {
        let tasarim = UICollectionViewFlowLayout()  //Tasarımların çoğunu bunla yaparız
        let genislik = collectionView.frame.size.width  //CollectionView'ın yayıldığı alanın genişliğini aldım
        tasarim.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)   //Hücre ile collectionView arası boşluklar
        tasarim.minimumInteritemSpacing = 10     //yatayda hücreler arası boşluk
        tasarim.minimumLineSpacing = 10  //Dikeyde hücreler arası boşluk
        let hucreKenarUzunluk = (genislik - 40) / 3
        tasarim.itemSize = CGSize(width: hucreKenarUzunluk,  height: hucreKenarUzunluk)
        tasarim.scrollDirection = UICollectionView.ScrollDirection.vertical       // Scroll yönü (Varsayılan olarak vertical zaten, .horizontal diyerek yatay yapabilirsin)
        collectionView.collectionViewLayout = tasarim   //Hazırladığım tasarımı aktardım
    }
    
    
    
    
    func urunleriGetirByKategoriId(_ kategoriId:String) -> [Urun] {
        var urunler = [Urun]()
        for urun in singleton.restoranUrunleri {
            if urun.kategoriId == kategoriId {
                urunler.append(urun)
            }
        }
        return urunler
    }
    
    
    
    
    func urunGetirByUrunId(_ urunId:String) -> Urun {
        for urun in singleton.restoranUrunleri {
            if urun.urunId == urunId {
                return urun
            }
        }
        return Urun("", "", 0.0, "", "")
    }
    
    
    
    
    func masayiVeriTabaninaYaz(_ masa:Masa) {
        progressView.isHidden = false
        
        var urunler = [String]()        //Urun id'leri
        var hesap = 0.0
        for urun in siparisler {
            urunler.append(urun.urunId)
            hesap = hesap + urun.urunFiyat
        }
        
        var veri = [String:Any]()
        veri["masaId"] = ""
        veri["masaNo"] = masa.masaNo
        veri["masaAcik"] = true
        veri["masaTutar"] = hesap
        veri["masaYazdirildi"] = false
        veri["restoranId"] = singleton.loginGarson!.restoranId
        veri["garsonId"] = singleton.loginGarson!.garsonId
        veri["urunler"] = urunler
        
        referenceMasalar.addDocument(data: veri) { (error) in
            if error == nil {
                self.progressView.isHidden = true
                self.siparisler.removeAll()
                self.tableViewSiparisler.reloadData()
                self.viewUrunEkle.isHidden = true
            }
        }
    }
    
    
    
    
    func siparisleriMasayaEkle() {
        progressView.isHidden = false
        var urunler = secilenMasa!.urunler      //id'ler
        var hesap = secilenMasa!.masaTutar
        
        for siparis in siparisler {
            urunler.append(siparis.urunId)
            hesap = hesap + siparis.urunFiyat
        }
        
        var veri = [String:Any]()
        veri["masaTutar"] = hesap
        veri["urunler"] = urunler
        
        referenceMasalar.document(secilenMasa!.masaId).setData(veri, merge: true) { (error) in
            if error == nil {
                self.siparisler.removeAll()
                self.tableViewSiparisler.reloadData()
                self.viewUrunEkle.isHidden = true
                self.progressView.isHidden = true
            }
        }
    }
    
    
    

    @IBAction func buttonDropDownMenu(_ sender: Any) {
        dropDownMenu.anchorView = buttonDropDownMenu
        dropDownMenu.selectionAction = {index, title in
            if index == 0 {     //Masa transefir yap
                let storyboard = UIStoryboard(name: "Dialog", bundle: .main)
                let masaTransferiVC = storyboard.instantiateViewController(withIdentifier: "masaTransferiVC") as! MasaTransferiVC
                self.present(masaTransferiVC, animated: true, completion: nil)
                
            } else if index == 1 {      //Çıkış Yap
                self.dismiss(animated: true, completion: nil)
                self.performSegue(withIdentifier: "fromGarsonVCtoGirisVC", sender: nil)
            }
        }
        dropDownMenu.show()
    }
    
    
    
    
    @IBAction func buttonUrunGoruntuleViewGizle(_ sender: Any) {
        viewUrunGoruntule.isHidden = true
        goruntulenenUrunler.removeAll()
    }
    
    
    
    
    @IBAction func buttonUrunEkleViewGizle(_ sender: Any) {
        viewUrunEkle.isHidden = true
        siparisler.removeAll()
    }
    
    
    
    @IBAction func buttonSiparisleriGonder(_ sender: Any) {
        if secilenMasa!.masaAcik {
            if siparisler.isEmpty {
                alertGoster("Uyarı", "Ürün girişi yapmadınız.")
                
            } else {
                siparisleriMasayaEkle()
            }
            
        } else {
            if siparisler.isEmpty {
                alertGoster("Uyarı", "Ürün girişi yapmadınız.")
                
            } else {
                masayiVeriTabaninaYaz(secilenMasa!)
            }
        }
    }
    
    
    
    
    @IBAction func buttonUrunEkle(_ sender: Any) {
        goruntulenenUrunler.removeAll()
        viewUrunGoruntule.isHidden = true
        viewUrunEkle.isHidden = false
    }
}







// -------------------  CollectionView --------------------
extension TumMasalarVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tumMasalar.count
    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "hucreTumMasalar", for: indexPath) as! HucreTumMasalar
        let masa = tumMasalar[indexPath.item]
        
        if masa.masaAcik && masa.masaYazdirildi {
            cell.backgroundColor = UIColor(named: "yazdirilmisMasaHucreRengi")
        } else if masa.masaAcik {
            cell.backgroundColor = UIColor(named: "doluMasaHucreRengi")
        } else {
            cell.backgroundColor = UIColor(named: "bosMasaHucreRengi")
        }
        
        cell.labelGarsonAd.text = garsonAdiGetirByGarsonId(masa.garsonId)
        cell.labelHesap.text = "\(masa.masaTutar) TL"
        cell.labelMasaNo.text = String(masa.masaNo)
        
        return cell
    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        secilenMasa = tumMasalar[indexPath.item]
        
        if let masa = secilenMasa {
            if masa.masaAcik {
                viewUrunGoruntule.isHidden = false
                goruntulenenUrunler.removeAll()
                for urunId in masa.urunler {
                    goruntulenenUrunler.append(urunGetirByUrunId(urunId))
                }
                tableViewUrunGoruntule.reloadData()
                
                if masa.garsonId == singleton.loginGarson!.garsonId && !masa.masaYazdirildi{       //Masa giriş yapan garsonunsa ve yazdırılmamışsa
                    buttonUrunEkle.isHidden = false
                } else {
                    buttonUrunEkle.isHidden = true
                }
                
            } else {
                viewUrunEkle.isHidden = false
                siparisler.removeAll()
                tableViewSiparisler.reloadData()
            }
        }
    }
}








// -------------------  TableView --------------------
extension TumMasalarVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var veriSayisi:Int = 0
        
        if tableView == tableViewSiparisler {
            veriSayisi = siparisler.count
            
        } else if tableView == tableViewUrunler {
            veriSayisi = urunler.count
            
        } else if tableView == tableViewUrunGoruntule {
            veriSayisi = goruntulenenUrunler.count
        }
        
        return veriSayisi
    }
    
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == tableViewUrunler {
            let cell = tableView.dequeueReusableCell(withIdentifier: "urunlerHucre", for: indexPath) as! HucreUrun
            let urun = urunler[indexPath.row]
            
            cell.labelUrunAd.text = urun.urunAd
            cell.labelUrunFiyat.text = "\(urun.urunFiyat) TL"
            
            return cell
            
        } else if tableView == tableViewSiparisler {
            let cell = tableView.dequeueReusableCell(withIdentifier: "siparislerHucre", for: indexPath) as! HucreSiparis
            let siparis = siparisler[indexPath.row]
            
            cell.labelUrunAd.text = siparis.urunAd
            cell.labelUrunFiyat.text = "\(siparis.urunFiyat) TL"
            
            return cell
            
        } else if tableView == tableViewUrunGoruntule{
            let cell = tableView.dequeueReusableCell(withIdentifier: "goruntulenenUrunlerHucre", for: indexPath) as! HucreGoruntulenenUrun
            let urun = goruntulenenUrunler[indexPath.row]
            
            cell.labelUrunAd.text = urun.urunAd
            cell.labelUrunFiyat.text = "\(urun.urunFiyat) TL"
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == tableViewUrunler {        //Ürünü gönderilecek siparişlere ekle
            let urun = urunler[indexPath.row]
            siparisler.append(urun)
            tableViewSiparisler.reloadData()
            
        } else if tableView == tableViewSiparisler {    //Ürünü gönderilecek siparişlerden çıkar
            siparisler.remove(at: indexPath.row)
            tableViewSiparisler.reloadData()
        }
    }
}








// -------------------  PickerView --------------------
extension TumMasalarVC: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {       //Kaç sütun
        return 1
    }
    
    
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return kategoriler.count
    }
    
    
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? { //Başlıklar için #titleForRow
        return kategoriler[row].kategoriAd
    }
    
    
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        urunler = urunleriGetirByKategoriId(kategoriler[row].kategoriId)
        tableViewUrunler.reloadData()
    }
}
