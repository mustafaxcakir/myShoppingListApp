//
//  ViewController.swift
//  myShoppingListApp
//
//  Created by MustafaCan on 10.12.2023.
//

import UIKit

//
class ViewController: UIViewController,UITextFieldDelegate {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    

    let username = ""
    let password = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        
    }
 
    
    @IBAction func loginButtonClicked(_ sender: Any) {
        
        let enterUsername = usernameTextField.text
        let enterPassword = passwordTextField.text
        
        if enterUsername == "" && enterPassword == "" {
            
            performSegue(withIdentifier: "toMainMenu", sender: self)
        }else {
            
            let alertMessage = UIAlertController(title: "Error! ",
                                                 message: "Username or Password Error!",
                                                 preferredStyle: UIAlertController.Style.alert)
            
            let okayButton = UIAlertAction(title: "Okay",
                                           style: UIAlertAction.Style.default) { UIAlertAction in
                print("cliked okay button.")
            }
            
            self.passwordTextField.resignFirstResponder()
            
            alertMessage.addAction(okayButton)
            self.present(alertMessage, animated: true,completion: nil)
        }
    }
//keyboard close.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case usernameTextField:
            passwordTextField.becomeFirstResponder()
        case passwordTextField:
               passwordTextField.resignFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        return true
    }
    
    // Perform the necessary actions when this screen will appear again regularly.
    func resetLoginFields() {

        usernameTextField.text = ""
        passwordTextField.text = ""
      }
    
    
    override func viewWillAppear(_ animated: Bool) {
          super.viewWillAppear(animated)

        
        resetLoginFields()
      }
    


}



