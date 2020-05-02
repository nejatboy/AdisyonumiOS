

import UIKit

class HesapAlVC: UIViewController {
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var labelMasaNo: UILabel!
    @IBOutlet weak var labelKalanTutar: UILabel!
    @IBOutlet weak var textfieldGirilenTutar: UITextField!
    
    
    
    
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
    }
    
    
    
    
    @IBAction func buttonGeri(_ sender: Any) {
    }
    
    
    
    @IBAction func segmentedControl(_ sender: UISegmentedControl) {
    }
    
    

    @IBAction func buttonTutariAl(_ sender: Any) {
    }
}
