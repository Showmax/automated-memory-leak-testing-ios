//
//  GeneratorViewController.swift
//  Leakmax
//
//  Created by Ondrej Macoszek on 12/10/2018.
//  Copyright © 2018 com.showmax. All rights reserved.
//

import UIKit

class GeneratorViewController: UIViewController {

    // MARK: - Internal

    private lazy var generator = Generator(delegate: self)

    // MARK: - User Interface

    @IBOutlet var numberLabel: UILabel?
    @IBOutlet var activityIndicator: UIActivityIndicatorView?

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        generator.generate()
    }
    
    @IBAction func onDismissTap(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - GeneratorDelegate

extension GeneratorViewController: GeneratorDelegate {
    func didGenerate(number: Int) {
        numberLabel?.text = "\(number)"
        activityIndicator?.stopAnimating()
    }
}
