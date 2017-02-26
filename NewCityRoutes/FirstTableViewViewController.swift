//
//  FirstTableViewViewController.swift
//  NewCityRoutes
//
//  Created by Dusan Juranovic on 2/26/17.
//  Copyright © 2017 Dusan Juranovic. All rights reserved.
//

import UIKit

class FirstTableViewViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBAction func backButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    @IBOutlet var tableView: UITableView!
    var selectedTransport = [Routes]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    //MARK: TableView Delegates
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedTransport.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = selectedTransport[indexPath.row].ref
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        let controller = storyboard?.instantiateViewController(withIdentifier: "DetailVC") as! DetailViewController
        self.present(controller, animated: true, completion: nil)
        controller.lineRoutes = self.selectedTransport[indexPath.row].routes
        
    }
}
