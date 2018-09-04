//
//  Catagory.swift
//  Todoey
//
//  Created by Heng Brandon on 8/31/18.
//  Copyright © 2018 Heng Brandon. All rights reserved.
//

import Foundation
import RealmSwift

class Category : Object{
    @objc dynamic var name: String = ""
    @objc dynamic var color: String = ""
    let items = List<Item>()
}
