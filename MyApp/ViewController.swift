//
//  ViewController.swift
//  MyApp
//
//  Created by Robert Ryan on 2/16/21.
//

import UIKit
import MyAppKit

class ViewController: UIViewController {

    @IBOutlet weak var arcView: ArcView!

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [self] in
            startUpdating()
        }
    }

    func startUpdating() {
        arcView.progress = 0

        var current = 0

        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { [weak self] timer in
            current += 1

            guard let self = self, current <= 10 else {
                timer.invalidate()
                return
            }

            self.arcView.progress = CGFloat(current) / 10
        }
    }
}

