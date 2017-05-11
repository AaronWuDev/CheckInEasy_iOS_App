
import Foundation

func postToServer(url: String!, data: AnyObject, handler: ((NSDictionary?) -> Void)? ) {
    let request = NSMutableURLRequest(URL: NSURL(string: url)!)
    let session = NSURLSession.sharedSession()
    request.HTTPMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    do {
        print("isValidJsonObject: \(NSJSONSerialization.isValidJSONObject(data))")
        let jsonObject = try NSJSONSerialization.dataWithJSONObject(data, options: .PrettyPrinted)
        request.HTTPBody = jsonObject
    } catch {
        print("Trasform Json Failed!: \(error)")
    }
    
    let task = session.dataTaskWithRequest(request) { data, response, error in
        if let _ = handler {
            guard data != nil else {
                print("No data found")
                handler?(nil)
                return
            }
            
            do {
                if let json = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary {
                    handler?(json)
                } else {
                    let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding) // No error thrown, but not NSDictionary
                    handler?(nil)
                    print("Error could not parse JSON: \(jsonStr)")
                }
            } catch let parseError {
                handler?(nil)
                print(parseError)
                let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                print("Error could not parse JSON: '\(jsonStr)'")
            }
        }
    }
    
    task.resume()
}


func getFromServer(url: String!, handler: ((NSDictionary?) -> Void)? ) {
    let request = NSMutableURLRequest(URL: NSURL(string: url)!)
    let session = NSURLSession.sharedSession()
    let task = session.dataTaskWithRequest(request) { data, response, error in
        if let _ = handler {
            guard data != nil else {
                print("No data found: \(error)")
                handler!(nil)
                return
            }
            
            do {
                if let json = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary {
                    handler!(json)
                } else {
                    let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding) // No error thrown, but not NSDictionary
                    handler!(nil)
                    print("Error could not parse JSON: \(jsonStr)")
                }
            } catch let parseError {
                handler!(nil)
                print(parseError)
                let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                print("Error could not parse JSON: '\(jsonStr)'")
            }
        }
    }
    task.resume()
    
}


func convertStringToDictionary(text: String) -> [String:AnyObject]? {
    if let data = text.dataUsingEncoding(NSUTF8StringEncoding) {
        do {
            return try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String:AnyObject]
        } catch let error as NSError {
            print(error)
        }
    }
    return nil
}

