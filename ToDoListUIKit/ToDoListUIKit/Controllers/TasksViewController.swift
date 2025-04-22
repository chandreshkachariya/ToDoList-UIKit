//
//  TasksViewController.swift
//  ToDoListUIKit
//
//  Created by Chandresh Kachariya on 22/04/25.
//

import Foundation
import UIKit

class TasksViewController: UIViewController {
    private var tasks: [Task] = []
    private var filteredTasks: [Task] = []
    
    // Define filter states
    private enum FilterState: Int {
        case all = 0
        case pending = 1
        case completed = 2
    }
    
    private lazy var segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["All", "Pending", "Completed"])
        control.selectedSegmentIndex = FilterState.pending.rawValue
        control.addTarget(self, action: #selector(filterChanged), for: .valueChanged)
        return control
    }()
    
    @IBOutlet weak var tableView: UITableView!
    
    private lazy var addButton: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTask))
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadTasks()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "My Tasks"
        navigationItem.rightBarButtonItem = addButton
        
        // Add segmented control to navigation bar
        navigationItem.titleView = segmentedControl
        
        tableView.register(TaskTableViewCell.self, forCellReuseIdentifier: TaskTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func loadTasks() {
        tasks = TaskManager.shared.loadTasks()
        applyFilter()
        tableView.reloadData()
    }
    
    private func applyFilter() {
        guard let filterState = FilterState(rawValue: segmentedControl.selectedSegmentIndex) else { return }
        
        switch filterState {
        case .all:
            filteredTasks = tasks
        case .pending:
            filteredTasks = tasks.filter { !$0.isCompleted }
        case .completed:
            filteredTasks = tasks.filter { $0.isCompleted }
        }
    }
    
    @objc private func filterChanged() {
        UIView.transition(with: tableView, duration: 0.3, options: .transitionCrossDissolve, animations: {
            self.applyFilter()
            self.tableView.reloadData()
        })
    }
    
    @objc private func addTask() {        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AddEditTaskViewController") as! AddEditTaskViewController
        vc.completion = { [weak self] newTask in
            TaskManager.shared.addTask(newTask)
            self?.loadTasks()
            self?.animateAddTask()
        }
        present(UINavigationController(rootViewController: vc), animated: true)
    }
    
    private func animateAddTask() {
        guard !filteredTasks.isEmpty else { return }
        
        let indexPath = IndexPath(row: filteredTasks.count - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.1, options: .curveEaseInOut, animations: {
                cell.transform = CGAffineTransform.identity
            })
        }
    }
    
    private func animateDeleteTask(at indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            UIView.animate(withDuration: 0.3, animations: {
                cell.alpha = 0
                cell.transform = CGAffineTransform(translationX: -cell.frame.width, y: 0)
            }, completion: { _ in
                self.tableView.reloadData()
            })
        }
    }
}

// UITableViewDelegate and UITableViewDataSource extensions remain the same

extension TasksViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredTasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TaskTableViewCell.identifier, for: indexPath) as? TaskTableViewCell else {
            return UITableViewCell()
        }
        
        let task = filteredTasks[indexPath.row]
        cell.configure(with: task)
        cell.completion = { [weak self] isCompleted in
            var updatedTask = task
            updatedTask.isCompleted = isCompleted
            TaskManager.shared.updateTask(updatedTask)
            self?.loadTasks()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let task = filteredTasks[indexPath.row]
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "TaskDetailViewController") as! TaskDetailViewController
        vc.task = task
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let task = filteredTasks[indexPath.row]
            
            let alert = UIAlertController(title: "Delete Task", message: "Are you sure you want to delete this task?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                TaskManager.shared.deleteTask(withId: task.id)
                self.animateDeleteTask(at: indexPath)
                self.loadTasks()
            }))
            
            present(alert, animated: true)
        }
    }
}
