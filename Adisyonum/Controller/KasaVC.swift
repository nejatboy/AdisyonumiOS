

import UIKit

class KasaVC: UIViewController {
    
    @IBOutlet weak var collectionViewMasalar: UICollectionView!
    
    let singleton = Singleton.getInstance
    var tumMasalar = [Masa]()
    
    
    
    
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
        
        collectionViewMasalar.delegate = self
        collectionViewMasalar.dataSource = self
        
        masalariOlustur()
    }
    
    
    
    
    func garsonGetirByGarsonId(_ garsonId:String) -> Garson {
        var garson:Garson?
        for g in singleton.restoranGarsonlari {
            if g.garsonId == garsonId {
                garson = g
                break
            }
        }
        return garson!
    }
    
    
    
    
    func masalariOlustur() {
        for i in 1...singleton.loginKasa!.masaSayisi {
            tumMasalar.append(Masa("", i, 0.0, false, false, "", "", [String]()))
        }
        collectionViewMasalar.reloadData()
    }
    


}







// --------------------------- CollectionView -------------------------
extension KasaVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tumMasalar.count
    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if tumMasalar.isEmpty {
            return UICollectionViewCell()
            
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "hucreMasa_KasaVC", for: indexPath) as! HucreMasa_KasaVC
            let masa = tumMasalar[indexPath.item]
            
            if masa.masaAcik && masa.masaYazdirildi {
                //MAVİ
            } else if masa.masaAcik {
                //KIRMIZI
            } else {
                // YEŞİL
            }
            
            cell.labelHesap.text = "\(masa.masaTutar) TL"
            //cell.labelGarsonAd.text = garsonGetirByGarsonId(masa.garsonId).garsonAd
            cell.labelMasaNo.text = String(masa.masaNo)
            
            return cell
        }
    }
}
