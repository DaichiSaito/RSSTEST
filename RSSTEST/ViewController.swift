//
//  ViewController.swift
//  RSSTEST
//
//  Created by DaichiSaito on 2017/12/17.
//  Copyright © 2017年 Orfool inc. All rights reserved.
//

import UIKit
import Alamofire
class ViewController: UIViewController, XMLParserDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        fetchRSS()
        
//        loadXML()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func fetchRSS() {
        let parameters: Parameters = ["q": "select * from rss where url = 'http://soccerlture.com/feed/'", "format": "json"]
        Alamofire.request("https://query.yahooapis.com/v1/public/yql", parameters: parameters).responseJSON { response in
            print("Request: \(String(describing: response.request))")   // original url request
            print("Response: \(String(describing: response.response))") // http url response
            print("Result: \(response.result)")                         // response serialization result
//            print(response.result.value)
            if let json = response.result.value {
//                print("JSON: \(json)") // serialized json response
                
//                print(json["query"])
//                print(json["query"]["results"]["item"])
//                let data = json.data(using: .utf8)!
//                let data = json
//                do {
//                    let dic = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] // ["fuga": "aiueo", "user": ["name": "tenten0213", "age": 30], "foo": 999]
//                    dic?["fuga"] // "aiueo"
//                    let user = dic?["user"] as? [String: Any] // ["name": "tenten0213", "age": 30]
//                    user?["name"] as? String // "tenten0213"
//                    user?["age"] as? Int // 30
//                } catch {
//                    print(error.localizedDescription)
//                }
                
                
            }
//
            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
//                print("Data: \(utf8Text)") // original server data as UTF8 string
//                let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary
//                let json = try! JSONSerialization.jsonObject(with: data, options:[])
//                print(json["query"] ?? "だめだ")
            }
            
            if let dict = response.result.value as? NSDictionary {
//                print(dict)
//                print(dict["query"])
                guard let query = dict["query"] as? NSDictionary else {
                    return
                }
                
                guard let results = query["results"] as? NSDictionary else {
                    return
                }
                
                guard let items = results["item"] as? NSArray else {
                    return
                }
                items.forEach {
                    print(($0 as! NSDictionary)["title"] as! String)
                }
            }
        }
    }
    
    func loadXML() {
        
        let url_text = "http://soccerlture.com/feed/"
        
        guard let url = URL(string: url_text) else{
            return
        }
        // インターネット上のXMLを取得し、NSXMLParserに読み込む
        guard let parser = XMLParser(contentsOf: url) else{
            return
        }
        parser.delegate = self;
        parser.parse()
    }
    
    // XML解析開始時に実行されるメソッド
    func parserDidStartDocument(_ parser: XMLParser) {
        print("XML解析開始しました")
    }
    
    // 解析中に要素の開始タグがあったときに実行されるメソッド
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        print("開始タグ:" + elementName)
    }
    
    // 開始タグと終了タグでくくられたデータがあったときに実行されるメソッド
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        print("要素:" + string)
    }
    
    // 解析中に要素の終了タグがあったときに実行されるメソッド
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        print("終了タグ:" + elementName)
    }
    
    // XML解析終了時に実行されるメソッド
    func parserDidEndDocument(_ parser: XMLParser) {
        print("XML解析終了しました")
    }
    
    // 解析中にエラーが発生した時に実行されるメソッド
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print("エラー:" + parseError.localizedDescription)
    }
}

