//
//  MUser.swift
//  Carinissima
//
//  Created by Edward de los Santos on 7/30/21.
//

import Foundation
import FirebaseAuth

class MUser {
    
    //MARK: - Vars
    let objectId: String
    var email: String
    var firstName: String
    var lastName: String
    var fullName: String
    var purchasedItemIds: [String]
    
    var fullAddress: String?
    var onBoard: Bool
    
    //MARK: - Inits
    init(_objectId: String, _email: String, _firstName: String, _lastName: String) {
        objectId = _objectId
        email = _email
        firstName = _firstName
        lastName = _lastName
        fullName = firstName + " " + lastName
        fullAddress = ""
        onBoard = false
        purchasedItemIds = []
    }
    
    init(_dictionary: NSDictionary) {
        objectId = _dictionary[kOBJECTID] as! String
        
        if let mail = _dictionary[kEMAIL] {
            email = mail as! String
        } else {
            email = ""
        }
        
        if let fname = _dictionary[kFIRSTNAME] {
            firstName = fname as! String
        } else {
            firstName = ""
        }
        
        if let lname = _dictionary[kLASTNAME] {
            lastName = lname as! String
        } else {
            lastName = ""
        }
        
        fullName = firstName + " " + lastName
        
        if let address = _dictionary[kFULLADDRESS] {
            fullAddress = (address as! String)
        } else {
            fullAddress = ""
        }
        
        if let onBoarding = _dictionary[kONBOARD] {
            onBoard = onBoarding as! Bool
        } else {
            onBoard = false
        }
        
        if let purchaseIds = _dictionary[kPURCHASEDITEMIDS] {
            purchasedItemIds = purchaseIds as! [String]
        } else {
            purchasedItemIds = []
        }
    }
    
    //MARK: - Return Current User
    class func currentId() -> String {
        return Auth.auth().currentUser!.uid
    }
    
    class func currentUser() -> MUser? {
        if Auth.auth().currentUser != nil {
            if let dicitionary = UserDefaults.standard.object(forKey: kCURRENTUSER) {
                return MUser.init(_dictionary: dicitionary as! NSDictionary)
            }
        }
        
        return nil
    }
    
    //MARK: - User Management
    class func loginUser(email: String, password: String, completion: @escaping (_ error: Error?, _ isEmailVerified: Bool) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authDataResult, error in
            if error == nil {
                if authDataResult!.user.isEmailVerified {
                    downloadUserFromFirestore(userId: authDataResult!.user.uid, email: email)
                    completion(error, true)
                } else {
                    print("email is not verified")
                    completion(error, false)
                }
            } else {
                completion(error, false)
            }
        }
    }
    
    class func registerUser(with email: String, password: String, completion: @escaping (_ error: Error?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authDataResult, error in
            completion(error)
            
            if error == nil {
                authDataResult!.user.sendEmailVerification { error in
                    if let error = error {
                        print("auth email verification error: ", error.localizedDescription)
                    }
                }
            }
        }
    }
    
    class func logOutCurrentUser(completion: @escaping (_ error: Error?) -> Void) {
        do {
            try Auth.auth().signOut()
            UserDefaults.standard.removeObject(forKey: kCURRENTUSER)
            completion(nil)
            
        } catch let error as NSError {
            completion(error)
        }
    }
    
    //MARK: - Resend link methods
    class func resetPasswordFor(email: String, completion: @escaping (_ error: Error?) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            completion(error)
        }
    }
    
    class func resendVerificationEmail(email: String, completion: @escaping (_ error: Error?) -> Void) {
        Auth.auth().currentUser?.reload(completion: { error in
            Auth.auth().currentUser?.sendEmailVerification(completion: { error in
                print(" resend email error: ", error?.localizedDescription ?? "")
                completion(error)
            })
        })
    }
}

//MARK: - Download user
func downloadUserFromFirestore(userId: String, email: String) {
    FireBaseReference(.User).document(userId).getDocument { snapshot, error in
        guard let snapshot = snapshot else { return }
        
        if snapshot.exists {
            saveUserLocally(mUserDictionary: snapshot.data()! as NSDictionary)
        } else {
            //there is no user, save new in firestore
            let user = MUser(_objectId: userId, _email: email, _firstName: "", _lastName: "")
            saveUserLocally(mUserDictionary: userDictionary(from: user) as NSDictionary)
            saveUserToFirestore(mUser: user)
        }
    }
}

//MARK: - Save user
func saveUserToFirestore(mUser: MUser) {
    FireBaseReference(.User).document(mUser.objectId).setData(userDictionary(from: mUser)) { error in
        if error != nil {
            print("error saving user \(error!.localizedDescription)")
        }
    }
}

func saveUserLocally(mUserDictionary: NSDictionary) {
    UserDefaults.standard.setValue(mUserDictionary, forKey: kCURRENTUSER)
}

//MARK: - Helper Functions
func userDictionary(from user: MUser) -> [String : Any] {
    return [kOBJECTID : user.objectId , kEMAIL : user.email, kFIRSTNAME : user.firstName, kLASTNAME : user.lastName, kFULLNAME : user.fullName, kFULLADDRESS : user.fullAddress ?? "", kONBOARD :  user.onBoard, kPURCHASEDITEMIDS : user.purchasedItemIds]
}

//MARK: - Update User
func updateCurrentUserInFirestore(withValues: [String: Any], completion: @escaping (_ error: Error?) -> Void ) {
    if let dictionary = UserDefaults.standard.object(forKey: kCURRENTUSER) {
        let user = (dictionary as! NSDictionary).mutableCopy() as! NSMutableDictionary
        user.setValuesForKeys(withValues)
        
        FireBaseReference(.User).document(MUser.currentId()).updateData(withValues) { error in
            completion(error)
            
            if error == nil {
                saveUserLocally(mUserDictionary: user)
            }
        }
    }
}
