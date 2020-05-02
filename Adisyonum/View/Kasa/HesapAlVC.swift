

import UIKit

class HesapAlVC: UIViewController {
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var labelMasaNo: UILabel!
    @IBOutlet weak var labelKalanTutar: UILabel!
    @IBOutlet weak var textfieldGirilenTutar: UITextField!
    
    var masa:Masa?
    var alinanTutar = 0.0
    var odemeTurleri = [String:Double]()
    var odemeTuru = String()
    
    
    
    
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
        
        if let masa = masa {
            labelMasaNo.text = "Masa: \(masa.masaNo)"
            labelKalanTutar.text = String(masa.masaTutar)
        } else {
            dismiss(animated: true, completion: nil)
        }
        
        segmentedControl.selectedSegmentIndex = 0       //İlk nakit seçilsin
        odemeTuru = "nakit"
        
        hesaplariOlustur()
    }
    
    
    
    
    func hesaplariOlustur() {
        odemeTurleri["nakit"] = 0.0
        odemeTurleri["krediKarti"] = 0.0
        odemeTurleri["multinet"] = 0.0
        odemeTurleri["ticket"] = 0.0
        odemeTurleri["sodexo"] = 0.0
        odemeTurleri["setcard"] = 0.0
        odemeTurleri["metropol"] = 0.0
    }
    
    
    
    
    @IBAction func buttonGeri(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    
    @IBAction func segmentedControl(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            odemeTuru = "nakit"
        } else if sender.selectedSegmentIndex == 1 {
            odemeTuru = "krediKarti"
        } else if sender.selectedSegmentIndex == 2 {
            odemeTuru = "multinet"
        } else if sender.selectedSegmentIndex == 3 {
            odemeTuru = "ticket"
        } else if sender.selectedSegmentIndex == 4 {
            odemeTuru = "sodexo"
        } else if sender.selectedSegmentIndex == 5 {
            odemeTuru = "setcard"
        } else if sender.selectedSegmentIndex == 6 {
            odemeTuru = "metropol"
        }
    }
    
    
    

    @IBAction func buttonTutariAl(_ sender: Any) {
        if let girilenTutarString = textfieldGirilenTutar.text {
            if girilenTutarString == "" {
                toastMesaj("Tutar giriniz.")
            } else if Double(girilenTutarString) == nil {
                toastMesaj("Sayı girişi yapınız.")
            } else {
                if  let girilenTutar = Double(girilenTutarString) {
                    alinanTutar = alinanTutar + girilenTutar
                    labelKalanTutar.text = "\(masa!.masaTutar - alinanTutar)"
                    textfieldGirilenTutar.text = "\(masa!.masaTutar - alinanTutar)"
                    
                    odemeTurleri[odemeTuru] = odemeTurleri[odemeTuru]! + girilenTutar
                    
                    if alinanTutar >= masa!.masaTutar {
                        toastMesaj("HESAP ALINDI")
                        
                        
                        
                        
                    }
                }
            }
        }
    }
    
    
    
}
