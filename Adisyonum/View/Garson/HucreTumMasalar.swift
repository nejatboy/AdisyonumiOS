//
//  HucreTumMasalar.swift
//  Adisyonum
//
//  Created by Nejat Boy on 22.04.2020.
//  Copyright © 2020 Nejat Boy. All rights reserved.
//

import UIKit

class HucreTumMasalar: UICollectionViewCell {
    @IBOutlet weak var labelMasaNo: UILabel!
    @IBOutlet weak var labelGarsonAd: UILabel!
    @IBOutlet weak var labelHesap: UILabel!
    
    
    override func awakeFromNib() {
        layer.cornerRadius = 10
    }
}
