//
//  Downloader.swift
//  Carinissima
//
//  Created by Edward de los Santos on 7/27/21.
//

import Foundation
import FirebaseStorage

//MARK: - Vars
let storage = Storage.storage()

func uploadImages(images: [UIImage?], itemId: String, completion: @escaping (_ imageLinks: [String]) -> Void ) {
    
    if Reachabilty.HasConnection() {
        var nameSuffix = 0
        var uploadedImagesCount = 0
        var imageLinkArray: [String] = []
        
        for image in images {
            let fileName = "ItemImages/" + itemId + "/" + "\(nameSuffix)" + ".jpg"
            let imageData = image!.jpegData(compressionQuality: 0.5)
        
            saveImageInFirebase(imageData: imageData!, fileName: fileName) { imageLink in
                
                if let imageLink = imageLink {
                    imageLinkArray.append(imageLink)
                    uploadedImagesCount += 1
                    
                    if uploadedImagesCount == images.count {
                        completion(imageLinkArray)
                    }
                }
            }
            nameSuffix += 1
        }
    }
}

func saveImageInFirebase(imageData: Data, fileName: String, completion: @escaping (_ imageLink: String?) -> Void) {
    
    var task: StorageUploadTask!
    
    let storageRef = storage.reference(forURL: kFILEREFERENCE).child(fileName)
    task = storageRef.putData(imageData, metadata: nil, completion: { metadata, error in
        
        task.removeAllObservers()
        if let error = error {
            print("Error uploading image", error.localizedDescription)
            completion(nil)
            return
        }
        
        storageRef.downloadURL { url, error in
            if let downloadUrl = url {
                completion(downloadUrl.absoluteString)
            } else {
                completion(nil)
                return
            }
        }
    })
}

func downloadImages(imageUrls: [String], completion: @escaping (_ images: [UIImage?]) -> Void) {
    var imageArray: [UIImage] = []
    var downloadCounter = 0
    
    for link in imageUrls {
        let url = URL(string: link)
        let downloadQueue = DispatchQueue(label: "imageDownloadQueue")
        
        downloadQueue.async {
            downloadCounter += 1
            let data = NSData(contentsOf: url! as URL)
            
            if let data = data {
                imageArray.append(UIImage(data: data as Data)!)
                
                if downloadCounter == imageArray.count {
                    DispatchQueue.main.async {
                        completion(imageArray)
                    }
                }
            } else {
                print("couldn't download image")
                completion(imageArray)
            }
        }
    }
}
