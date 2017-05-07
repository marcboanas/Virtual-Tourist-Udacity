//
//  FlickrClient.swift
//  Virtual Tourist - Final
//
//  Created by Marc Boanas on 05/05/2017.
//  Copyright © 2017 Marc Boanas. All rights reserved.
//

import Foundation

class FlickrClient: NSObject {
    
    // Shared session
    var session = URLSession.shared
    
    // MARK: Initializers
    
    override init() {
        super.init()
    }
    
    // MARK: GET
    
    func taskForGetMethod(_ method: String, parameters: [String: AnyObject], completionHandlerForGetMethod: @escaping (_ result: [String: AnyObject]?, _ errorString: String?) -> Void) -> URLSessionDataTask {
        
        // 1. Build the URL
        var mathodParameters = parameters
        
        mathodParameters[Constants.FlickrParameterKeys.Method] = Constants.FlickrParameterValues.SearchMethod as AnyObject?
        mathodParameters[Constants.FlickrParameterKeys.APIKey] = Constants.FlickrParameterValues.APIKey as AnyObject?
        mathodParameters[Constants.FlickrParameterKeys.SafeSearch] = Constants.FlickrParameterValues.UseSafeSearch as AnyObject?
        mathodParameters[Constants.FlickrParameterKeys.Extras] = Constants.FlickrParameterValues.MediumURL as AnyObject?
        mathodParameters[Constants.FlickrParameterKeys.Format] = Constants.FlickrParameterValues.ResponseFormat as AnyObject?
        mathodParameters[Constants.FlickrParameterKeys.NoJSONCallback] = Constants.FlickrParameterValues.DisableJSONCallback as AnyObject?
        
        let url: URL = flickrURLFromParameters(mathodParameters)
        
        // 2. Configure the request
        let request = URLRequest(url: url)
        
        // Create the network request
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            // GUARD: Was there an error?
            guard error == nil else {
                let errorString = "\(error!)"
                return completionHandlerForGetMethod(nil, errorString)
            }
            
            // GUARD: Did we get a successful 2XX response?
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                let errorString = "Your request returned an unsuccessful status code"
                return completionHandlerForGetMethod(nil, errorString)
            }
            
            // GUARD: Was there any data returned?
            guard let data = data else {
                let errorString = "No data returned!"
                return completionHandlerForGetMethod(nil, errorString)
            }
            
            // Parse the data
            let parsedData: [String: AnyObject]!
            do {
                parsedData = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: AnyObject]
            } catch {
                let errorString = "Could not parse the data as JSON: '\(data)'"
                return completionHandlerForGetMethod(nil, errorString)
            }
            
            // GUARD: Did Flickr return an error (stat != ok)?
            guard let stat = parsedData[Constants.FlickrResponseKeys.Status] as? String, stat == Constants.FlickrResponseValues.OKStatus else {
                let errorString = "Flickr API returned an error. See error code and message in: \(parsedData)"
                return completionHandlerForGetMethod(nil, errorString)
            }
            
            return completionHandlerForGetMethod(parsedData, nil)
        }
        
        task.resume()
        
        return task
    }
    
    // Create URL from parameters
    private func flickrURLFromParameters(_ parameters: [String: AnyObject], withPathExtension: String? = nil) -> URL {
        
        var components = URLComponents()
        components.scheme = Constants.Flickr.ApiScheme
        components.host = Constants.Flickr.ApiHost
        components.path = Constants.Flickr.ApiPath + (withPathExtension ?? "")
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
    
    // MARK: Shared Instance
    
    class func sharedInstace() -> FlickrClient {
        struct Singleton {
            static var sharedInstance = FlickrClient()
        }
        return Singleton.sharedInstance
    }
}

