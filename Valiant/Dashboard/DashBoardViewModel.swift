//
//  DashBoardViewModel.swift
//  Valiant
//
//  Created by Kalyan Thakur on 04/02/26.
//

import Foundation

struct MenuItems: Codable, Identifiable,Hashable {
    let id: Int?
    let name: String?
    let icon: String?
    
    // Custom Coding Keys (map snake_case & mismatched keys)
    enum CodingKeys: String, CodingKey {
        case id, name, icon
    }
}

class DashBoardViewModel: ObservableObject {
    
    @Published var arrSpogAlerts = [SpogAlert]()
    @Published var arrSpogEvents = [SpogEvent]()
    @Published var arrPresidentsMessages = [PresidentsMessage]()
    @Published var showAlertView = false
    @Published var showCalendarView = false
    @Published var showAlertDetailView: Bool = false
    @Published var showEventView = false
    @Published var showEventDetailView = false
    @Published var showMessageView = false
    @Published var showMessageDetailView = false
    @Published var showDocumentView = false
    @Published var showRequestGuidRepView = false
    @Published var showContactSpogView = false
    @Published var showAdditionalInfoView = false
    @Published var showProfileView = false

    init() {
    }
    
    func getSpogHomeData()  {
        // Ensure any previous loading indicator is hidden first
        LoadingIndicatorView.hide()
        
        // Small delay to ensure UI is ready
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            LoadingIndicatorView.show()
            networkManager.executeServiceWithURL(urlString: WEBURL.getSpogHomeData, postParameters: nil) { [weak self] response, error in
                // Always hide loading indicator
                DispatchQueue.main.async {
                    LoadingIndicatorView.hide()
                }
                
                guard let self = self else { return }
                
                if error == nil,let result = response {
                    do {
                        // Convert dictionary → Data
                        let jsonData = try JSONSerialization.data(withJSONObject: result.dictionaryObject ?? [:], options: [])
                        let response = try JSONDecoder().decode(HomeResponse.self, from: jsonData)
                        if response.status == 200 {
                            DispatchQueue.main.async {
                                self.arrSpogAlerts = response.data.alertsData
                                self.arrSpogEvents = response.data.eventData
                                self.arrPresidentsMessages = response.data.presidentMsg
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
}
