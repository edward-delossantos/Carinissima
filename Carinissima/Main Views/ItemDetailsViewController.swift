//
//  ItemDetailsViewController.swift
//  Carinissima
//
//  Created by Edward de los Santos on 7/28/21.
//

import UIKit
import JGProgressHUD

class ItemDetailsViewController: UIViewController {

    //MARK: - IBOutlets
    @IBOutlet weak var imageCollectionView: UICollectionView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UILabel!
    
    //MARK: - Vars
    var item: Item!
    var itemImages: [UIImage] = []
    let hud = JGProgressHUD(style: .dark)
    
    private let sectionInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
    private let cellHeight : CGFloat = 196.0
    private let itemsPerRow: CGFloat = 1
    
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        downloadPictures()
        self.navigationItem.leftBarButtonItems = [UIBarButtonItem(
                                                    image: UIImage(named: "back"),
                                                    style: .plain,
                                                    target: self,
                                                    action: #selector(self.backAction))]
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(
                                                    image: UIImage(named: "addToBasket"),
                                                    style: .plain,
                                                    target: self,
                                                    action: #selector(self.addToCart))]
    }
    
    //OBJC functions
    @objc func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func addToCart() {
        if MUser.currentUser() != nil {
            downloadCartFromFirestore(MUser.currentId()) { cart in
                if let cart = cart {
                    cart.itemIds.append(self.item.id)
                    self.updateCart(cart: cart, withValues: [kITEMIDS: cart.itemIds!])
                } else {
                    self.createNewCart()
                }
            }
        } else {
            showLoginView()
        }
    }
    
    //MARK: - Add To Cart
    private func createNewCart() {
        let newCart = Cart()
        newCart.id = UUID().uuidString
        newCart.ownerId = MUser.currentId()
        newCart.itemIds = [self.item.id]
        saveCartToFirestore(newCart)
        
        showHudNotification(view: self.view, hud: hud, text: "Added to cart", isError: false)
    }
    
    private func updateCart(cart: Cart, withValues: [String : Any]) {
        updateCartInFirestore(cart, withValues: withValues) { error in
            if let error = error {
                showHudNotification(view: self.view, hud: self.hud, text: error.localizedDescription, isError: true)
            } else {
                showHudNotification(view: self.view, hud: self.hud, text: "Added to Cart!", isError: false)
            }
        }
    }
    
    //MARK: - Download Pictures
    private func downloadPictures() {
        if item != nil && item.imageLinks != nil {
            downloadImages(imageUrls: item.imageLinks) { images in
                if images.count > 0 {
                    self.itemImages = images as! [UIImage]
                    self.imageCollectionView.reloadData()
                }
            }
        }
    }
    
    //MARK: - Helper Functions
    private func showLoginView() {
        let loginView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "loginView")
        
        self.present(loginView, animated: true, completion: nil)
    }
    
    //Setup UI
    private func setupUI() {
        if item != nil {
            self.title = item.name
            nameLabel.text = item.name
            priceLabel.text = convertToCurrency(item.price)
            descriptionTextView.text = item.description
        }
    }
}


extension ItemDetailsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    //MARK: - CollectionView Data Source
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemImages.count == 0 ? 1 : itemImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! ImageCollectionViewCell
        
        if itemImages.count > 0 {
            cell.setupImage(itemImage: itemImages[indexPath.row])
        }
        
        return cell
    }
}


extension ItemDetailsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.frame.width - sectionInsets.left
        
        //Create square sections
        return CGSize(width: availableWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}

