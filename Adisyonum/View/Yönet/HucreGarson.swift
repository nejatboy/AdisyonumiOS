

import UIKit
import DropDown

class HucreGarson: UITableViewCell {

    @IBOutlet weak var labelGarsonAd: UILabel!
    @IBOutlet weak var labelGizliGarsonId: UILabel!
    @IBOutlet weak var buttonMenuAc: UIButton!
    
    let dropDownMenu:DropDown = {
        let menu = DropDown()
        menu.dataSource = ["Sil", "Düzenle"]
        return menu
    }()
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.borderWidth = 3
        layer.cornerRadius = 5
        layer.borderColor = UIColor.white.cgColor
    }

    
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    
    @IBAction func buttonMenuAc(_ sender: Any) {
        if let garsonId = labelGizliGarsonId.text {
            dropDownMenu.anchorView = buttonMenuAc
            dropDownMenu.selectionAction = {index, title in
                if index == 0 {     //Sil
                    NotificationCenter.default.post(name: .garsonuSil, object: nil, userInfo: ["garsonId":garsonId])
                    
                } else if index == 1 {      //Düzenle
                    NotificationCenter.default.post(name: .garsonuDuzenle, object: nil, userInfo: ["garsonId":garsonId])
                    
                }
            }
            dropDownMenu.show()
        }
    }
    
}



