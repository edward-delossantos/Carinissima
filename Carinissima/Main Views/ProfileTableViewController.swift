//
//  ProfileTableViewController.swift
//  Carinissima
//
//  Created by Edward de los Santos on 7/30/21.
//

import UIKit


class ProfileTableViewController: UITableViewController, UIAdaptivePresentationControllerDelegate {

    //MARK: - View Lifecycle
    @IBOutlet weak var finishRegistrationButton: UIButton!
    @IBOutlet weak var purchaseHistoryButton: UIButton!
    
    //MARK: - Vars
    var editBarButton: UIBarButtonItem!
    
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    
        checkUserStatus()
    }
    
    // MARK: - TableView data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    //MARK: - TableView delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: - Helper functions
    func checkUserStatus() {
        checkLoginStatus()
        checkOnBoardingStatus()
    }
    
    private func checkOnBoardingStatus() {
        if let currentUser = MUser.currentUser() {
            if currentUser.onBoard {
                finishRegistrationButton.setTitle("Account is Active", for: .normal)
                finishRegistrationButton.isEnabled = false
            } else {
                finishRegistrationButton.setTitle("Finish Registration", for: .normal)
                finishRegistrationButton.isEnabled = true
                finishRegistrationButton.tintColor = .red
            }
            
            purchaseHistoryButton.isEnabled = true
            
        } else {
            finishRegistrationButton.setTitle("Logged out", for: .normal)
            finishRegistrationButton.isEnabled = false
            purchaseHistoryButton.isEnabled = false
        }
    }
    
    private func checkLoginStatus() {
        if MUser.currentUser() == nil {
            createRightBarButton(title: "Login")
        } else {
            createRightBarButton(title: "Edit")
        }
    }
    
    private func createRightBarButton(title: String) {
        editBarButton = UIBarButtonItem(
            title: title,
            style: .plain,
            target: self,
            action: #selector(didTapRightBarButton))
        
        self.navigationItem.rightBarButtonItem = editBarButton
    }
    
    
    @objc func didTapRightBarButton() {
        if editBarButton.title == "Login" {
            showLoginView()
        } else {
            goToEditProfile()
        }
    }
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    private func showLoginView() {
        let loginView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "loginView")
        self.present(loginView, animated: true, completion: nil)
    }

    private func goToEditProfile() {
        performSegue(withIdentifier: "editProfileSegue", sender: self)
    }
    
}
