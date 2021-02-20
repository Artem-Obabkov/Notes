//
//  RealmManager.swift
//  Notes
//
//  Created by pro2017 on 15/02/2021.
//

import Foundation
import RealmSwift

let realm = try! Realm()

class realmManager {
    
    static func saveDate(_ note: Note) {
        try! realm.write {
            realm.add(note)
        }
    }
    
    static func deleteData(_ note: Note) {
        try! realm.write {
            realm.delete(note)
        }
    }
}
