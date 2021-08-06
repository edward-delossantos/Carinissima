//
//  WelcomeViewController.swift
//  Carinissima
//
//  Created by Edward de los Santos on 7/30/21.
//

import UIKit
import JGProgressHUD
import NVActivityIndicatorView

class WelcomeViewController: UIViewController {

    //MARK: - IBOutlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var resendEmailButton: UIButton!
    
    //MARK: - Vars
    let hud = JGProgressHUD(style: .dark)
    var activityIndicator: NVActivityIndicatorView?
    
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        activityIndicator = NVActivityIndicatorView(
            frame: CGRect(
                x: self.view.frame.width / 2 - 30,
                y: self.view.frame.height / 2 - 30,
                width: 60,
                height: 60),
            type: .ballBeat,
            color: #colorLiteral(red: 0.9733608365, green: 0.553093195, blue: 0.4656373262, alpha: 1),
            padding: nil)
    }
    
    //MARK: - IBActions
    @IBAction func didTapCancelButton(_ sender: Any) {
        dismissView()
    }
    
    @IBAction func didTapLoginButton(_ sender: Any) {
        if textFieldsHaveText() {
            loginUser()
        } else {
            showHudNotification(view: self.view, hud: hud, text: "All fields are required!", isError: true)
        }
    }
    
    @IBAction func didTapRegisterButton(_ sender: Any) {
        if textFieldsHaveText() {
            registerUser()
        } else {
            showHudNotification(view: self.view, hud: hud, text: "All fields are required!", isError: true)
        }
    }
    
    @IBAction func didTapResendEmailButton(_ sender: Any) {
        MUser.resendVerificationEmail(email: emailTextField.text!) { error in
            if let error = error {
                print("error resending email: \(error.localizedDescription)")
            }
        }
    }
    
    @IBAction func didTapForgotPasswordButton(_ sender: Any) {
        if emailTextField.text != "" {
            resetPassword()
        } else {
            showHudNotification(view: self.view, hud: hud, text: "Please insert email", isError: true)
        }
    }
    
    //MARK: - Login User
    private func loginUser() {
        showLoadingIndicator()
        
        MUser.loginUser(email: emailTextField.text!, password: passwordTextField.text!) { error, isEmailVerified in
            if let error = error {
                showHudNotification(view: self.view, hud: self.hud, text: error.localizedDescription, isError: true)
            } else {
                if isEmailVerified {
                    self.dismissView()
                } else {
                    showHudNotification(view: self.view, hud: self.hud, text: "Please verify your email", isError: true)
                }
            }
            self.hideLoadingIndicator()
        }
    }
    
    //MARK: - Register User
    private func registerUser() {
        showLoadingIndicator()
        MUser.registerUser(with: emailTextField.text!, password: passwordTextField.text!) { error in
            if let error = error {
                print("error registering \(error.localizedDescription)")
                showHudNotification(view: self.view, hud: self.hud, text: error.localizedDescription, isError: true)
            } else {
                showHudNotification(view: self.view, hud: self.hud, text: "Verification email sent", isError: false)
            }
            self.hideLoadingIndicator()
        }
    }
     
    //MARK: - Helper Functions
    private func resetPassword() {
        MUser.resetPasswordFor(email: emailTextField.text!) { error in
            if error == nil {
                showHudNotification(view: self.view, hud: self.hud, text: "Reset password email has been sent!", isError: false)
            } else {
                showHudNotification(view: self.view, hud: self.hud, text: error!.localizedDescription, isError: true)
            }
        }
    }
    
    private func textFieldsHaveText() -> Bool {
        return emailTextField.text != "" && passwordTextField.text != ""
    }
    
    private func dismissView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Activity Indicator
    private func showLoadingIndicator(){
        if activityIndicator != nil {
            self.view.addSubview(activityIndicator!)
            activityIndicator!.startAnimating()
        }
    }
    
    private func hideLoadingIndicator(){
        if activityIndicator != nil {
            activityIndicator!.removeFromSuperview()
            activityIndicator!.stopAnimating()
        }
    }
}
