# NBUtility


[![Swift version](https://img.shields.io/badge/swift-3.0-orange.svg?style=flat.svg)](https://img.shields.io/badge/swift-3.0-orange.svg?style=flat.svg)
[![Support Dependecy Manager](https://img.shields.io/badge/support-CocoaPods-red.svg?style=flat.svg)](https://img.shields.io/badge/support-CocoaPods-red.svg?style=flat.svg)
[![Version](https://img.shields.io/cocoapods/v/NBUtility.svg?style=flat)](http://cocoapods.org/pods/NBUtility)
[![License](https://img.shields.io/badge/License-MIT-brightgreen.svg?style=flat.svg)](https://img.shields.io/badge/License-MIT-brightgreen.svg?style=flat.svg)
[![Platform](https://img.shields.io/cocoapods/p/NBUtility.svg?style=flat)](http://cocoapods.org/pods/NBUtility)





## Features

* Networking manager for API calls





## Installation


### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```


To integrate NBUtility into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'
use_frameworks!

target '<Your Target Name>' do
pod 'NBUtility'
end
```

Then, run the following command:

```bash
$ pod install
```




## Dependancies

* [Alamofire](https://github.com/Alamofire/Alamofire)
* [AlamofireObjectMapper](https://github.com/tristanhimmelman/AlamofireObjectMapper)
* [QorumLogs](https://github.com/goktugyil/QorumLogs)




## Usage


### Routable.swift 



#### Step 1
* Create a ``` ServiceManager.swift ``` file in your Xcode project




#### Step 2

* Extend the ```swift struct UrlService  ``` to add your end points
* It should look like following example,

```swift 

extension UrlService {
    static let login        = UrlService(rawValue: "user/login")
    static let logout       = UrlService(rawValue: "user/logout")
    static let countryList  = UrlService(rawValue: "user/countryList")
}
```




#### Step 3

* Extend the ```swift struct UrlService  ``` to conform it with ```swift protocol Directable  ```
* It should look like following example,

```swift 

extension UrlService: Directable {

    public func directableURLString() -> String {

        return "<Base URL>" + "/" + "<Tail>" + "/" + self.rawValue
    
        // return "https://abc.com" + "/" + "api" + "/" + self.rawValue
    }
}
```




#### Step 4

* Create a class to manage your API calls ```swift class ServiceManager  ``` and conform it with ```swift protocol Routable  ```
* It should look like following example,

```swift 

class ServiceManager: Routable {



//      You need to implement this method to send App specific headers with your API calls

    func authorizationHeadersIf(_ authorized: Bool) -> [String : String]? {

        //  You can send Open Auth Token, Appversion, API version and many more as per your need
        return ["app-version":"1.0"]
    }



//      You need to implement this method to validate the error of your server and you can take many decisions here with server's error status code


    func handleServerError(_ result: DataResponse<JSONTopModal>, failure: FailureErrorBlock!) -> Bool {

        let resultValue = result.value!

        if resultValue.isError {
            if resultValue.statusCode == -1 {
                //     handleTokenError(resultValue.message)
            }
            else {
                failure(NSError(errorMessage: resultValue.message, code: resultValue.statusCode))
            }

            return true
        }

        return false
    }
}

```


#### Step 5

* In your controllers, you can use the ```swift   ServiceManager  ``` to manage your API calls

* Example for a simple API call is given below,


```swift 

    fileprivate let manager:ServiceManager = ServiceManager()

    manager.request(.get, service: UrlService.countryList, success: { (response, jsonTopModelResult) in
        
        print("proceed with your jsonTopModelResult")
    
    }, failure: { (error) in

        print("Handle error")
    })

```


#### Next Step

* Coming Soon...




## License

NBUtility is available under the MIT license. See the LICENSE file for more info.




## Author

**Fahid Attique** - (https://github.com/fahidattique55)
