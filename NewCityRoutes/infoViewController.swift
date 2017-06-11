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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
       
        titleLabel.text = language == "latin" ? "City Routes" : "Градске Руте"
        longTextLabel.text = language == "latin" ? "This application was developed using openstreetmap.com and overpas-turbo.eu. Considering that openstreetmap.com is an open source map editing website, our data may slightly differ from the actual state. Should you notice any errors with data or have any suggestions to make our maps better, please, let us know at your own convenience, so we can correct the map data in our next update. You will find our team's emails below." : "Ова апликација је прављена са подацима креираним или преузетим са openstreetmap.org, помоћу overpass-turbo.eu. С обзиром да је openstreetmap.org, отворени сајт за рад са мапама и подацима, може доћи до неслагања наших података са реалним стањем на улицама. Уколико приметите икаква неслагања или имате предлоге и сугестије како бисмо побољшали квалитет мапа, молимо Вас да нам пошаљете имејл са свим релевантним подацима. Имејл адресе нашег тима су излистане испод."
        developerLabel.text = language == "latin" ? "Developer Team:" : "Тим:"
        copyrightLabel.text = language == "latin" ? "Copyright ⓒ. All rights reserved Ⓡ" : "Ауторска права ⓒ. Сва права задржана Ⓡ"
        dusan.text = language == "latin" ? "Dušan Juranović" : "Душан Јурановић"
        marko.text = language == "latin" ? "Marko Tribl" : "Марко Трибл"
        predrag.text = language == "latin" ? "Predrag Djordjević" : "Предраг Ђорђевић"
    }
}
