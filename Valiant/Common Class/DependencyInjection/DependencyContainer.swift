//
//  DependencyContainer.swift
//  Valiant
//
//  Created by Kalyan Thakur on 02/02/26.
//


import Foundation
import SwiftUI

/// Dependency container that holds all app dependencies
/// This enables dependency injection and makes the code testable
struct DependencyContainer {
    let networkManager: NetworkManagerProtocol
    let appUserDefaults: AppUserDefaultsProtocol
    let appShareData: AppShareDataProtocol
    
    /// Default production dependencies
    static let production = DependencyContainer(
        networkManager: NetworkManager.sharedInstance,
        appUserDefaults: AppUserDefaults.shared,
        appShareData: AppsharedData.sharedInstance
    )
    
    /// Create a container with custom dependencies (useful for testing)
    init(
        networkManager: NetworkManagerProtocol,
        appUserDefaults: AppUserDefaultsProtocol,
        appShareData: AppShareDataProtocol
    ) {
        self.networkManager = networkManager
        self.appUserDefaults = appUserDefaults
        self.appShareData = appShareData
    }
}

/// Environment key for dependency injection in SwiftUI
struct DependenciesKey: EnvironmentKey {
    static let defaultValue: DependencyContainer = .production
}

extension EnvironmentValues {
    var dependencies: DependencyContainer {
        get { self[DependenciesKey.self] }
        set { self[DependenciesKey.self] = newValue }
    }
}

/// View modifier to inject dependencies
extension View {
    func injectDependencies(_ container: DependencyContainer) -> some View {
        self.environment(\.dependencies, container)
    }
}