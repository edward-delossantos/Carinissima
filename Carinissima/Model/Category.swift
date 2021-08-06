//
//  Category.swift
//  Carinissima
//
//  Created by Edward de los Santos on 7/23/21.
//

import Foundation
import UIKit

class Category {
    
    //MARK: - Vars
    var id: String
    var name: String
    var image: UIImage?
    var imageName: String?
    
    //MARK: - Inits
    init(_name: String, _imageName: String) {
        id = ""
        name = _name
        imageName = _imageName
        image = UIImage(named: _imageName)
    }
    
    init(_dictionary: NSDictionary) {
        id = _dictionary[kOBJECTID] as! String
        name = _dictionary[kNAME] as! String
        image = UIImage(named: _dictionary[kIMAGENAME] as? String ?? "")
    }
}

//MARK: - Download Category
func downloadCategories(completion: @escaping(_ categoryArray: [Category]) -> Void) {
    var categoryArray: [Category] = []
    FireBaseReference(.Category).getDocuments { snapshot, error in
        guard let snapshot = snapshot else {
            completion(categoryArray)
            return
        }
        
        if !snapshot.isEmpty {
            for categoryDict in snapshot.documents{
                categoryArray.append(Category(_dictionary: categoryDict.data() as NSDictionary))
            }
        }
        
        completion(categoryArray)
    }
}

//MARK: - Save Category Functions
func saveCategoryToFirebase(_ category: Category) {
    let id = UUID().uuidString
    category.id = id
    
    FireBaseReference(.Category).document(id).setData(categoryDictionaryFrom(category))
}


//MARK: - Helper functions
func categoryDictionaryFrom(_ category: Category) -> [String : Any] {
    return [kOBJECTID : category.id, kNAME : category.name, kIMAGENAME : category.imageName ?? ""]
}

//use only one time
//func createCategorySet() {
//    
//    let womenClothing = Category(_name: "Women's Clothing & Accessories", _imageName: "womenCloth")
//    let footWaer = Category(_name: "Footwaer", _imageName: "footWaer")
//    let electronics = Category(_name: "Electronics", _imageName: "electronics")
//    let menClothing = Category(_name: "Men's Clothing & Accessories" , _imageName: "menCloth")
//    let health = Category(_name: "Health & Beauty", _imageName: "health")
//    let baby = Category(_name: "Baby Stuff", _imageName: "baby")
//    let home = Category(_name: "Home & Kitchen", _imageName: "home")
//    let car = Category(_name: "Automobiles & Motorcyles", _imageName: "car")
//    let luggage = Category(_name: "Luggage & bags", _imageName: "luggage")
//    let jewelery = Category(_name: "Jewelery", _imageName: "jewelery")
//    let hobby =  Category(_name: "Hobby, Sport, Traveling", _imageName: "hobby")
//    let pet = Category(_name: "Pet products", _imageName: "pet")
//    let industry = Category(_name: "Industry & Business", _imageName: "industry")
//    let garden = Category(_name: "Garden supplies", _imageName: "garden")
//    let camera = Category(_name: "Cameras & Optics", _imageName: "camera")
//    
//    let arrayOfCategories = [womenClothing, footWaer, electronics, menClothing, health, baby, home, car, luggage, jewelery, hobby, pet, industry, garden, camera]
//    
//    for category in arrayOfCategories {
//        saveCategoryToFirebase(category)
//    }
//}
