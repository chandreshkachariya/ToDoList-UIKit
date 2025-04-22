//
//  TaskManager.swift
//  ToDoListUIKit
//
//  Created by Chandresh Kachariya on 22/04/25.
//

import Foundation

class TaskManager {
    static let shared = TaskManager()
    private let tasksKey = "savedTasks"
    
    private init() {}
    
    func saveTasks(_ tasks: [Task]) {
        if let encoded = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(encoded, forKey: tasksKey)
        }
    }
    
    func loadTasks() -> [Task] {
        if let data = UserDefaults.standard.data(forKey: tasksKey),
           let tasks = try? JSONDecoder().decode([Task].self, from: data) {
            return tasks
        }
        return []
    }
    
    func addTask(_ task: Task) {
        var tasks = loadTasks()
        tasks.append(task)
        saveTasks(tasks)
    }
    
    func updateTask(_ updatedTask: Task) {
        var tasks = loadTasks()
        if let index = tasks.firstIndex(where: { $0.id == updatedTask.id }) {
            tasks[index] = updatedTask
            saveTasks(tasks)
        }
    }
    
    func deleteTask(withId id: String) {
        var tasks = loadTasks()
        tasks.removeAll { $0.id == id }
        saveTasks(tasks)
    }
}
