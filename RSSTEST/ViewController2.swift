//
//  ViewController2.swift
//  RSSTEST
//
//  Created by DaichiSaito on 2018/01/28.
//  Copyright © 2018年 Orfool inc. All rights reserved.
//

import UIKit
import Alamofire
import Kanna
import SafariServices
class ViewController2: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var array = [Feed]()
    
    let apiKey = "AIzaSyCaLccs3OKflVwSJXI4p7KCBtzKhGUAbP0"
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.fetchYoutube()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchYoutube() {
        var title: String!
        var imagePath: String?
        var link: String!
        var createdAt: Date!
        
        let parameters: Parameters = ["key": apiKey, "q": "ゴルフ","part": "snippet", "maxResults":"40","oder":"date"]
        Alamofire.request("https://www.googleapis.com/youtube/v3/search", parameters: parameters).responseJSON { (response) in
            
            if let dict = response.result.value as? NSDictionary {
                print(dict)
                guard let items = dict["items"] as? NSArray else {
                    return
                }
                
                items.forEach({ (item) in
                    guard let convertedItem = item as? NSDictionary else {
                        return
                    }
                    
                    guard let snippet = convertedItem["snippet"] as? NSDictionary else {
                        return
                    }
                    title = snippet["title"] as! String
                    
                    guard let ids = convertedItem["id"] as? NSDictionary else {
                        return
                    }
                    if ids["kind"] as! String == "youtube#channel" {
                        let channelId = ids["channelId"] as! String
                        link = "https://www.youtube.com/channel/" + channelId
                    } else {
                        let videoId = ids["videoId"] as! String
                        link = "https://www.youtube.com/watch?v=" + videoId
                    }
                    
                    
                    guard let thumbnails = snippet["thumbnails"] as? [String: NSDictionary] else {
                        return
                    }
                    
                    imagePath = thumbnails["default"]!["url"] as? String
                    
                    var date = snippet["publishedAt"] as! String
                    let dateFormatter = DateFormatter()
                    // 書式が変わらない固定ロケールで一度値を取得
                    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                    let r_date = dateFormatter.date(from: date)
                    
                    if let d = r_date {
                        // ロケールを日本語にして曜日を取得
                        dateFormatter.locale = Locale(identifier: "ja_JP")
                        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
                        print(dateFormatter.string(from: d))
                        createdAt = dateFormatter.date(from: dateFormatter.string(from: d))
                        //                            tmpEntry.addObject(dateFormatter.stringFromDate(d))
                    }
                    self.array.append(Feed(title: title, imagePath: imagePath, link: link, createdAt: createdAt))
                })
                
            }
            
            
            self.array.sort(by: { (a, b) -> Bool in
                a.createdAt.compare(b.createdAt) == .orderedDescending
            })
            self.tableView.reloadData()
        }
    }

    

}
extension ViewController2: UITableViewDataSource {
    //各セルの要素を設定する
    func tableView(_ table: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = table.dequeueReusableCell(withIdentifier: "YoutubeTableViewCell", for: indexPath) as! YoutubeTableViewCell
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

extension ViewController2: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let url = self.array[indexPath.row].link
        let transformedURL = URL(string: url)
        let safariViewController = SFSafariViewController(url: transformedURL!)
        
        present(safariViewController, animated: true, completion: nil)
    }
}
