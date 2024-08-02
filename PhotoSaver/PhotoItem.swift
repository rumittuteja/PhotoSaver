//
//  PhotoItem.swift
//  PhotoSaver
//
//  Created by Rumit Singh Tuteja on 6/7/24.
//

import Foundation


struct PhotoItem: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var description: String
    var data: Data
    
    static func == (lhs: PhotoItem, rhs: PhotoItem) -> Bool {
        lhs.id == rhs.id
    }
}
