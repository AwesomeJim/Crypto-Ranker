//
//  UIViewController+ErrorAlert.swift
//  CryptoCoinranking
//
//  Created by Awesome Jim on 07/11/2025.
//

import UIKit

extension UIViewController {
    func presentErrorAlert(error: AppError) {
        let alert = UIAlertController(title: error.title, message: error.message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
}
