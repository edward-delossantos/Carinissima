//
//  CartViewController.swift
//  Carinissima
//
//  Created by Edward de los Santos on 7/29/21.
//

import UIKit
import JGProgressHUD
import Stripe

class CartViewController: UIViewController {

    //MARK: - IBOutlets
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var checkOutButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var totalItemsLabel: UILabel!
    
    //MARK: - Vars
    var cart: Cart?
    var allItems: [Item] = []
    var purchasedItemIds: [String] = []
    var totalPrice = 0.0
    
    let hud = JGProgressHUD(style: .dark)

    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = footerView
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if MUser.currentUser() != nil {
            loadCartFromFirestore()
        } else {
            updateTotalLabels(true)
        }
    }
    
    //MARK: - IBActions
    @IBAction func didTapCheckOut(_ sender: Any) {
        if MUser.currentUser()!.onBoard {
            showPaymentOptions()
        } else {
            // Add notification that redirects to completing the onboarding
            showHudNotification(view: self.view, hud: hud, text: "Please complete your profile!", isError: true)
        }
    }
    
    //MARK: - Download Cart
    private func loadCartFromFirestore() {
        downloadCartFromFirestore(MUser.currentId()) { cart in
            self.cart = cart
            self.getCartItems()
        }
    }
    
    private func getCartItems() {
        if cart != nil {
            downloadItems(cart!.itemIds) { items in
                self.allItems = items
                self.updateTotalLabels(false)
                self.tableView.reloadData()
            }
        }
    }
    
    //MARK: - Stripe Checkout
    private func payButtonPressed(token: STPToken) {
        totalPrice = 0
        
        for item in allItems {
            purchasedItemIds.append(item.id)
            totalPrice += item.price
        }
        //Convert to cents
        totalPrice = totalPrice * 100
        
        StripeClient.sharedClient.createAndConfirmPayment(token, amount: Int(totalPrice)) { error in
            if let error = error {
                print("error \(error.localizedDescription)")
            } else {
                self.emptyCart()
                self.addToPucharseHistory(self.purchasedItemIds)
                showHudNotification(view: self.view, hud: self.hud, text: "Payment Successful!", isError: false)
            }
        }
    }
    
    private func showPaymentOptions() {
        let alertController = UIAlertController(title: "Payment Options", message: "Choose a payment option", preferredStyle: .actionSheet)
        
        let cardAction = UIAlertAction(title: "Pay with Card", style: .default) { action in
            let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "cardInfoVC") as! CardInfoViewController
            
            self.present(vc, animated: true, completion: nil)
        }
        //Add apple pay ***
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(cardAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    //MARK: - Helper Functions
    private func updateTotalLabels(_ isEmpty: Bool) {
        totalItemsLabel.text = isEmpty ? "0" : "\(allItems.count)"
        totalLabel.text = CartTotalPrice()
        checkoutButtonStatus()
    }
    
    //Calculate total cart price
    private func CartTotalPrice() -> String {
        var totalPrice = 0.0
        
        for item in allItems {
            totalPrice += item.price
        }
        
        return "Total price: " + convertToCurrency(totalPrice)
    }
    
    private func emptyCart() {
        purchasedItemIds.removeAll()
        allItems.removeAll()
        tableView.reloadData()
        
        cart!.itemIds = []
        updateCartInFirestore(cart!, withValues: [kITEMIDS : cart!.itemIds!]) { error in
            if let error = error {
                print("Error updating basket \(error.localizedDescription)")
            }
            
            self.getCartItems()
        }
    }
    
    private func addToPucharseHistory(_ itemIds: [String]) {
        if let currentUser = MUser.currentUser() {
            let newItemIds = currentUser.purchasedItemIds + itemIds
            
            updateCurrentUserInFirestore(withValues: [kPURCHASEDITEMIDS : newItemIds]) { error in
                if let error = error {
                    print("Error adding purchased items \(error.localizedDescription)")
                }
            }
        }
    }

    private func removeItemFromCart(itemId: String) {
        for i in 0..<cart!.itemIds.count {
            if itemId == cart!.itemIds[i] {
                cart!.itemIds.remove(at: i)
                return
            }
        }
    }

    //Control CheckoutButton
    private func checkoutButtonStatus () {
        checkOutButton.isEnabled = allItems.count > 0
        if checkOutButton.isEnabled {
            checkOutButton.backgroundColor = #colorLiteral(red: 0.973748982, green: 0.5231565833, blue: 0.4656918049, alpha: 1)
        } else {
            checkOutButton.backgroundColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
        }
    }
    
    //MARK: - Navigation
    private func showItemsView(item: Item) {
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "itemView") as! ItemDetailsViewController
        vc.item = item
        self.navigationController?.pushViewController(vc, animated: true)
    }
}


extension CartViewController: UITableViewDelegate, UITableViewDataSource {
    
    //MARK: - TableView Data Source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as! ItemTableViewCell
        cell.generateCell(allItems[indexPath.row])
        
        return cell
    }
    
    //MARK: - TableView Delegate
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let itemToDelete = allItems[indexPath.row]
            allItems.remove(at: indexPath.row)
            tableView.reloadData()
            
            removeItemFromCart(itemId: itemToDelete.id)
            
            updateCartInFirestore(cart!, withValues: [kITEMIDS : cart!.itemIds!]) { error in
                if error != nil {
                    print("error updating cart: \(error!.localizedDescription)")
                }
                
                self.getCartItems()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        showItemsView(item: allItems[indexPath.row])
    }
}
