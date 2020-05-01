

import UIKit

class DialogView: UIView {

    
    override func awakeFromNib() {
        layer.cornerRadius = 8
        layer.shadowRadius = 10
        layer.shadowOpacity = 10
        layer.shadowColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
    }

}
