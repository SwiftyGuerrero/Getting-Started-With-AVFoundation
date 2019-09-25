//
//  ViewController.swift
//  CameraBasic
//
//  Created by Emanuel Guerrero on 9/24/19.
//  Copyright © 2019 ModernizingMedicine. All rights reserved.
//

import UIKit

// MARK: - ViewController

final class ViewController: UIViewController {
    
    // MARK: - Private Instance Properties
    
    private lazy var launchCameraButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.setTitle(NSLocalizedString("Launch Camera", comment: ""), for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(launchCamera), for: .touchUpInside)
        
        return button
    }()
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    // MARK: - Private Instance Methods
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(launchCameraButton)
        
        launchCameraButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        launchCameraButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    @objc
    private func launchCamera() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.showsCameraControls = true
        imagePicker.delegate = self
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    private func showTakenPhoto(_ photo: UIImage) {
        let previewViewController = PreviewViewController(image: photo)
        
        navigationController?.pushViewController(previewViewController, animated: true)
    }
}

// MARK: - UIImagePickerControllerDelegate

extension ViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            dismiss(animated: true) { [weak self] in
                self?.showTakenPhoto(image)
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
