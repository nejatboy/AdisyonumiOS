//
//  HucreRestoran.swift
//  Adisyonum
//
//  Created by Nejat Boy on 26.04.2020.
//  Copyright © 2020 Nejat Boy. All rights reserved.
//

import UIKit
import DropDown

class HucreRestoran: UITableViewCell {

    @IBOutlet weak var labelRestoranAdi: UILabel!
    @IBOutlet weak var labelGizliRestoranId: UILabel!
    @IBOutlet weak var buttonMenuAc: UIButton!
    
    let dropDownMenu:DropDown = {
        let menu = DropDown()
        menu.dataSource = ["Düzenle", "Sil", "Restoran Kodunu Kopyala"]
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
        if let restoranId = labelGizliRestoranId.text {
            dropDownMenu.anchorView = buttonMenuAc
            dropDownMenu.selectionAction = {index, title in
                if index == 0 {     //Düzenle
                    NotificationCenter.default.post(name: .restoraniDuzenle, object: nil, userInfo: ["restoranId":restoranId])
                    
                } else if index == 1 {      //Sil
                    NotificationCenter.default.post(name: .restoraniSil, object: nil, userInfo: ["restoranId":restoranId])
                    
                } else if index == 2 {      //Restoran Kodu Kopyala
                    NotificationCenter.default.post(name: .restoranKoduKopyalama, object: nil, userInfo: ["restoranId":restoranId])
                    
                }
            }
            dropDownMenu.show()
        }
    }
    
}






