//
//  Cart.swift
//  Carinissima
//
//  Created by Edward de los Santos on 7/29/21.
//

import Foundation


class Cart {
    
    //MARK: - Vars
    var id: String!
    var ownerId: String!
    var itemIds: [String]!
    
    //MARK: - Inits
    init() {
    }
    
    init(_dictionary: NSDictionary) {
        id = _dictionary[kOBJECTID] as? String
        ownerId = _dictionary[kOWNERID] as? String
        itemIds = _dictionary[kITEMIDS] as? [String]
    }
}

//MARK: - Download items
func downloadCartFromFirestore(_ ownerId: String, completion: @escaping (_ cart: Cart?) -> Void) {
    FireBaseReference(.Cart).whereField(kOWNERID, isEqualTo: ownerId).getDocuments { snapshot, error in
        guard let snapshot = snapshot else {
            completion(nil)
            return
        }
        
        if !snapshot.isEmpty && snapshot.documents.count > 0 {
            let cart = Cart(_dictionary: snapshot.documents.first!.data() as NSDictionary)
            completion(cart)
        } else {
            completion(nil)
        }
    }
}

//MARK: - Save to Firebase
func saveCartToFirestore(_ cart: Cart) {
    FireBaseReference(.Cart).document(cart.id).setData(cartDictionary(from: cart))
}

//MARK: - Helper Functions
func cartDictionary(from cart: Cart) -> [String : Any] {
    return [kOBJECTID : cart.id!, kOWNERID : cart.ownerId!, kITEMIDS : cart.itemIds!]
}

//MARK: - Update Cart
func updateCartInFirestore(_ cart: Cart, withValues: [String: Any], completion: @escaping (_ error: Error?) -> Void ) {
    FireBaseReference(.Cart).document(cart.id).updateData(withValues) { error in
        completion(error)
    }
}
