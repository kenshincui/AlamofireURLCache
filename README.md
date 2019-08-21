![AlamofireURLCache](https://raw.githubusercontent.com/kenshincui/AlamofireURLCache/master/Resources/AlamofireURLCache_Logo.png)

[![Build Status](https://travis-ci.org/kenshincui/AlamofireURLCache.svg?branch=master)](https://travis-ci.org/KenshinCui/AlamofireURLCache)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Weibo](https://img.shields.io/badge/Weibo-%40KenshinCui-yellow.svg?style=flat)](https://m.weibo.cn/p/1005051869326357)
![](https://img.shields.io/github/license/mashape/apistatus.svg)

Alamofire network library URLCache-based cache extension

- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
    - **[Cache and refresh](#cache-and-refresh)**
    - **[Ignore server-side cache configuration](#ignore-server-side-cache-configuration)**
    - **[Clear cache](#clear-cache)**
- [License](#license)

## Features

- [x] Cache data and refresh
- [x] Ignore server config
- [x] Clear cache


## Installation

### Carthage

To integrate Alamofire into your Xcode project using Carthage, specify it in your Cartfile:

#### Swift 4 or Swift 5 (Alamofire version is 4.x)

```
github "kenshincui/AlamofireURLCache"
```

#### Swift 3 (Alamofire version is 3.x)

```
github "kenshincui/AlamofireURLCache" == 0.1
```

Run carthage update to build the framework and drag the built AlamofireURLCache.framework into your Xcode project.

### Manually

If you prefer not to use any of the aforementioned dependency managers, you can integrate AlamofireURLCache into your project manually(Only need to copy AlamofireURLCache.swift to you project).

## Usage

### Cache and refresh

You can use the *cache()* method to save cache for this request, and set the request with the *refreshCache* parameter to re-initiate the request to refresh the cache data.

* Simply cache data

```swift
Alamofire.request("https://myapi.applinzi.com/url-cache/no-cache.php").responseJSON(completionHandler: { response in
    if response.value != nil {
        self.textView.text = (response.value as! [String:Any]).debugDescription
    } else {
        self.textView.text = "Error!"
    }
    
}).cache(maxAge: 10)
```

* Refresh cache

```swift
Alamofire.request("https://myapi.applinzi.com/url-cache/no-cache.php",refreshCache:true).responseJSON(completionHandler: { response in
    if response.value != nil {
        self.textView.text = (response.value as! [String:Any]).debugDescription
    } else {
        self.textView.text = "Error!"
    }
    
}).cache(maxAge: 10)
```

### Ignore server-side cache configuration

By default, if the server is configured with cache headers, the server-side configuration is used, but you can use the custom cache age and ignore this configuration by setting the *ignoreServer* parameter。

```swift
Alamofire.request("https://myapi.applinzi.com/url-cache/default-cache.php",refreshCache:false).responseJSON(completionHandler: { response in
    if response.value != nil {
        self.textView.text = (response.value as! [String:Any]).debugDescription
    } else {
        self.textView.text = "Error!"
    }
    
}).cache(maxAge: 10,isPrivate: false,ignoreServer: true)
```

### Clear cache

Sometimes you need to clean the cache manually rather than refresh the cache data, then you can use AlamofireURLCache cache cache API. But for network requests error, serialization error, etc. we recommend the use of *autoClearCache* parameters Automatically ignores the wrong cache data.

```swift
Alamofire.clearCache(dataRequest: dataRequest) // clear cache by DataRequest
Alamofire.clearCache(request: urlRequest) // clear cache by URLRequest

// ignore data cache when request error
Alamofire.request("https://myapi.applinzi.com/url-cache/no-cache.php",refreshCache:false).responseJSON(completionHandler: { response in
    if response.value != nil {
        self.textView.text = (response.value as! [String:Any]).debugDescription
    } else {
        self.textView.text = "Error!"
    }
    
},autoClearCache:true).cache(maxAge: 10)
```

> When using AlamofireURLCache, we recommend that you add the *autoClearCache* parameter in any case.

## License

AlamofireURLCache is released under the MIT license. [See LICENSE](https://raw.githubusercontent.com/kenshincui/AlamofireURLCache/master/LICENSE) for details.

