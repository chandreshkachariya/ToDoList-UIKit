//
//  AddEditTaskViewController.swift
//  ToDoListUIKit
//
//  Created by Chandresh Kachariya on 22/04/25.
//

import Foundation
import UIKit

class AddEditTaskViewController: UIViewController {
    var completion: ((Task) -> Void)?
    var task: Task?
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var dateSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        populateFieldsIfEditing()
        datePicker.isHidden = !dateSwitch.isOn
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = task == nil ? "Add Task" : "Edit Task"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(save))
        
        titleTextField.placeholder = "Task title"
        titleTextField.borderStyle = .roundedRect
        titleTextField.delegate = self
        titleTextField.translatesAutoresizingMaskIntoConstraints = false

        descriptionTextView.layer.borderColor = UIColor.systemGray5.cgColor
        descriptionTextView.layer.borderWidth = 1
        descriptionTextView.layer.cornerRadius = 5
        descriptionTextView.font = UIFont.preferredFont(forTextStyle: .body)
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false

        datePicker.datePickerMode = .dateAndTime
        datePicker.minimumDate = Date()
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        
        dateSwitch.isOn = false
        dateSwitch.addTarget(self, action: #selector(toggleDatePicker), for: .valueChanged)
        dateSwitch.translatesAutoresizingMaskIntoConstraints = false
        dateSwitch.isUserInteractionEnabled = true  // Explicitly enable interaction
    }
    
    private func updateDatePickerVisibility(animated: Bool) {
        let isHidden = !dateSwitch.isOn
        
        if animated {
            UIView.animate(withDuration: 0.3) {
                self.datePicker.isHidden = isHidden
                self.view.layoutIfNeeded()
            }
        } else {
            datePicker.isHidden = isHidden
        }
    }
    
    private func createDateRow() -> UIView {
        let row = UIView()
        row.translatesAutoresizingMaskIntoConstraints = false
        row.isUserInteractionEnabled = true  // Enable interaction for the entire row
        
        let label = UILabel()
        label.text = "Due Date"
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        row.addSubview(label)
        row.addSubview(dateSwitch)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            label.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            
            dateSwitch.trailingAnchor.constraint(equalTo: row.trailingAnchor),
            dateSwitch.centerYAnchor.constraint(equalTo: row.centerYAnchor)
        ])
        
        return row
    }
    
    private func populateFieldsIfEditing() {
        guard let task = task else { return }
        
        titleTextField.text = task.title
        descriptionTextView.text = task.description
        
        if let dueDate = task.dueDate {
            dateSwitch.isOn = true
            datePicker.date = dueDate
        }
        updateDatePickerVisibility(animated: false)
    }
    
    @objc private func toggleDatePicker() {
        UIView.animate(withDuration: 0.3) {
            self.datePicker.isHidden = !self.dateSwitch.isOn
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func cancel() {
        dismiss(animated: true)
    }
    
    @objc private func save() {
        guard let title = titleTextField.text, !title.isEmpty else {
            showAlert(title: "Missing Title", message: "Please enter a title for your task")
            return
        }
        
        let description = descriptionTextView.text.isEmpty ? nil : descriptionTextView.text
        let dueDate = dateSwitch.isOn ? datePicker.date : nil
        
        // If editing existing task, preserve its ID and creation date
        let task: Task
        if let existingTask = self.task {
            task = Task(
                id: existingTask.id,
                title: title,
                description: description,
                dueDate: dueDate,
                isCompleted: existingTask.isCompleted,
                createdAt: existingTask.createdAt
            )
        } else {
            task = Task(
                title: title,
                description: description,
                dueDate: dueDate
            )
        }
        
        completion?(task)
        dismiss(animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension AddEditTaskViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
