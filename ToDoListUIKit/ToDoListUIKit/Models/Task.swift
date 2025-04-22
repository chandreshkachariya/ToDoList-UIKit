//
//  Task.swift
//  ToDoListUIKit
//
//  Created by Chandresh Kachariya on 22/04/25.
//

import Foundation

struct Task: Codable {
    let id: String
    var title: String
    var description: String?
    var dueDate: Date?
    var isCompleted: Bool
    var createdAt: Date
    
    // Initializer for new tasks
    init(title: String, description: String? = nil, dueDate: Date? = nil) {
        self.id = UUID().uuidString
        self.title = title
        self.description = description
        self.dueDate = dueDate
        self.isCompleted = false
        self.createdAt = Date()
    }
    
    // Initializer for existing tasks (when editing)
    init(id: String, title: String, description: String?, dueDate: Date?, isCompleted: Bool, createdAt: Date) {
        self.id = id
        self.title = title
        self.description = description
        self.dueDate = dueDate
        self.isCompleted = isCompleted
        self.createdAt = createdAt
    }
}
