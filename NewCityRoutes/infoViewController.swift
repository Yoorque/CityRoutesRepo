//
//  infoViewController.swift
//  NewCityRoutes
//
//  Created by Dusan Juranovic on 5/25/17.
//  Copyright © 2017 Dusan Juranovic. All rights reserved.
//

import UIKit

class infoViewController: UIViewController {
    @IBOutlet var dusan: UITextField!
    @IBOutlet var marko: UITextField!
    @IBOutlet var predrag: UITextField!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var longTextLabel: UITextView!
    @IBOutlet var developerLabel: UITextField!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet var copyrightLabel: UILabel!
    
    var blurEffect = BlurEffect()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        longTextLabel.textAlignment = .justified
        longTextLabel.backgroundColor = UIColor.clear
        blurEffect.blurTheBackgound(view: backgroundImage)
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UINavigationBar.classForCoder() as! UIAppearanceContainer.Type]).setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.white], for: .normal)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
       
        
        if language == "latin" {
            titleLabel.text = "City Routes"
            longTextLabel.text = "This application was developed using openstreetmap.com and overpas-turbo.eu. Considering that openstreetmap.com is an open source map editing website, our data may slightly differ from the actual state. Should you notice any errors with data or have any suggestions to make our maps better, please, let us know at your own convenience, so we can correct the map data in our next update. You will find our team's emails below."
            developerLabel.text = "Developer Team:"
            copyrightLabel.text = "Copyright ⓒ. All rights reservedⓇ"
            dusan.text = "Dušan Juranović"
            marko.text = "Marko Tribl"
            predrag.text = "Predrag Djordjević"
        } else {
            titleLabel.text = "Градске Руте"
            longTextLabel.text = "Ова апликација је прављена са подацима креираним или преузетим са openstreetmap.org, помоћу overpass-turbo.eu. С обзиром да је openstreetmap.org, отворени сајт за рад са мапама и подацима, може доћи до неслагања наших података са реалним стањем на улицама. Уколико приметите икаква неслагања или имате предлоге и сугестије како бисмо побољшали квалитет мапа, молимо Вас да нам пошаљете имејл са свим релевантним подацима. Имејл адресе нашег тима су излистане испод."
            developerLabel.text = "Тим:"
            copyrightLabel.text = "Ауторска права ⓒ. Сва права задржана Ⓡ"
            dusan.text = "Душан Јурановић"
            marko.text = "Марко Трибл"
            predrag.text = "Предраг Ђорђевић"
        }
    }
    
    
}
