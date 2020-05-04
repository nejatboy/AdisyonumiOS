

import UIKit
import Firebase

class TumRaporlarVC: UIViewController {
    
    @IBOutlet weak var tableViewRaporlar: UITableView!
    
    let referenceGunlukRaporlar = Firestore.firestore().collection("GunlukRaporlar")
    let singleton = Singleton.getInstance
    var tumRaporlar = [Rapor]()
    
    
    
    
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
        
        tableViewRaporlar.delegate = self
        tableViewRaporlar.dataSource = self
        
        tumRaporlariGetir(singleton.loginKasa!.restoranId)
    }
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TumRaporlarVCtoRaporGoruntuleVC" {
            let rapor = sender as! Rapor
            let vc = segue.destination as! RaporGoruntuleVC
            vc.rapor = rapor
        }
    }
    
    
    
    
    func tumRaporlariGetir(_ restoranId:String)  {
        let query = referenceGunlukRaporlar.whereField("restoranId", isEqualTo: restoranId).order(by: "tarih", descending: true)
        query.getDocuments { (querySnapshots, error) in
            if error == nil && querySnapshots != nil {
                self.tumRaporlar.removeAll()
                
                for document in querySnapshots!.documents {
                    let raporId = document.documentID
                    let hesaplar = document.get("hesaplar") as! [String:Double]
                    let garsonSatislari = document.get("garsonSatislari") as! [String:Double]
                    let ciro = document.get("ciro") as! Double
                    let tarih = document.get("tarih") as! Timestamp
                    
                    let rapor = Rapor(raporId, hesaplar, garsonSatislari, tarih.dateValue(), ciro, restoranId)
                    self.tumRaporlar.append(rapor)
                }
                self.tableViewRaporlar.reloadData()
            }
        }
        
    }
    

    

    @IBAction func buttonGeri(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}







// ------------------------------ TableView ----------------------------
extension TumRaporlarVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tumRaporlar.count
    }
    
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tumRaporlar.isEmpty {
            return UITableViewCell()
            
        } else {
            let cell = UITableViewCell()
            let rapor = tumRaporlar[indexPath.row]
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
            let tarihString = dateFormatter.string(from: rapor.tarih)
            
            cell.textLabel!.text = tarihString
            
            return cell
        }
    }
    
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let rapor = tumRaporlar[indexPath.row]
        performSegue(withIdentifier: "TumRaporlarVCtoRaporGoruntuleVC", sender: rapor)
    }
}
