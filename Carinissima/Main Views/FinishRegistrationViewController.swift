//
//  FinishRegistrationViewController.swift
//  Carinissima
//
//  Created by Edward de los Santos on 7/31/21.
//

import UIKit
import JGProgressHUD

class FinishRegistrationViewController: UIViewController {

    //MARK: - IBOutlets
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var surnameTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var doneButton: UIButton!
    
    //MARK: - Vars
    let hud = JGProgressHUD(style: .dark)
    
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        surnameTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        addressTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
    }

    //MARK: - IBActions
    @IBAction func didTapDoneButton(_ sender: Any) {
        finishOnboarding()
    }
    
    @IBAction func didTapCancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //OBJC funcs
    @objc func textFieldDidChange(_ textField: UITextField) {
        updateDoneButtonStatus()
    }
    
    //MARK: - Helper Functions
    private func updateDoneButtonStatus() {
        if nameTextField.text != "" && surnameTextField.text != "" && addressTextField.text != "" {
            doneButton.backgroundColor = #colorLiteral(red: 0.9733608365, green: 0.553093195, blue: 0.4656373262, alpha: 1)
            doneButton.isEnabled = true
        } else {
            doneButton.backgroundColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
            doneButton.isEnabled = false
        }
    }
    
    private func finishOnboarding() {
        let withValues = [kFIRSTNAME: nameTextField.text!, kLASTNAME: surnameTextField.text!, kONBOARD: true ,kFULLADDRESS: addressTextField.text!, kFULLNAME: (nameTextField.text! + " " + surnameTextField.text!)] as [String : Any]
        
        updateCurrentUserInFirestore(withValues: withValues) { error in
            if let error = error {
                print("error: \(error.localizedDescription)")
                
                showHudNotification(view: self.view, hud: self.hud, text: error.localizedDescription, isError: true)
                self.dismiss(animated: true, completion: nil)
            } else {
                showHudNotification(view: self.view, hud: self.hud, text: "Updated", isError: false)
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}
