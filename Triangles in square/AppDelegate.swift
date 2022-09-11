//
//  AppDelegate.swift
//  Triangles in square
//
//  Created by Руслан on 10.09.2022.
//

import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let viewController = ViewController()
        viewController.title = "Разбей квадраты на уголки!"
        let navigationController = UINavigationController(rootViewController: viewController)

        window = UIWindow()
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
        return true
    }
}
