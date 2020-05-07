
import Firebase
import UIKit

class MasaTransferiVC: UIViewController {
    
    @IBOutlet weak var buttonAktar: UIButton!
    @IBOutlet weak var pickerViewGarsonlar: UIPickerView!
    
    let scrollView:UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.showsHorizontalScrollIndicator = false
        sv.contentSize = CGSize(width: 200, height: 200)       //Alanı
        return sv
    }()
    
    let referenceMasalar = Firestore.firestore().collection("Masalar")
    var secilenGarson:Garson?
    let singleton = Singleton.getInstance
    var garsonlar = [Garson]()
    var acikMasalar = [Masa]()
    var switchler = [UISwitch]()
    var switchLabellari = [UILabel]()
    
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollViewSetup()
        
        restoraninDigerGarsonlariniGetir()
        
        pickerViewGarsonlar.delegate = self
        pickerViewGarsonlar.dataSource = self
        
        switchleriVeLabellariniOlustur()
        
        switchleriVeLabellariScrollViewaEkle()
    }
    
    
    
    
    func restoraninDigerGarsonlariniGetir() {
        garsonlar.removeAll()
        for garson in singleton.restoranGarsonlari {
            if garson.garsonId != singleton.loginGarson!.garsonId {
                garsonlar.append(garson)
            }
        }
    }
    
    
    
    
    func scrollViewSetup()  {
        view.addSubview(scrollView)
        scrollView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        scrollView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: pickerViewGarsonlar.bottomAnchor, constant: 10).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: buttonAktar.topAnchor, constant: -10).isActive = true
    }
    
    
    
    
    func switchleriVeLabellariniOlustur() {
        if !acikMasalar.isEmpty {
            switchler.removeAll()
            switchLabellari.removeAll()
            
            for masa in acikMasalar {
                let swtch = UISwitch()
                swtch.isOn = false
                swtch.onTintColor = UIColor(named: "colorAccent")
                swtch.translatesAutoresizingMaskIntoConstraints = false
                switchler.append(swtch)
                
                let label = UILabel()
                label.text = "Masa \(masa.masaNo)"
                label.textColor = .black
                label.translatesAutoresizingMaskIntoConstraints = false
                switchLabellari.append(label)
            }
        }
    }
    
    
    
    
    func switchleriVeLabellariScrollViewaEkle() {
        if !acikMasalar.isEmpty {
            var topAnchor:CGFloat = 10
            for i in 0...switchler.count - 1 {
                scrollView.addSubview(switchler[i])
                switchler[i].leftAnchor.constraint(equalTo: scrollView.leftAnchor).isActive = true
                switchler[i].topAnchor.constraint(equalTo: scrollView.topAnchor, constant: topAnchor).isActive = true
                
                scrollView.addSubview(switchLabellari[i])
                switchLabellari[i].leftAnchor.constraint(equalTo: switchler[i].rightAnchor, constant: 10).isActive = true
                switchLabellari[i].centerYAnchor.constraint(equalTo: switchler[i].centerYAnchor).isActive = true
                
                topAnchor = topAnchor + 40
                scrollView.contentSize = CGSize(width: 200, height: topAnchor)
            }
        }
    }
    
    
    
    
    func masayiGarsonaTransferEt(_ masaId:String, _ garsonId:String) {
        var veri = [String:Any]()
        veri["garsonId"] = garsonId
        
        referenceMasalar.document(masaId).setData(veri, merge: true)
    }
    
    
    

    @IBAction func buttonGeri(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    
    @IBAction func buttonAktar(_ sender: Any) {
        if let garson = secilenGarson {
            if acikMasalar.isEmpty {
                toastMesaj("Açık masanız bulunmamaktadır.")
            } else {
                for i in 0...acikMasalar.count - 1 {
                    if switchler[i].isOn {
                        masayiGarsonaTransferEt(acikMasalar[i].masaId, garson.garsonId)
                    }
                }
                dismiss(animated: true, completion: nil)
            }
            
        } else {
            toastMesaj("Garson seçiniz.")
        }
    }
}







// -------------------- PickerView -----------------------------
extension MasaTransferiVC: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return garsonlar.count
    }
    
    
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return garsonlar[row].garsonAd
    }
    
    
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        secilenGarson = garsonlar[row]
    }
}
