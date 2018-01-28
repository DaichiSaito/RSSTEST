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
    
    var array = [Any]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self

        fetchRSS(url: "http://golf1000.blog23.fc2.com/?xml")
//        fetchRSS(url: "http://www.analyze2005.com/mkblogneo/?feed=rss2")
//        fetchRSS(url: "http://blog.secret-golf.com/index.rdf")
//        fetchRSS(url: "http://rssblog.ameba.jp/crenshaw2/rss20.xml")
//        fetchRSS(url: "http://rssblog.ameba.jp/50shoulder/rss20.xml")
        
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
//                    print(($0 as! NSDictionary)["title"] as! String)
                    print(($0 as! NSDictionary)["encoded"])
                    let xml = "<myTag>" + (($0 as! NSDictionary)["encoded"] as! String) + "</myTag>"
                    if let doc: XMLDocument = try! Kanna.XML(xml: xml, encoding: .utf8) {
                        
//                        doc.xpath("//*/img[1]div[@id='content']/div[@id='bodyContent']/div[@id='mw-content-text']")
                        let node = doc.css("img[src]").first
                        print(node?["src"])
                    }
                    self.array.append($0)
                }
                
//                self.array = items
                self.tableView.reloadData()
            }
        }
    }

}

extension ViewController1: UITableViewDataSource {
    //各セルの要素を設定する
    func tableView(_ table: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = table.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TableViewCell
        // Tag番号 ２ で UILabel インスタンスの生成
//        let label = cell.viewWithTag(1) as! UILabel
        let title = (self.array[indexPath.row] as! NSDictionary)["title"] as! String
//        label.text = String(describing: title)
        cell.titleLabel.text = title
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
}

extension ViewController1: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let url = (self.array[indexPath.row] as! NSDictionary)["link"] as! String
        let transformedURL = URL(string: url)
        let safariViewController = SFSafariViewController(url: transformedURL!)
        
        present(safariViewController, animated: true, completion: nil)
    }
}

struct Feed {
    var title: String
    var imagePath: String?
    
    init(title: String, imagePath: String? = nil) {
        self.title = title
        self.imagePath = imagePath
    }
}
