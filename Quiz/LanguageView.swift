//
//  LanguageView.swift
//  Quiz
//
//  Created by Bhavesh Kerai on 27/01/20.
//  Copyright © 2020 LPK Techno. All rights reserved.
//

import UIKit

class LanguageView:UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tableView: UITableView!
    
    let menuList = ["Cheese", "Bacon", "Egg","Fanta", "Lift", "Coke"] // Inside your ViewController
    var selectedElement = [Int : String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return menuList.count
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       let cell:LanguageCell =
        tableView.dequeueReusableCell(withIdentifier: "LanguageCell") as! LanguageCell
         let item = menuList[indexPath.row]
         cell.itemLabel.text = item
         if item == selectedElement[indexPath.section] {
             cell.radioButton.isSelected = true
         } else {
             cell.radioButton.isSelected = false
         }
         cell.initCellItem()
        // cell.delegate = self
         // Your logic....
        cell.selectionStyle = .none
         return cell
    }


    func didToggleRadioButton(_ indexPath: IndexPath) {
        let section = indexPath.section
        let data = menuList[indexPath.row]
        if let previousItem = selectedElement[section] {
            if previousItem == data {
                selectedElement.removeValue(forKey: section)
                return
            }
        }
        selectedElement.updateValue(data, forKey: section)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        let cell:LanguageCell = self.tableView.cellForRow(at: indexPath) as! LanguageCell
        cell.radioButtonTapped(cell.radioButton)
               
    }

}
