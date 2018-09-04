//
//  Item.swift
//  
//
//  Created by Heng Brandon on 8/31/18.
//

import Foundation
import RealmSwift

class Item : Object{
    @objc dynamic var title: String = ""
    @objc dynamic var done:Bool = false
    @objc dynamic var dateCreated:Date?
    var parentsCategory = LinkingObjects(fromType: Category.self, property: "items")
}
