//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Heng Brandon on 8/30/18.
//  Copyright © 2018 Heng Brandon. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController{

    let realm = try! Realm()
    var catagories: Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCatagories()
        
        tableView.rowHeight = 85.0
        tableView.separatorStyle = .none
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source method

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return catagories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        cell.textLabel?.text = catagories?[indexPath.row].name ?? "No Categorized Added"
        
        guard let categoryColor = UIColor(hexString: (catagories?[indexPath.row].color ?? "1D9BF6")) else {
            fatalError()
        }
        
        cell.backgroundColor = categoryColor
        
        cell.textLabel?.textColor = ContrastColorOf(categoryColor, returnFlat: true)
        
        return cell
    }
    
    //MARK: - add new categories
    @IBAction func addButtonPress(_ sender: UIBarButtonItem) {
        var textfield = UITextField()
        let alert = UIAlertController(title: "Add New Catagory", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Catagory", style: .default) { (alertAction) in
            let newCatagory = Category()
            newCatagory.name = textfield.text!
            newCatagory.color = UIColor.randomFlat.hexValue()
            
            self.saveCatagories(categories: newCatagory)
        }
        alert.addAction(action)
        alert.addTextField { (alertTextfield) in
            alertTextfield.placeholder = "Add your new Catagory Here"
            textfield = alertTextfield
        }
        present(alert,animated: true, completion: nil)
    }
    
    //MARK: -Data Manipulation Method
    func saveCatagories(categories: Category){
        do{
            try realm.write {
                realm.add(categories)
            }
        }catch{
            print("Error saving context\(error)")
        }
        self.tableView.reloadData()
    }
    
    func loadCatagories() {
        catagories = realm.objects(Category.self)
        
        self.tableView.reloadData()
    }
    
    //MARK: -Delete data from swipe
    override func updateModel(at indexPath: IndexPath) {
                    if let categoryForDeletion = self.catagories?[indexPath.row]{
                        do{
                            try self.realm.write {
                                self.realm.delete(categoryForDeletion)
                            }
                        }catch{
                            print("Error deleteing \(error)")
                        }
                        //self.tableView.reloadData()
                    }
    }
    
    
    //MARK: -tableview delegate method
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow{
            destinationVC.selectedCategory = catagories?[indexPath.row]
        }
    }
    
    
}


