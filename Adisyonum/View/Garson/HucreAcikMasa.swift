
import UIKit
import DropDown
import Firebase

class HucreAcikMasa: UITableViewCell {
    @IBOutlet weak var labelMasaNo: UILabel!
    @IBOutlet weak var labelHesap: UILabel!
    @IBOutlet weak var labelGizliMasaId: UILabel!
    @IBOutlet weak var buttonMenuAc: UIButton!
    
    let dropDownMenu:DropDown = {
        let menu = DropDown()
        menu.dataSource = ["Adisyonu Yazdır", "Masa Numarasını Değiştir"]
        return menu
    }()
    
    let referenceMasalar = Firestore.firestore().collection("Masalar")
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.borderWidth = 3
        layer.borderColor = UIColor.white.cgColor
        layer.cornerRadius = 5
    }

    
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    
    
    func adisyonuYazdir(_ masaId:String)  {
        var veri = [String:Any]()
        veri["masaYazdirildi"] = true
        referenceMasalar.document(masaId).setData(veri, merge: true)
    }

    
    
    @IBAction func buttonMenuAc(_ sender: Any) {
        guard let masaId = labelGizliMasaId.text else {
            return
        }
        
        dropDownMenu.anchorView = buttonMenuAc
        dropDownMenu.selectionAction = {index, title in
            if index == 0 {     //Adisyonu yazdır
                self.adisyonuYazdir(masaId)
                
            } else if index == 1 {      //Masa numarasını değiştir
                NotificationCenter.default.post(name: .masaTasimasiYapilacak, object: nil, userInfo: ["masaId":masaId])
            }
        }
        dropDownMenu.show()
    }
}
