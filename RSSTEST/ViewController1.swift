//
//  ViewController1.swift
//  RSSTEST
//
//  Created by DaichiSaito on 2018/01/27.
//  Copyright © 2018年 Orfool inc. All rights reserved.
//

import UIKit
import Alamofire
import SafariServices
import Kanna
class ViewController1: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var array = [Feed]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.estimatedRowHeight = 1000
        self.tableView.rowHeight = UITableViewAutomaticDimension

        fetchRSS(url: "http://golf1000.blog23.fc2.com/?xml")
        fetchRSS(url: "http://www.analyze2005.com/mkblogneo/?feed=rss2")
        fetchRSS(url: "http://blog.secret-golf.com/index.rdf")
        fetchRSS(url: "http://rssblog.ameba.jp/crenshaw2/rss20.xml")
        fetchRSS(url: "http://rssblog.ameba.jp/50shoulder/rss20.xml")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func fetchRSS(url: String) {
        let parameters: Parameters = ["q": "select * from rss where url = '"+url+"'", "format": "json"]
        Alamofire.request("https://query.yahooapis.com/v1/public/yql", parameters: parameters).responseJSON { response in
//            print("Request: \(String(describing: response.request))")   // original url request
//            print("Response: \(String(describing: response.response))") // http url response
//            print("Result: \(response.result)")                         // response serialization result
            
            var title: String!
            var imagePath: String?
            var link: String!
            var createdAt: Date!
            if let dict = response.result.value as? NSDictionary {
                
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
                    title = ($0 as! NSDictionary)["title"] as! String
                    link = ($0 as! NSDictionary)["link"] as! String
//                    var date = ($0 as! NSDictionary)["db:date"] as? Date
//                    var creater = ($0 as! NSDictionary)["db:publisher"] as? String
//                    print(($0 as! NSDictionary))
                    
                    if let date = ($0 as! NSDictionary)["pubDate"] as? String {
//                        print(date)
                        let dateFormatter = DateFormatter()
                        // 書式が変わらない固定ロケールで一度値を取得
                        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                        dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss ZZZZ"
                        let r_date = dateFormatter.date(from: date)
                        
                        if let d = r_date {
                            // ロケールを日本語にして曜日を取得
                            dateFormatter.locale = Locale(identifier: "ja_JP")
                            dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
//                            print(dateFormatter.string(from: d))
//                            createdAt = dateFormatter.string(from: d)
                            createdAt = dateFormatter.date(from: dateFormatter.string(from: d))
//                            tmpEntry.addObject(dateFormatter.stringFromDate(d))
                        }
                        
                    } else if let date = ($0 as! NSDictionary)["date"] as? String {
//                        print(date)
                        let dateFormatter = DateFormatter()
                        // 書式が変わらない固定ロケールで一度値を取得
                        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
                        let r_date = dateFormatter.date(from: date)
                        
                        if let d = r_date {
                            // ロケールを日本語にして曜日を取得
                            dateFormatter.locale = Locale(identifier: "ja_JP")
                            dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
                            print(dateFormatter.string(from: d))
                            createdAt = dateFormatter.date(from: dateFormatter.string(from: d))
                            //                            tmpEntry.addObject(dateFormatter.stringFromDate(d))
                        }
//                        let outputFormatter = DateFormatter()
//                        outputFormatter.dateFormat = "yyy/MM/dd HH:mm"
//                        let outputDateString = outputFormatter.stringFromDate(date)
                    }
                    if let content = (($0 as! NSDictionary)["encoded"] as? String) {
                        imagePath = self.getImagePath(xml: "<myTag>"+content+"</myTag>")
                    } else if let content = (($0 as! NSDictionary)["description"] as? String) {
                        imagePath = self.getImagePath(xml: "<myTag>"+content+"</myTag>")
                    }
                    
                    
                    self.array.append(Feed(title: title, imagePath: imagePath, link: link, createdAt: createdAt))
                }
                
//                self.array = items
                self.array.sort(by: { (a, b) -> Bool in
                    a.createdAt.compare(b.createdAt) == .orderedDescending
                })
                self.tableView.reloadData()
            }
        }
    }

}

extension ViewController1: UITableViewDataSource {
    //各セルの要素を設定する
    func tableView(_ table: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = table.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TableViewCell
        cell.setCell(feed: array[indexPath.row])
        // Tag番号 ２ で UILabel インスタンスの生成
//        let label = cell.viewWithTag(1) as! UILabel
//        let title = (self.array[indexPath.row] as! NSDictionary)["title"] as! String
//        label.text = String(describing: title)
//        cell.titleLabel.text = title
        return cell
    }
    
    // Section数
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Table Viewのセルの数を指定
    func tableView(_ table: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.array.count
    }
    
    func getImagePath(xml: String) -> String? {
        if let doc: XMLDocument = try! Kanna.XML(xml: xml, encoding: .utf8) {
            let node = doc.css("img[src]").first
            return node?["src"]
        }
    }
}

extension ViewController1: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let url = self.array[indexPath.row].link
        let transformedURL = URL(string: url)
        let safariViewController = SFSafariViewController(url: transformedURL!)
        
        present(safariViewController, animated: true, completion: nil)
    }
}

struct Feed {
    var title: String
    var link: String
    var imagePath: String?
    var createdAt: Date!
    
    init(title: String, imagePath: String? = nil, link: String, createdAt: Date) {
        self.title = title
        self.imagePath = imagePath
        self.link = link
        self.createdAt = createdAt
    }
}
