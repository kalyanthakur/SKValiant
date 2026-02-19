//
//  AlertViewModel.swift
//  Valiant
//
//  Created by Kalyan Thakur on 06/02/26.
//

import Foundation

class AlertViewModel: ObservableObject {
    
    @Published var arrAllAlerts = [SpogAlert]()
    @Published var showAlertDetailView: Bool = false
    
    init() {
        
    }
    func getSpogAlerts()  {
        LoadingIndicatorView.show()
        networkManager.executeServiceWithURL(urlString: WEBURL.spogAlerts, postParameters: nil) { [weak self] response, error in
            LoadingIndicatorView.hide()
            guard let self = self else { return }
                        
            if error == nil,let result = response {
                do {
                    // Convert dictionary → Data
                    let jsonData = try JSONSerialization.data(withJSONObject: result.dictionaryObject ?? [:], options: [])
                    let response = try JSONDecoder().decode(AlertsResponse.self, from: jsonData)
                    if response.status == 200 {
                        DispatchQueue.main.async {
                            self.arrAllAlerts = response.data
                        }
                    } else {
                        DispatchQueue.main.async {
                            appSharedData.showAlertControllerWith(title: projectName, andMessage: response.message)
                        }
                    }
                } catch {
                    Logger.logDecodingError(error, context: "DashboardViewModel")
                    let errorMessage = appSharedData.getUserFriendlyErrorMessage(from: error, context: "load announcements")
                    DispatchQueue.main.async {
                        appSharedData.showAlertControllerWith(title: projectName, andMessage: errorMessage)
                    }
                }
            } else {
                let errorMessage = appSharedData.getUserFriendlyErrorMessage(from: error, context: "load schedule")
                DispatchQueue.main.async {
                    appSharedData.showAlertControllerWith(title: projectName, andMessage: errorMessage)
                }
            }
        }
    }
}
