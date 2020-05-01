//
//  HucreUrun_Yonetici.swift
//  Adisyonum
//
//  Created by Nejat Boy on 29.04.2020.
//  Copyright © 2020 Nejat Boy. All rights reserved.
//

import UIKit
import DropDown

class HucreUrun_Yonetici: UITableViewCell {

    @IBOutlet weak var labelUrunAd: UILabel!
    @IBOutlet weak var labelGizliUrunId: UILabel!
    @IBOutlet weak var buttonMenuAc: UIButton!
    @IBOutlet weak var labelUrunFiyat: UILabel!
    
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
        if let urunId = labelGizliUrunId.text {
            dropDownMenu.anchorView = buttonMenuAc
            dropDownMenu.selectionAction = {index, title in
                if index == 0 {     //Sil
                    NotificationCenter.default.post(name: .urunuSil, object: nil, userInfo: ["urunId":urunId])
                    
                } else if index == 1 {      //Düzenle
                    NotificationCenter.default.post(name: .urunuDuzenle, object: nil, userInfo: ["urunId":urunId])
                }
            }
            dropDownMenu.show()
        }
    }
    
}
