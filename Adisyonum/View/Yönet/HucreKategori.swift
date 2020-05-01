
import UIKit
import DropDown

class HucreKategori: UITableViewCell {
    
    @IBOutlet weak var labelGizliKategoriId: UILabel!
    @IBOutlet weak var labelKategoriAd: UILabel!
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

    }
    
    
    

    @IBAction func buttonMenuAc(_ sender: Any) {
        if let kategoriId = labelGizliKategoriId.text {
            dropDownMenu.anchorView = buttonMenuAc
            dropDownMenu.selectionAction = {index, title in
                if index == 0 {     //Sil
                    NotificationCenter.default.post(name: .kategoriyiSil, object: nil, userInfo: ["kategoriId":kategoriId])
                    
                } else if index == 1 {      //Düzenle
                    NotificationCenter.default.post(name: .kategoriyiDuzenle, object: nil, userInfo: ["kategoriId":kategoriId])
                }
            }
            dropDownMenu.show()
        }
    }
}
