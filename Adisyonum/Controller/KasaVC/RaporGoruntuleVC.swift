

import UIKit

class RaporGoruntuleVC: UIViewController {
    
    @IBOutlet weak var labelNakit: UILabel!
    @IBOutlet weak var labelKrediKarti: UILabel!
    @IBOutlet weak var labelMultinet: UILabel!
    @IBOutlet weak var labelTicket: UILabel!
    @IBOutlet weak var labelSodexo: UILabel!
    @IBOutlet weak var labelSetcard: UILabel!
    @IBOutlet weak var labelMetropol: UILabel!
    @IBOutlet weak var labelToplam: UILabel!
    
    var rapor:Rapor?
    let viewRight = UIView()
    
    
    
    
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
        
        if let rapor = rapor {
            hesaplariGoster(rapor)
            viewRightOlusturr()
            garsonSatislariniGoster(rapor)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
            let tarihString = dateFormatter.string(from: rapor.tarih)
            navigationItem.title = tarihString
        }
    }
    
    
    
    
    func hesaplariGoster(_ rapor:Rapor) {
        let hesaplar = rapor.hesaplar
        labelNakit.text = "Nakit: \(hesaplar["nakit"]!)"
        labelKrediKarti.text = "Kredi Kartı: \(hesaplar["krediKarti"]!)"
        labelMultinet.text = "Multinet \(hesaplar["multinet"]!)"
        labelTicket.text = "Ticket: \(hesaplar["ticket"]!)"
        labelSodexo.text = "Sodexo: \(hesaplar["sodexo"]!)"
        labelSetcard.text = "Setcard: \(hesaplar["setcard"]!)"
        labelMetropol.text = "Metropol: \(hesaplar["metropol"]!)"
        labelToplam.text = "Toplam: \(rapor.ciro)"
    }
    
    
    
    
    func garsonSatislariniGoster(_ rapor:Rapor) {
        let garsonSatislari = rapor.garsonSatislari
        var bottomAnchor:CGFloat = -20
        for garson in Singleton.getInstance.restoranGarsonlari {
            if garsonSatislari[garson.garsonId] != nil {
                labelOlustur("\(garson.garsonAd) : \(garsonSatislari[garson.garsonId]!)", bottomAnchor: bottomAnchor)
            } else {
                labelOlustur("\(garson.garsonAd) : 0.0", bottomAnchor: bottomAnchor)
            }
            
            bottomAnchor = bottomAnchor - 20
        }
    }
    
    
    
    
    func labelOlustur(_ yazi:String, bottomAnchor:CGFloat) {
        let label = UILabel()
        self.view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.leftAnchor.constraint(equalTo: viewRight.leftAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: bottomAnchor).isActive = true
        label.textAlignment = .left
        label.textColor = UIColor.black
        label.text = yazi
    }
    
    
    
    
    func viewRightOlusturr()  {     //Ekranın sağından başlayıp
        self.view.addSubview(viewRight)
        viewRight.translatesAutoresizingMaskIntoConstraints = false
        viewRight.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        viewRight.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        viewRight.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        viewRight.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.3).isActive = true
    }
    

    

}
