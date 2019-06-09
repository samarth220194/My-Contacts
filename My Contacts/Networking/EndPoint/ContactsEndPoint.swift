//
//  MovieEndPoint.swift
//  NetworkLayer
//
//  Created by Samarth Kejriwal on 08/06/19.
//  Copyright © 2019 Samarth Kejriwal. All rights reserved.
//

import Foundation


enum NetworkEnvironment {
    case qa
    case production
    case staging
}

public enum ContactsApi {
    case listContact
    case detailContact(id:Int)
    case createContact(body : [String : Any])
    case updateContact(id:Int,body : [String : Any])
}

extension ContactsApi: EndPointType {
    
    var environmentBaseURL : String {
        switch NetworkManager.environment {
        case .production: return "http://gojek-contacts-app.herokuapp.com/"
        case .qa: return "http://gojek-contacts-app.herokuapp.com/"
        case .staging: return "http://gojek-contacts-app.herokuapp.com/"
        }
    }
    
    var baseURL: URL {
        guard let url = URL(string: environmentBaseURL) else { fatalError("baseURL could not be configured.")}
        return url
    }
    
    var path: String {
        switch self {
        case .listContact:
            return "contacts.json"
        case .createContact( _) :
            return "contacts.json"
        case .detailContact(let id):
            return "contacts/\(id).json"
        case .updateContact(let id, _) :
            return "contacts/\(id).json"
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .listContact:
            return .get
        case .detailContact( _):
            return .get
        case .createContact:
            return .post
        case .updateContact( _):
            return .put
        }
    }
    
    var task: HTTPTask {
        switch self {
        case .listContact:
            return .requestParameters(bodyParameters: nil,
                                      bodyEncoding: .urlEncoding,
                                      urlParameters: [:])
        case .detailContact( _) :
            return .requestParameters(bodyParameters: nil,
                                      bodyEncoding: .urlEncoding,
                                      urlParameters: [:])
        case .createContact(let body) :
            return .requestParameters(bodyParameters: body,
                                      bodyEncoding: .jsonEncoding,
                                      urlParameters: [:])
        case .updateContact( _,let body) :
            return .requestParameters(bodyParameters: body,
                                      bodyEncoding: .jsonEncoding,
                                      urlParameters: [:])
        }
    }
    
    var headers: HTTPHeaders? {
        return nil
    }
}


