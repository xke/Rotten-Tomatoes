//
//  MovieDetailsViewController.swift
//  Rotten Tomatoes
//
//  Created by Xian on 9/16/15.
//  Copyright © 2015 swifterlabs. All rights reserved.
//

import UIKit

class MovieDetailsViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var synopsisLabel: UILabel!
    
    var movie: NSDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        KVNProgress.dismiss()
        

        titleLabel.text = movie["title"] as? String
        synopsisLabel.text = movie["synopsis"] as? String
        self.title = titleLabel.text


        var urlString = movie.valueForKeyPath("posters.thumbnail") as! String
        if let range = urlString.rangeOfString(".*cloudfront.net/", options: .RegularExpressionSearch) {
            urlString = urlString.stringByReplacingCharactersInRange(range, withString: "https://content6.flixster.com/")
        }
        
        imageView.setImageWithURL(NSURL(string: urlString)!)

        
        
    }
    
    
    
}
