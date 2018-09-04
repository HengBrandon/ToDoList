//
//  ViewController.swift
//  Todoey
//
//  Created by Heng Brandon on 8/29/18.
//  Copyright © 2018 Heng Brandon. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController{

    let realm = try! Realm()
    var todoItems: Results<Item>?

    @IBOutlet weak var mySearchBar: UISearchBar!
    var selectedCategory : Category? {
        didSet{
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 85.0
        tableView.separatorStyle = .none

    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let colorHex = selectedCategory?.color else{
            fatalError()
        }
        
        title = selectedCategory?.name
        updateNavBar(withHexCode: colorHex)
        mySearchBar.barTintColor = UIColor(hexString :colorHex)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        updateNavBar(withHexCode: "1D9BF6")
        
    }
    
    //MARK - Nav Bar Setup methods
    func updateNavBar(withHexCode colorHexCode: String){
        guard let navBar = navigationController?.navigationBar else {
            fatalError()
        }
        
        guard let navBarColor = UIColor(hexString :colorHexCode) else{
            fatalError("Navigation controller does not exit")
        }
        navBar.barTintColor = navBarColor
        navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
        navBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: ContrastColorOf(navBarColor, returnFlat: true)]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

        // Dispose of any resources that can be recreated.
    }
    

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = UITableViewCell(style: default, reuseIdentifier: "ToDoItemCell")
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let item = self.todoItems?[indexPath.row]{
            cell.textLabel?.text = item.title
            cell.accessoryType = item.done ? .checkmark : .none
            if let colour = UIColor(hexString: selectedCategory!.color)?.darken(byPercentage: CGFloat(indexPath.row)/CGFloat(todoItems!.count)){
                cell.backgroundColor = colour
                cell.textLabel?.textColor = ContrastColorOf(colour, returnFlat: true)
            }
            
        }else{
            cell.textLabel?.text = "No item added"
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    @objc func tableViewTapped(){
        //messageTextfield.endEditing(true)
    }
    
    //MARK::TableView delegate Method
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = todoItems?[indexPath.row]{
            do{
                try realm.write{
//                    realm.delete(item)
                    item.done = !item.done
                }
            }catch{
                print("Error updating context\(error)")
            }
        }
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK - Add New Items
    @IBAction func addButtonPress(_ sender: UIBarButtonItem) {
        var textfiled = UITextField()
        let alert = UIAlertController(title: "Add New Todoey It", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default){ (action) in

                if let currentCatagory = self.selectedCategory{
                    do{
                        try self.realm.write {
                            let newItem = Item()
                            newItem.title = textfiled.text!
                            newItem.dateCreated = Date()
                            currentCatagory.items.append(newItem)
                            self.realm.add(newItem)
                        }
                    }catch{
                       print("Error saving context\(error)")
                    }
                }
                self.tableView.reloadData()
        }
        alert.addTextField { (alterTextFile) in
            alterTextFile.placeholder = "Create new item"
            textfiled = alterTextFile
        }
        alert.addAction(action)
        present(alert,animated: true, completion: nil)
    }
    
    //MARK - Model Manupulation Methods
    
    func loadItems(){
        todoItems = (selectedCategory?.items.sorted(byKeyPath: "title", ascending: true))
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let categoryForDeletion = self.todoItems?[indexPath.row]{
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
}

//MARK: - Search bar method

extension TodoListViewController: UISearchBarDelegate{
    
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //searchBar.endEditing(true)
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
        searchBar.endEditing(true)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0{
            loadItems()
        }else{
            todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "title", ascending: true)
            tableView.reloadData()
        }
    }
}

