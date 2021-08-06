//
//  AddItemViewController.swift
//  Carinissima
//
//  Created by Edward de los Santos on 7/27/21.
//

import UIKit
import Gallery
import JGProgressHUD
import NVActivityIndicatorView

class AddItemViewController: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    //MARK: - Vars
    var category: Category!
    var gallery: GalleryController!
    let hud = JGProgressHUD(style: .dark)
    
    var activityIndicator: NVActivityIndicatorView?
    
    var itemImages: [UIImage?] = []
    
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        activityIndicator = NVActivityIndicatorView(
            frame: CGRect(x: self.view.frame.width / 2 - 30,
                          y: self.view.frame.height / 2 - 30,
                          width: 60,
                          height: 60),
            type: .ballPulse,
            color: #colorLiteral(red: 0.992338717, green: 0.5598635077, blue: 0.487847507, alpha: 1),
            padding: nil)
    }
    
    
    //MARK: - IBActions
    @IBAction func didTapDoneBarButton(_ sender: Any) {
        dismissKeyboard()
        
        if(fieldsAreCompleted()) {
            saveToFirebase()
        } else {
            showHudNotification(view: self.view, hud: hud, text: "All fields are required!", isError: true)
        }
    }
    
    @IBAction func didTapCameraButton(_ sender: Any) {
        itemImages = []
        showImageGallery()
    }
    
    @IBAction func didTapBackground(_ sender: Any) {
        dismissKeyboard()
    }
    
    //MARK: - Helper Functions
    private func dismissKeyboard() {
        self.view.endEditing(false)
    }
    
    private func fieldsAreCompleted() -> Bool {
        return (titleTextField.text != "" && priceTextField.text != "" && descriptionTextView.text != "")
    }
    
    private func dismissView() {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - Save Item
    private func saveToFirebase() {
        showLoadingIndicator()
        
        let item = Item()
        item.id = UUID().uuidString
        item.name = titleTextField.text
        item.categoryId = category.id
        item.description = descriptionTextView.text
        item.price = Double(priceTextField.text!)
        
        if itemImages.count > 0 {
            uploadImages(images: itemImages, itemId: item.id) { imageLinkArry in

                item.imageLinks = imageLinkArry
                saveItemToFireStore(item)
                saveItemToAlgolia(item)
                self.hideLoadingIndicator()
                self.dismissView()
            }
        } else {
            saveItemToFireStore(item)
            saveItemToAlgolia(item)
            hideLoadingIndicator()
            dismissView()
        }
    }
    
    //MARK: - Activity Indication
    private func showLoadingIndicator() {
        if activityIndicator != nil {
            self.view.addSubview(activityIndicator!)
            activityIndicator!.startAnimating()
        }
    }
    
    private func hideLoadingIndicator() {
        if activityIndicator != nil {
            activityIndicator!.removeFromSuperview()
            activityIndicator!.stopAnimating()
        }
    }
    
    //MARK: - Show Gallery
    private func showImageGallery() {
        self.gallery = GalleryController()
        self.gallery.delegate = self
        
        Config.tabsToShow = [.cameraTab, .imageTab]
        Config.Camera.imageLimit = 6
        
        self.present(self.gallery, animated: true, completion: nil)
    }
}

extension AddItemViewController: GalleryControllerDelegate {
    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
        if images.count > 0 {
            Image.resolve(images: images) { resolvedImages in
                self.itemImages = resolvedImages
            }
        }
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryControllerDidCancel(_ controller: GalleryController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    
}
