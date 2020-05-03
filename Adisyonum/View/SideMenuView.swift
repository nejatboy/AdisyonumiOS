

import UIKit

class SideMenuView: UIView {

    override func awakeFromNib() {
        layer.cornerRadius = 15
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5      //(0 - 1)
        layer.shadowOffset = CGSize(width: 5, height: 0)
    }
    

}
