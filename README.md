![Alt text](http://i.imgur.com/xE7UfDS.png "NBUtility-Image")

[![Swift version](https://img.shields.io/badge/swift-3.0-orange.svg?style=flat.svg)](https://img.shields.io/badge/swift-3.0-orange.svg?style=flat.svg)
[![Support Dependecy Manager](https://img.shields.io/badge/support-CocoaPods-red.svg?style=flat.svg)](https://img.shields.io/badge/support-CocoaPods-red.svg?style=flat.svg)
[![Version](https://img.shields.io/cocoapods/v/NBUtility.svg?style=flat)](http://cocoapods.org/pods/NBUtility)
[![License](https://img.shields.io/badge/License-MIT-brightgreen.svg?style=flat.svg)](https://img.shields.io/badge/License-MIT-brightgreen.svg?style=flat.svg)
[![Platform](https://img.shields.io/cocoapods/p/NBUtility.svg?style=flat)](http://cocoapods.org/pods/NBUtility)





## Features


### Routable.swift Features

*  It supports all HTTP request methods i.e GET, POST, PUT and DELETE
*  It supports multipart requests for uploading data to your server
*  It provides three methods for calling an HTTP request methods,
    *  request 
        *  You will get JSONTopModel as response of this method. You can parse it as per your need 
    *  requestForObject 
        *  You will get the auto-mapped object as response of this method. You just need to send the mapperClass in request parameter
    *  requestForArray 
        *  You will get the auto-mapped array of objects as response of this method. You just need to send the mapperClass in request parameter
*  It provides three same methods for multipart API calls
*  It allows you to make your API call authorized with only one Boolean parameter "authorized"  
*  It gives you the flexibility for server error handling 
*  It will handle the serialization errors of responses for all API calls by its own


#### Special Features

*  Protocol Oriented Networking manager
*  Provides you the shared implementation of all HTTP and multipart request method
*  Allows you to provide the custom implementation of any request method defined in the Routable protocol
*  Highly structured with Abstraction and Namespacing techniques



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


### ``` Routable.swift ```

* It is a protocol oriented network manager which has the following features
* All network calls will parse its responses with JSONTopModel as base class. You can find its implementation in ``` Routable.swift ```

#### Step 1
* Create a ``` ServiceManager.swift ``` file in your Xcode project




#### Step 2


* Create an ``` enum Endpoint ``` to add app specific end points. Conform it with Directable to make directable urls from your end points.
* It should look like following example,

```swift 

enum Endpoint: Directable {

    
    //      Setup the base Url of your application according to the application mode

    static var baseUrl: String {

        var baseUrl = ""

        switch appMode {
        
            case .test:
                baseUrl = "http://apidev.accuweather.com/currentconditions"
            case .production:
                baseUrl = "http://apidev.accuweather.com/currentconditions"
        }

        return baseUrl
    }




    //      Define some endpoints like this,

    case weatherConditions,
    countryList





    //      Implement the protocol method to make your app specific end points fully directable as Url
    
    func directableURLString() -> String {

        var servicePath = ""

        switch (self) {

            case .weatherConditions:
            servicePath = "get-weather-conditions"

            case .countryList:
            servicePath = "get-countries-data"
        }

        let tail = "api"
        return Endpoint.baseUrl + "/" + tail + "/" + servicePath
    }
}

```




#### Step 3

* Create a class to manage your API calls ``` class ServiceManager  ``` and conform it with ``` protocol Routable  ```
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

* In your controllers, you can use the ```  ServiceManager  ``` to manage your network calls

* Example for a simple API call is given below,


```swift 

    fileprivate let manager:ServiceManager = ServiceManager()

    manager.request(.get, service: Endpoint.countryList, success: { (response, jsonTopModelResult) in
        
        print("proceed with your jsonTopModelResult")
    
    }, failure: { (error) in

        print("Handle error")
    })

```


* Add "authorized" Boolean perameter in the same API call to add authorized headers


```swift 

    manager.request(.get, service: Endpoint.countryList, authorized: true, success: { (response, jsonTopModelResult) in

        print("proceed with your jsonTopModelResult")

    }, failure: { (error) in

        print("Handle error")
    })

```



#### Advance Usage

* Get the Countries list (Array of custom objects) auto-mapped with the help of Routable protocol


```swift 

    manager.requestForArray(.get, service: Endpoint.countryList, mapperClass: Country.self, success: { (response, countries) in

        print("proceed with your countries list")
    
    }, failure: { (error) in

        print("Handle error")
    })

```


* Get the Weather Conditions (Custom object) auto-mapped with the help of Routable protocol


```swift 

    manager.requestForObject(.get, service: Endpoint.weatherConditions, mapperClass: WeatherCondition.self, success: { (response, weatherConditions) in

        print("proceed with your weather Conditions")

    }, failure: { (error) in

        print("Handle error")
    })

```


* Same API calls can be user as multipart request for uploading data to your server. Use the multipart request methods of Routable protocol.


## License

NBUtility is available under the MIT license. See the LICENSE file for more info.




## Author

**Fahid Attique** - (https://github.com/fahidattique55)
