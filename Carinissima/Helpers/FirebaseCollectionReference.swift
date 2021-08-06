//
//  FirebaseCollectionReference.swift
//  Carinissima
//
//  Created by Edward de los Santos on 7/23/21.
//

import Foundation
import FirebaseFirestore

enum FCollectionReference: String {
    case User
    case Category
    case Items
    case Cart
}

//Returns the reference for the specified collection
func FireBaseReference(_ collectionReference: FCollectionReference) -> CollectionReference {
    return Firestore.firestore().collection(collectionReference.rawValue)
}
