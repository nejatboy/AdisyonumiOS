

import UIKit
import DropDown

class HucreMasa_KasaVC: UICollectionViewCell {
    
    @IBOutlet weak var labelMasaNo: UILabel!
    @IBOutlet weak var labelGarsonAd: UILabel!
    @IBOutlet weak var labelHesap: UILabel!
    @IBOutlet weak var labelGizliMasaId: UILabel!
    @IBOutlet weak var buttonMenuAc: UIButton!
    
    let dropDownMenu:DropDown = {
           let menu = DropDown()
           menu.dataSource = ["Adisyonu Yazdır / Geri Al", "Hesabı Al"]
           return menu
       }()
    
    
    
    
    override func awakeFromNib() {
        layer.cornerRadius = 10
    }
    
    
    
    @IBAction func buttonMenuAc(_ sender: Any) {
        if let masaId = labelGizliMasaId.text {
            dropDownMenu.anchorView = buttonMenuAc
            dropDownMenu.selectionAction = {index, title in
                if index == 0 {     //Adisyon Yazdır / Geri Al
                    NotificationCenter.default.post(name: .adisyonuYazdir, object: nil, userInfo: ["masaId":masaId])
                    
                } else if index == 1 {      //Hesabı Al
                    NotificationCenter.default.post(name: .hesabiAl, object: nil, userInfo: ["masaId":masaId])
                    
                }
            }
            dropDownMenu.show()
        }
    }
}
