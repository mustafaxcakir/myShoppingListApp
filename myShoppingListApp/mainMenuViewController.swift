//
//  mainMenuViewController.swift
//  myShoppingListApp
//
//  Created by MustafaCan on 10.12.2023.
//

import UIKit
import CoreData

class mainMenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var nameArray = [String]()
    var idArray = [UUID]()
    var selectName = ""
    var selectUUID : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonClicked))
        
        getData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name(rawValue: "addData"), object: nil)
        
    }
    
    @objc func getData(){
        
        nameArray.removeAll(keepingCapacity: false)
        idArray.removeAll(keepingCapacity: false)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ShoppingList")
        fetchRequest.returnsObjectsAsFaults = false
        
        do{
            let result = try context.fetch(fetchRequest)
            if result.count > 0 {
                for data in result  as! [NSManagedObject]{
                    if let name = data.value(forKey: "name") as? String{
                        nameArray.append(name)
                    }
                    if let id = data.value(forKey: "id") as? UUID{
                        idArray.append(id)
                    }
                }
                
                tableView.reloadData()
                
            }
            
            
        }catch{
            print("Error fetching data: \(error)")
        }
        
    }
    
    
    @objc func addButtonClicked(){
        selectName = ""
        performSegue(withIdentifier: "toProductDetails", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArray.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = nameArray[indexPath.row]
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toProductDetails"{
            let destinationVC = segue.destination as! DetailsViewController
            destinationVC.selectProductName = selectName
            destinationVC.selecetProductUUID = selectUUID
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectName = nameArray[indexPath.row]
        selectUUID = idArray[indexPath.row]
        performSegue(withIdentifier: "toProductDetails", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            let context = appDelegate?.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ShoppingList")
            let uuidString = idArray[indexPath.row].uuidString
            
            fetchRequest.predicate = NSPredicate(format: "id = %@", uuidString)
            fetchRequest.returnsObjectsAsFaults = false
            
            do{
                let result = try context?.fetch(fetchRequest)
                if result!.count > 0{
                    for data in result as! [NSManagedObject]{
                        if let id = data.value(forKey: "id") as? UUID{
                            if id == idArray[indexPath.row]{
                                context?.delete(data)
                                nameArray.remove(at: indexPath.row)
                                idArray.remove(at: indexPath.row)
                                
                                self.tableView.reloadData()
                                do{
                                    try context?.save()
                                }catch{
                                    
                                }
                                break
                            }
                        }
                    }
                    
                }
            }catch{
                print("error")
            }
        }
        
    }
}
