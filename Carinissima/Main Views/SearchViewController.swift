//
//  SearchViewController.swift
//  Carinissima
//
//  Created by Edward de los Santos on 8/2/21.
//

import UIKit
import NVActivityIndicatorView
import EmptyDataSet_Swift

class SearchViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    
    var searchResults: [Item] = []
    
    var activityIndicator: NVActivityIndicatorView?
    
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        
        searchTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
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
    @IBAction func didTapSearchBarButton(_ sender: Any) {
        disableSearchButton()
        emptyTextField()
        animateSearchOptions()
        dismissKeyboard()
    }
    
    @IBAction func didTapSearchButton(_ sender: Any) {
        if searchTextField.text != "" {
            searchInFirebase(for: searchTextField.text!)
            emptyTextField()
            animateSearchOptions()
            dismissKeyboard()
            
        }
    }
    
    //MARK: - Search database
    private func searchInFirebase(for name: String) {
        showLoadingIndicator()
        
        searchAlgolia(searchString: name) { itemIds in
            downloadItems(itemIds) { allItems in
                self.searchResults = allItems
                self.tableView.reloadData()
                self.hideLoadingIndicator()
            }
        }
    }
    
    //Helper Functions
    private func emptyTextField() {
        searchTextField.text = ""
    }
    
    private func dismissKeyboard() {
        self.view.endEditing(false)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        searchButton.isEnabled = textField.text != ""
        if searchButton.isEnabled {
            searchButton.backgroundColor = #colorLiteral(red: 0.9733608365, green: 0.553093195, blue: 0.4656373262, alpha: 1)
        } else {
            disableSearchButton()
        }
    }
    
    private func disableSearchButton() {
        searchButton.isEnabled = false
        searchButton.backgroundColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
    }
    
    //MARK: - Animations
    private func animateSearchOptions() {
        UIView.animate(withDuration: 0.4) {
            self.searchView.isHidden = !self.searchView.isHidden
        }
        
        if !self.searchView.isHidden {
            searchTextField.becomeFirstResponder()
        }
    }
    
    //MARK: - Activity indicator
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
    
    private func showItemView(with item: Item) {
        let itemVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "itemView") as! ItemDetailsViewController
        itemVC.item = item
        self.navigationController?.pushViewController(itemVC, animated: true)
    }
}


extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    //MARK: - TableView Data Source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as! ItemTableViewCell
        cell.generateCell(searchResults[indexPath.row])
        
        return cell
    }
    
    //TableView Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        showItemView(with: searchResults[indexPath.row])
    }
}

extension SearchViewController: EmptyDataSetSource, EmptyDataSetDelegate {
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "No items to display!")
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        return UIImage(named: "emptyData")
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "Start searching...")
    }

    func buttonImage(forEmptyDataSet scrollView: UIScrollView, for state: UIControl.State) -> UIImage? {
        return UIImage(named: "search")
    }
    
    func buttonTitle(forEmptyDataSet scrollView: UIScrollView, for state: UIControl.State) -> NSAttributedString? {
        return NSAttributedString(string: "Start searching...")
    }
    
    func emptyDataSet(_ scrollView: UIScrollView, didTapButton button: UIButton) {
        disableSearchButton()
        emptyTextField()
        animateSearchOptions()
    }
}
