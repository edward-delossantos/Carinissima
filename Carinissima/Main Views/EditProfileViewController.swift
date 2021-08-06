//
//  EditProfileViewController.swift
//  Carinissima
//
//  Created by Edward de los Santos on 8/1/21.
//

import UIKit
import JGProgressHUD

class EditProfileViewController: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var surnameTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    
    //MARK: - Vars
    let hud = JGProgressHUD(style: .dark)
    
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadUserInfo()
    }
    
    //MARK: - IBActions
    @IBAction func didTapSaveButton(_ sender: Any) {
        dismissKeyboard()
        if textFieldsHaveText() {
            let withValues = [kFIRSTNAME: nameTextField.text!, kLASTNAME: surnameTextField.text!, kFULLADDRESS: addressTextField.text!, kFULLNAME: (nameTextField.text! + " " + surnameTextField.text!)] as [String : Any]
            
            updateCurrentUserInFirestore(withValues: withValues) { error in
                if let error = error {
                    print("error updating user \(error.localizedDescription)")
                    showHudNotification(view: self.view, hud: self.hud, text: error.localizedDescription, isError: true)
                } else {
                    showHudNotification(view: self.view, hud: self.hud, text: "Updated", isError: false)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        } else {
            showHudNotification(view: self.view, hud: hud, text: "All fields are required", isError: true)
        }
    }
    
    @IBAction func didTapLogOutButton(_ sender: Any) {
        logOutUser()
    }
    
    //MARK: - Helper functions
    private func dismissKeyboard() {
        self.view.endEditing(false)
    }
    
    private func textFieldsHaveText() -> Bool {
        return (nameTextField.text != "" && surnameTextField.text != "" && addressTextField.text != "")
    }
    
    //UpdateUI
    private func loadUserInfo() {
        if let currentUser = MUser.currentUser() {
            nameTextField.text = currentUser.firstName
            surnameTextField.text = currentUser.lastName
            addressTextField.text = currentUser.fullAddress
        }
    }

    private func logOutUser() {
        MUser.logOutCurrentUser { error in
            if let error = error {
                print("error logging out: \(error.localizedDescription)")
            } else {
                showHudNotification(view: self.view, hud: self.hud, text: "Logged out", isError: false)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
}
