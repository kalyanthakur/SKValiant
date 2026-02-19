//
//  DocumentViewModel.swift
//  Valiant
//
//  Created by Kalyan Thakur on 08/02/26.
//

import Foundation

class DocumentViewModel: ObservableObject {
    
    @Published var arrDocuments = [DocumentItem]()
    @Published var showMessageDetailView = false
    @Published var documentDetail: DocumentDetail?


    init() {
        
    }
    
    func getSpogDocuments()  {
        LoadingIndicatorView.show()
        networkManager.executeServiceWithURL(urlString: WEBURL.getSpogDocuments, postParameters: nil) { [weak self] response, error in
            LoadingIndicatorView.hide()
            guard let self = self else { return }
                        
            if error == nil,let result = response {
                do {
                    // Convert dictionary → Data
                    let jsonData = try JSONSerialization.data(withJSONObject: result.dictionaryObject ?? [:], options: [])
                    let response = try JSONDecoder().decode(DocumentsResponse.self, from: jsonData)
                    if response.status == 200 {
                        DispatchQueue.main.async {
                            self.arrDocuments = response.data
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
    
    func getSpogPresidentsMessageDetailsById(documentId:Int)  {
        LoadingIndicatorView.show()
        networkManager.executeServiceWithURL(urlString: WEBURL.spogDocumentDetailsById + "/\(documentId)", postParameters: nil) { [weak self] response, error in
            LoadingIndicatorView.hide()
            guard let self = self else { return }
                        
            if error == nil,let result = response {
                do {
                    // Convert dictionary → Data
                    let jsonData = try JSONSerialization.data(withJSONObject: result.dictionaryObject ?? [:], options: [])
                    let response = try JSONDecoder().decode(DocumentsDetailResponse.self, from: jsonData)
                    if response.status == 200 {
                        DispatchQueue.main.async {
                            self.documentDetail = response.data
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
                            // Update the document in the list
                            if let index = self.arrDocuments.firstIndex(where: { $0.id == itemId }) {
                                var updatedDocument = self.arrDocuments[index]
                                updatedDocument.isBookmark = (isBookmark == 1)
                                self.arrDocuments[index] = updatedDocument
                            }
                            // Update documentDetail if it matches
                            if var documentDetail = self.documentDetail, documentDetail.id == itemId {
                                documentDetail.isBookmark = (isBookmark == 1)
                                self.documentDetail = documentDetail
                            }
                        }
                    } else {
                        DispatchQueue.main.async {
                            appSharedData.showAlertControllerWith(title: projectName, andMessage: response.message ?? "")
                        }
                    }
                } catch {
                    Logger.logDecodingError(error, context: "DocumentViewModel")
                    let errorMessage = appSharedData.getUserFriendlyErrorMessage(from: error, context: "bookmark document")
                    DispatchQueue.main.async {
                        appSharedData.showAlertControllerWith(title: projectName, andMessage: errorMessage)
                    }
                }
            } else {
                let errorMessage = appSharedData.getUserFriendlyErrorMessage(from: error, context: "bookmark document")
                DispatchQueue.main.async {
                    appSharedData.showAlertControllerWith(title: projectName, andMessage: errorMessage)
                }
            }
        }
    }
}
