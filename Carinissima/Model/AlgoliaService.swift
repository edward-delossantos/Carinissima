//
//  AlgoliaService.swift
//  Carinissima
//
//  Created by Edward de los Santos on 8/2/21.
//

import Foundation
import InstantSearchClient

class AlgoliaService {
    static let shared = AlgoliaService()
    
    let client = Client(appID: kALGOLIA_APP_ID, apiKey: kALGOLIA_ADMIN_KEY)
    let index = Client(appID: kALGOLIA_APP_ID, apiKey: kALGOLIA_ADMIN_KEY).index(withName: "item_Name")
}
