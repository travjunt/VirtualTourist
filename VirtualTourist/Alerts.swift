//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by Travis McCormick on 12/29/17.
//  Copyright © 2017 TravisMcCormick. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Alerts

class Alerts {
    
    class func pushAlert(controller: UIViewController, message: String) {
        let alert = UIAlertController(title: "Something went wrong.", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        performUIUpdatesOnMain {
            controller.present(alert, animated: true, completion: nil)
        }
    }
}
