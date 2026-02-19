//
//  AdditionalInfoViewModel.swift
//  Valiant
//
//  Created by Kalyan Thakur on 10/02/26.
//


import Foundation

class AdditionalInfoViewModel: ObservableObject {
    
    @Published var arrSholarships = [Scholarship]()
    @Published var scholarship: Scholarship?
    @Published var votePDF: VotePDF?
    
    init() {
        
    }
    
    func getSaucierScholarshipPosts()  {
        LoadingIndicatorView.show()
        networkManager.executeServiceWithURL(urlString: WEBURL.saucierScholarshipPosts, postParameters: nil) { [weak self] response, error in
            LoadingIndicatorView.hide()
            guard let self = self else { return }
                        
            if error == nil,let result = response {
                do {
                    // Convert dictionary → Data
                    let jsonData = try JSONSerialization.data(withJSONObject: result.dictionaryObject ?? [:], options: [])
                    let response = try JSONDecoder().decode(ScholarshipResponse.self, from: jsonData)
                    if response.status == 200 {
                        DispatchQueue.main.async {
                            self.arrSholarships = response.data
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
    
    func getSaucierScholarshipPostsDetailsById(scholarshipId:Int)  {
        LoadingIndicatorView.show()
        networkManager.executeServiceWithURL(urlString: WEBURL.saucierScholarshipPosts + "/\(scholarshipId)", postParameters: nil) { [weak self] response, error in
            LoadingIndicatorView.hide()
            guard let self = self else { return }
                        
            if error == nil,let result = response {
                do {
                    // Convert dictionary → Data
                    let jsonData = try JSONSerialization.data(withJSONObject: result.dictionaryObject ?? [:], options: [])
                    let response = try JSONDecoder().decode(ScholarshipDetailResponse.self, from: jsonData)
                    if response.status == 200 {
                        DispatchQueue.main.async {
                            self.scholarship = response.data
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
    
    func getVotePost()  {
        LoadingIndicatorView.show()
        networkManager.executeServiceWithURL(urlString: WEBURL.votePost, postParameters: nil) { [weak self] response, error in
            LoadingIndicatorView.hide()
            guard let self = self else { return }
                        
            if error == nil,let result = response {
                do {
                    // Convert dictionary → Data
                    let jsonData = try JSONSerialization.data(withJSONObject: result.dictionaryObject ?? [:], options: [])
                    let response = try JSONDecoder().decode(VotePDFResponse.self, from: jsonData)
                    if response.status == 200 {
                        DispatchQueue.main.async {
                            self.votePDF = response.data
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
