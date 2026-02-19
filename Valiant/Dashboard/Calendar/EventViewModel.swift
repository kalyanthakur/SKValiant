//
//  EventViewModel.swift
//  Valiant
//
//  Created by Kalyan Thakur on 08/02/26.
//

import Foundation

class EventViewModel: ObservableObject {
    
    @Published var arrSpogEvents = [SpogEvent]()
    @Published var showEventView = false
    @Published var showEventDetailView = false
    @Published var eventDetail: SpogEvent?


    init() {
        
    }
    
    func getSpogEvents()  {
        LoadingIndicatorView.show()
        networkManager.executeServiceWithURL(urlString: WEBURL.getSpogEvents, postParameters: nil) { [weak self] response, error in
            LoadingIndicatorView.hide()
            guard let self = self else { return }
                        
            if error == nil,let result = response {
                do {
                    // Convert dictionary → Data
                    let jsonData = try JSONSerialization.data(withJSONObject: result.dictionaryObject ?? [:], options: [])
                    let response = try JSONDecoder().decode(EventsResponse.self, from: jsonData)
                    if response.status == 200 {
                        DispatchQueue.main.async {
                            self.arrSpogEvents = response.data
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
    
    func getSpogEventDetailsById(eventId:Int)  {
        LoadingIndicatorView.show()
        networkManager.executeServiceWithURL(urlString: WEBURL.spogEventDetailsById + "/\(eventId)", postParameters: nil) { [weak self] response, error in
            LoadingIndicatorView.hide()
            guard let self = self else { return }
                        
            if error == nil,let result = response {
                do {
                    // Convert dictionary → Data
                    let jsonData = try JSONSerialization.data(withJSONObject: result.dictionaryObject ?? [:], options: [])
                    let response = try JSONDecoder().decode(EventDetailResponse.self, from: jsonData)
                    if response.status == 200 {
                        DispatchQueue.main.async {
                            self.eventDetail = response.data
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
    
    func bookmarkPost(itemType:String, itemId:Int, isBookmark:Int)  {
        LoadingIndicatorView.show()
        let param = [
            "itemType": itemType,
            "itemId": itemId,
            "isBookmark": isBookmark
        ] as [String : Any]
        networkManager.executeServiceWithURL(urlString: WEBURL.bookmarkPost, postParameters: param) { [weak self] response, error in
            LoadingIndicatorView.hide()
            guard let self = self else { return }
                        
            if error == nil,let result = response {
                do {
                    // Convert dictionary → Data
                    let jsonData = try JSONSerialization.data(withJSONObject: result.dictionaryObject ?? [:], options: [])
                    let response = try JSONDecoder().decode(BookmarkResponse.self, from: jsonData)
                    if response.status == 200 {
                        DispatchQueue.main.async {
                            // Update the event in the list
                            if let index = self.arrSpogEvents.firstIndex(where: { $0.id == itemId }) {
                                var updatedEvent = self.arrSpogEvents[index]
                                updatedEvent.isBookmark = (isBookmark == 1)
                                self.arrSpogEvents[index] = updatedEvent
                            }
                            // Update eventDetail if it matches
                            if var eventDetail = self.eventDetail, eventDetail.id == itemId {
                                eventDetail.isBookmark = (isBookmark == 1)
                                self.eventDetail = eventDetail
                            }
                        }
                    } else {
                        DispatchQueue.main.async {
                            appSharedData.showAlertControllerWith(title: projectName, andMessage: response.message ?? "")
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
