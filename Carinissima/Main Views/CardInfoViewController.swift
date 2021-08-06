//
//  CardInfoViewController.swift
//  Carinissima
//
//  Created by Edward de los Santos on 8/6/21.
//

import UIKit

class CardInfoViewController: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var doneButton: UIButton!
    
    
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: - IBAction
    @IBAction func didTapDoneButton(_ sender: Any) {
        dismissView()
    }
    
    @IBAction func didTapCancelButton(_ sender: Any) {
        dismissView()
    }
    
    //MARK: - Helpers
    private func dismissView() {
        dismiss(animated: true, completion: nil)
    }
}
