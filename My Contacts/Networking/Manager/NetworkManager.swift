//
//  NetworkManager.swift
//  NetworkLayer
//
//  Created by Samarth Kejriwal on 08/06/19.
//  Copyright © 2019 Samarth Kejriwal. All rights reserved.
//

import Foundation


enum NetworkResponse:String {
    case success
    case authenticationError = "You need to be authenticated first."
    case badRequest = "Bad request"
    case outdated = "The url you requested is outdated."
    case failed = "Network request failed."
    case noData = "Response returned with no data to decode."
    case unableToDecode = "We could not decode the response."
}

enum Result<String>{
    case success
    case failure(String)
}

struct NetworkManager {
    static let environment : NetworkEnvironment = .production
    let router = Router<ContactsApi>()
    

    func getContacts(completion: @escaping (_ data: Data?,_ error: String?)->()){
        router.request(.listContact) { data, response, error in
            let response = self.handleData(data, response, error)
            completion(response.0,response.1)
        }
    }
    
    func getContactDetails(id : Int,completion: @escaping (_ data: Data?,_ error: String?)->()){
        router.request(.detailContact(id: id)) { data, response, error in
            let response = self.handleData(data, response, error)
            completion(response.0,response.1)
        }
    }
    
    func createContact(body : [String : Any],completion: @escaping (_ data: Data?,_ error: String?)->()) {
        router.request(.createContact(body: body)) { data, response, error in
            let response = self.handleData(data, response, error)
            completion(response.0,response.1)
        }
    }
    func updateContact(body : [String : Any],id : Int,completion: @escaping (_ data: Data?,_ error: String?)->()) {
        router.request(.updateContact(id: id, body: body)) { data, response, error in
            let response = self.handleData(data, response, error)
            completion(response.0,response.1)
        }
    }
    
    func handleData(_ data: Data?,_ response: URLResponse?,_ error: Error?) -> (Data?, String?)
    {
        if error != nil {
            return (nil,"Please check your network connection.")
        }
        if let response = response as? HTTPURLResponse {
            let result = self.handleNetworkResponse(response)
            switch result {
            case .success:
                guard let responseData = data else {
                    return (nil,NetworkResponse.noData.rawValue)
                }
                return (responseData,nil)
            case .failure(let networkFailureError):
                return (nil,networkFailureError)
            }
        }
        return (nil,nil)
    }
    
    
    
    fileprivate func handleNetworkResponse(_ response: HTTPURLResponse) -> Result<String>{
        switch response.statusCode {
        case 200...299: return .success
        case 401...500: return .failure(NetworkResponse.authenticationError.rawValue)
        case 501...599: return .failure(NetworkResponse.badRequest.rawValue)
        case 600: return .failure(NetworkResponse.outdated.rawValue)
        default: return .failure(NetworkResponse.failed.rawValue)
        }
    }
}
