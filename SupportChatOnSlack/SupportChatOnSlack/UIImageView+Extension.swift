//
//  UIImageView+Extension.swift
//  Messenger
//
//  Created by Knedle on 01/08/2016.
//

import UIKit

class UIImageView_Extension {
    
}

extension UIImageView {
    
    func downloadedFrom(link: String, contentMode mode: UIViewContentMode = UIViewContentMode.scaleAspectFit) {
        guard let url = NSURL(string: link) else { return }
        contentMode = mode
        URLSession.shared.dataTask(with: url as URL) { (data, response, error) in
            guard
                let httpURLResponse = response as? HTTPURLResponse , httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType , mimeType.hasPrefix("image"),
                let data = data , error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async {
                self.image = image
            }
            }.resume()
    }
    
}
