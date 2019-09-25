//
//  PreviewViewController.swift
//  CameraAdvanced
//
//  Created by Emanuel Guerrero on 9/24/19.
//  Copyright © 2019 ModernizingMedicine. All rights reserved.
//

import UIKit

final class PreviewViewController: UIViewController {
    
    // MARK: - Private Instance Properties
    
    private let image: UIImage
    
    private lazy var imageView: UIImageView = {
        let newImageView = UIImageView(frame: .zero)
        newImageView.contentMode = .scaleAspectFit
        newImageView.translatesAutoresizingMaskIntoConstraints = false
        newImageView.image = image
        
        return newImageView
    }()
    
    // MARK: - Initializers
    
    init(image: UIImage) {
        self.image = image
        
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    // MARK: - Private Instance Methods
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(imageView)
        
        imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
    }
}
