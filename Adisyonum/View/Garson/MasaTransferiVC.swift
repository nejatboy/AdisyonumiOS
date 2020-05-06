

import UIKit

class MasaTransferiVC: UIViewController {
    
    @IBOutlet weak var buttonAktar: UIButton!
    @IBOutlet weak var pickerViewGarsonlar: UIPickerView!
    
    let scrollView:UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.backgroundColor = .red
        sv.showsHorizontalScrollIndicator = false
        sv.contentSize = CGSize(width: 100, height: 100)       //Alanı
        return sv
    }()
    
    var garsonlar = [Garson]()
    let singleton = Singleton.getInstance
    
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        scrollViewSetup()
        
        restoraninDigerGarsonlariniGetir()
        
        pickerViewGarsonlar.delegate = self
        pickerViewGarsonlar.dataSource = self
        
        
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
    
    
    

    @IBAction func buttonGeri(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    
    @IBAction func buttonAktar(_ sender: Any) {
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
        let garson = garsonlar[row]
        print(garson.garsonAd)
    }
}
