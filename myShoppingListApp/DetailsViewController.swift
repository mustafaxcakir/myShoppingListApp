//
//  DetailsViewController.swift
//  myShoppingListApp
//
//  Created by MustafaCan on 10.12.2023.
//

import UIKit
import CoreData

class DetailsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var productNameTextField: UITextField!
    @IBOutlet weak var productTypeTextField: UITextField!
    @IBOutlet weak var productCostTextField: UITextField!
    
    var selectProductName = ""
    var selecetProductUUID : UUID?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if selectProductName != "" {
            
            saveButton.isHidden = true
            
               if let uuidString = selecetProductUUID?.uuidString {
                
                   let appDelegate = UIApplication.shared.delegate as! AppDelegate
                   let context = appDelegate.persistentContainer.viewContext
                   
                   let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ShoppingList")
                   fetchRequest.predicate = NSPredicate(format: "id = %@" , uuidString)
                   fetchRequest.returnsObjectsAsFaults = false
                   
                   do {
                       let result = try context.fetch(fetchRequest)
                       if result.count > 0 {
                           for data in result as! [NSManagedObject]{
                               
                               if let name = data.value(forKey: "name") as? String{
                                   productNameTextField.text = name
                               }
                               if let cost = data.value(forKey: "cost") as? Int{
                                   productCostTextField.text = String(cost)
                               }
                               if let type = data.value(forKey: "type") as? String{
                                   productTypeTextField.text = type
                               }
                               if let imageData = data.value(forKey: "image") as? Data{
                                    let image = UIImage(data: imageData)
                                   imageView.image = image
                               }
 
                           }
                       }
                   }catch{
                       print("Error!")
                   }
                   
                   
               }
           } else {
               saveButton.isHidden = false
               saveButton.isEnabled = false
               productNameTextField.text = ""
               productTypeTextField.text = ""
               productCostTextField.text = ""
           }
        
        //keyboard close.
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(keyboardClose))
        view.addGestureRecognizer(gestureRecognizer)
        
        imageView.isUserInteractionEnabled = true
        let imageGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageView.addGestureRecognizer(imageGestureRecognizer)
        
    
        
    }
    
    @objc func selectImage(){
    
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .camera
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        imageView.image = info[.editedImage] as? UIImage
        saveButton.isEnabled = true
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    @objc func keyboardClose(){
        view.endEditing(true)
    }
    
    
    func isProductAlreadyExists(name: String) -> Bool {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ShoppingList")
        fetchRequest.predicate = NSPredicate(format: "name = %@", name)
        
        do {
            let result = try context.fetch(fetchRequest)
            return result.count > 0
        } catch {
            print("Error checking existing products: \(error.localizedDescription)")
            return false
        }
    }
    
    
    @IBAction func saveButton(_ sender: Any) {
        
        guard let productName = productNameTextField.text else {
                return
            }

            if isProductAlreadyExists(name: productName) {
                // If the product is already registered, a personal alert may be shown.
                let alert = UIAlertController(title: "Warning", message: "This product is already added.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(okAction)
                present(alert, animated: true, completion: nil)
                return
            }
        
        
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let shopping = NSEntityDescription.insertNewObject(forEntityName: "ShoppingList",
                                                           into: context)
        shopping.setValue(productNameTextField.text, forKey: "name")
        shopping.setValue(productTypeTextField.text, forKey: "type")
        
        if let cost = Int(productCostTextField.text!){
            shopping.setValue(cost, forKey: "cost")
        }
        
        shopping.setValue(UUID(), forKey: "id")
        
        let data = imageView.image!.jpegData(compressionQuality: 0.5)
        
        shopping.setValue(data, forKey: "image")
        
        do{
            try    context.save()
            let alert = UIAlertController(title: "Congratulations!", message: "Photo saved.", preferredStyle: UIAlertController.Style.alert)
            let okButton = UIAlertAction(title: "Okay", style: UIAlertAction.Style.default) { UIAlertAction in
                print("photo saved")
                }
                    alert.addAction(okButton)
                    self.present(alert, animated: true, completion: nil)
        }catch{
            let alertTwo = UIAlertController(title: "Sorry", message: "Photo could not be saved.", preferredStyle: UIAlertController.Style.alert)
            let okayButton = UIAlertAction(title: "Okay", style: UIAlertAction.Style.cancel) { UIAlertAction in
                print("image not saved")
            }
            alertTwo.addAction(okayButton)
            self.present(alertTwo,animated: true,completion: nil)
        }
        
        self.navigationController?.popViewController(animated: true)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "addData"), object: nil)

    }
   
  
    
    
    
}
