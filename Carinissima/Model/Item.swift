//
//  Item.swift
//  Carinissima
//
//  Created by Edward de los Santos on 7/26/21.
//

import Foundation
import UIKit
import InstantSearchClient

class Item {
    
    //MARK: - Vars
    var id: String!
    var categoryId: String!
    var name: String!
    var description: String!
    var price: Double!
    var imageLinks: [String]!
    
    //MARK: - Inits
    init() {}
    
    init(_dictionary: NSDictionary) {
        id = _dictionary[kOBJECTID] as? String
        categoryId = _dictionary[kCATEGORYID] as? String
        name = _dictionary[kNAME] as? String
        description = _dictionary[kDESCRIPTION] as? String
        price = _dictionary[kPRICE] as? Double
        imageLinks = _dictionary[kIMAGELINKS] as? [String]
    }
    
}

//MARK: - Save Items
func saveItemToFireStore(_ item: Item) {
    FireBaseReference(.Items).document(item.id).setData(itemDictionary(from: item))
}

//MARK: - Load Items
func loadItemsFromFirebase(_ withCategoryId: String, completion: @escaping (_ itemArray: [Item]) -> Void) {
    var itemArray: [Item] = []
    
    FireBaseReference(.Items).whereField(kCATEGORYID, isEqualTo: withCategoryId).getDocuments { snapshot, error in
        guard let snapshot = snapshot else {
            completion(itemArray)
            return
        }
        
        if !snapshot.isEmpty {
            
            for itemDict in snapshot.documents {
                itemArray.append(Item(_dictionary: itemDict.data() as NSDictionary))
            }
        }
        
        completion(itemArray)
    }
}

func downloadItems(_ withIds: [String], completion: @escaping (_ itemArray: [Item]) -> Void) {
    var count = 0
    var itemArray: [Item] = []
    
    if withIds.count > 0 {
        for itemId in withIds {
            FireBaseReference(.Items).document(itemId).getDocument { snapshot, error in
                
                guard let snapshot = snapshot else {
                    completion(itemArray)
                    return
                }
                
                if snapshot.exists {
                    itemArray.append(Item(_dictionary: snapshot.data()! as NSDictionary))
                    count += 1
                } else {
                    completion(itemArray)
                }
                
                if count == withIds.count {
                    completion(itemArray)
                }
            }
        }
    } else {
        completion(itemArray)
    }
}


//MARK: - Helper Functions
func itemDictionary(from item: Item) -> [String : Any] {
    return [kOBJECTID : item.id!, kCATEGORYID : item.categoryId!, kNAME : item.name!, kDESCRIPTION : item.description!, kPRICE : item.price!, kIMAGELINKS : item.imageLinks ?? []]
}

//MARK: - Algolia Funcs
func saveItemToAlgolia(_ item: Item) {
    let index = AlgoliaService.shared.index
    let itemToSave = itemDictionary(from: item)
    
    index.addObject(itemToSave, withID: item.id, requestOptions: nil) { content, error in
        if error != nil {
            print("Error saving to algolia \(error!.localizedDescription)")
        } else {
            print("added to algolia")
        }
    }
}

func searchAlgolia(searchString: String, completion: @escaping (_ itemArray: [String]) -> Void) {
    let index = AlgoliaService.shared.index
    var resultIds: [String] = []
    
    let query = Query(query: searchString)
    
    query.attributesToRetrieve = [kNAME, kDESCRIPTION]
    
    index.search(query) { content, error in
        if error == nil {
            let cont = content!["hits"] as! [[String : Any]]
    
            resultIds = []
            
            for result in cont {
                resultIds.append(result[kOBJECTID] as! String)
            }
            
            completion(resultIds)
        } else {
            print("Error algolia search \(error!.localizedDescription)")
            completion(resultIds)
        }
    }
}
