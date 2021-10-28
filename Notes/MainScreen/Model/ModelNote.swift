//
//  ModelNote.swift
//  Notes
//
//  Created by pro2017 on 11/02/2021.
//

import Foundation
import RealmSwift

class Note: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var subName: String?
    @objc dynamic var isFavourite: Bool = false
    @objc dynamic var date = Date()
    @objc dynamic var noteText: String = ""
    
    convenience init(name: String, subName: String, isFavourite: Bool, noteText: String) {
        self.init()
        self.name = name
        self.subName = subName
        self.isFavourite = isFavourite
        self.noteText = noteText
    }
}
