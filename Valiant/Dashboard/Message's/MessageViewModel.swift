//
//  MessageViewModel.swift
//  Valiant
//
//  Created by Kalyan Thakur on 08/02/26.
//

import Foundation

class MessageViewModel: ObservableObject {
    
    @Published var arrPresidentsMessage = [PresidentsMessage]()
    @Published var showMessageDetailView = false
    @Published var messageDetail: PresidentsMessage?


    init() {
        
    }
    
    func getSpogPresidentsMessages()  {
        LoadingIndicatorView.show()
        networkManager.executeServiceWithURL(urlString: WEBURL.getSpogPresidentsMessages, postParameters: nil) { [weak self] response, error in
            LoadingIndicatorView.hide()
            guard let self = self else { return }
                        
            if error == nil,let result = response {
                do {
                    // Convert dictionary → Data
                    let jsonData = try JSONSerialization.data(withJSONObject: result.dictionaryObject ?? [:], options: [])
                    let response = try JSONDecoder().decode(PresidentsMessageResponse.self, from: jsonData)
                    if response.status == 200 {
                        DispatchQueue.main.async {
                            self.arrPresidentsMessage = response.data
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
    
    func getSpogPresidentsMessageDetailsById(messageId:Int)  {
        LoadingIndicatorView.show()
        networkManager.executeServiceWithURL(urlString: WEBURL.spogPresidentsMessageDetailsById + "/\(messageId)", postParameters: nil) { [weak self] response, error in
            LoadingIndicatorView.hide()
            guard let self = self else { return }
                        
            if error == nil,let result = response {
                do {
                    // Convert dictionary → Data
                    let jsonData = try JSONSerialization.data(withJSONObject: result.dictionaryObject ?? [:], options: [])
                    let response = try JSONDecoder().decode(PresidentsMessageDetailResponse.self, from: jsonData)
                    if response.status == 200 {
                        DispatchQueue.main.async {
                            self.messageDetail = response.data
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
                            // Update the message in the list
                            if let index = self.arrPresidentsMessage.firstIndex(where: { $0.id == itemId }) {
                                var updatedMessage = self.arrPresidentsMessage[index]
                                updatedMessage.isBookmark = (isBookmark == 1)
                                self.arrPresidentsMessage[index] = updatedMessage
                            }
                            // Update messageDetail if it matches
                            if var messageDetail = self.messageDetail, messageDetail.id == itemId {
                                messageDetail.isBookmark = (isBookmark == 1)
                                self.messageDetail = messageDetail
                            }
                        }
                    } else {
                        DispatchQueue.main.async {
                            appSharedData.showAlertControllerWith(title: projectName, andMessage: response.message ?? "")
                        }
                    }
                } catch {
                    Logger.logDecodingError(error, context: "MessageViewModel")
                    let errorMessage = appSharedData.getUserFriendlyErrorMessage(from: error, context: "bookmark message")
                    DispatchQueue.main.async {
                        appSharedData.showAlertControllerWith(title: projectName, andMessage: errorMessage)
                    }
                }
            } else {
                let errorMessage = appSharedData.getUserFriendlyErrorMessage(from: error, context: "bookmark message")
                DispatchQueue.main.async {
                    appSharedData.showAlertControllerWith(title: projectName, andMessage: errorMessage)
                }
            }
        }
    }
}
