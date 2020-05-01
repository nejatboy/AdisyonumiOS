

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
        hucreTasariminiAyarla()
        
        masalariOlustur()
        
        
    }
    
    
    
    
    func hucreTasariminiAyarla() {
        let tasarim = UICollectionViewFlowLayout()  //Tasarımların çoğunu bunla yaparız
        let genislik = collectionViewMasalar.frame.size.width  //CollectionView'ın yayıldığı alanın genişliğini aldım
        tasarim.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)   //Hücre ile collectionView arası boşluklar
        tasarim.minimumInteritemSpacing = 10     //yatayda hücreler arası boşluk
        tasarim.minimumLineSpacing = 10  //Dikeyde hücreler arası boşluk
        let hucreKenarUzunluk = (genislik - 70) / 6
        tasarim.itemSize = CGSize(width: hucreKenarUzunluk,  height: hucreKenarUzunluk)
        tasarim.scrollDirection = UICollectionView.ScrollDirection.vertical
        collectionViewMasalar.collectionViewLayout = tasarim   //Hazırladığım tasarımı aktardım
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
                cell.backgroundColor = UIColor(named: "yazdirilmisMasaHucreRengi")
            } else if masa.masaAcik {
                //KIRMIZI
                cell.backgroundColor = UIColor(named: "doluMasaHucreRengi")
            } else {
                // YEŞİL
                cell.backgroundColor = UIColor(named: "bosMasaHucreRengi")
            }
            
            cell.labelHesap.text = "\(masa.masaTutar) TL"
            //cell.labelGarsonAd.text = garsonGetirByGarsonId(masa.garsonId).garsonAd
            cell.labelMasaNo.text = String(masa.masaNo)
            
            return cell
        }
    }
}
