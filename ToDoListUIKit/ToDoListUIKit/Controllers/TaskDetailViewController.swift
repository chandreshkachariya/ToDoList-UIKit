//
//  TaskDetailViewController.swift
//  ToDoListUIKit
//
//  Created by Chandresh Kachariya on 22/04/25.
//

import Foundation
import UIKit

class TaskDetailViewController: UIViewController {
    var task: Task?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    private lazy var editButton: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editTask))
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureWithTask()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Task Details"
        navigationItem.rightBarButtonItem = editButton
        
        titleLabel.font = UIFont.preferredFont(forTextStyle: .title1)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        descriptionLabel.font = UIFont.preferredFont(forTextStyle: .body)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        dateLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        dateLabel.textColor = .tertiaryLabel
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func configureWithTask() {
        titleLabel.text = task?.title
        descriptionLabel.text = task?.description ?? "No description"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        if let dueDate = task?.dueDate {
            dateLabel.text = "Due: \(dateFormatter.string(from: dueDate))"
        } else {
            dateLabel.text = "No due date"
        }
    }
    
    @objc private func editTask() {        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AddEditTaskViewController") as! AddEditTaskViewController
        vc.task = task
        vc.completion = { [weak self] updatedTask in
            TaskManager.shared.updateTask(updatedTask)
            self?.navigationController?.popViewController(animated: true)
        }
        present(UINavigationController(rootViewController: vc), animated: true)

    }
}
