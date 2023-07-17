//
//  ViewController.swift
//  DynamicAppIconDemo
//
//  Created by Nitin Bhatia on 14/07/23.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //outlet
    @IBOutlet weak var tblData: UITableView!
    
    //variables
    var data : [String] = [String]()
    var currentlySelectedIndexPath: IndexPath = IndexPath()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        let path = Bundle.main.path(forResource: "Info", ofType: "plist")!
        let dict = NSDictionary(contentsOfFile: path) as! [String:AnyObject]
        let iconDict = (dict["CFBundleIcons"] as! [String:AnyObject])["CFBundleAlternateIcons"] as! [String:AnyObject]
        print(iconDict.keys)
        data.append(contentsOf: iconDict.keys)
        data.sort(by: {$0 < $1})
        
        //as app icon is defualt application's icon and not being displayed fron info.plist, so we are adding it manually
        data.insert("AppIcon", at: 0)

    }
    
    //MARK: this code will change the app icon with showing alert
    func updateAppIcon(_ iconName: String?) {
        // updateAppIconWithoutAlert(iconName)
        if UIApplication.shared.supportsAlternateIcons {
            
            UIApplication.shared.setAlternateIconName(iconName) { error in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    print("Success!")
                }
            }
        }
    }
    
    //MARK: this code will change the app icon without showing alert
    //This is little bit risky because if Apple change it’s native method name, app will start crashing, so use at your own risk
    func updateAppIconWithoutAlert(_ iconName: String ) {
        if UIApplication.shared.responds(to: #selector(getter: UIApplication.supportsAlternateIcons)) && UIApplication.shared.supportsAlternateIcons {
            typealias setAlternateIconName = @convention(c) (NSObject, Selector, NSString, @escaping (NSError) -> ()) -> ()
            let selectorString = "_setAlternateIconName:completionHandler:"
            let selector = NSSelectorFromString(selectorString)
            let imp = UIApplication.shared.method(for: selector)
            let method = unsafeBitCast(imp, to: setAlternateIconName.self)
            method(UIApplication.shared, selector, iconName  as NSString, { _ in })
        }
    }
    
    func getCurrentAppIconName() -> String {
        return UIApplication.shared.alternateIconName ?? "AppIcon"
    }
    
    
    //MARK: - Table view functions
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        var defualtConfig = cell.defaultContentConfiguration()
        
        let imageName = data[indexPath.row].replacingOccurrences(of: "Icon", with: "Image")
        
        //it displays only png image but in app icon Jpeg image can also work but as png image is light weighted to prefer to use png image only
        defualtConfig.image = UIImage(named: imageName)
        
//        if data[indexPath.row].contains("AppIcon") {
//            defualtConfig.image = UIImage(named: "AppImage")
//        }
        
        defualtConfig.text = data[indexPath.row].components(separatedBy: "_").last ?? ""
        
        cell.contentConfiguration = defualtConfig
        
        
        if data[indexPath.row] == getCurrentAppIconName() {
            cell.accessoryType = .checkmark
            currentlySelectedIndexPath = indexPath
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if data[indexPath.row].contains("AppIcon") {
            updateAppIcon(nil)
        } else {
            updateAppIcon(data[indexPath.row].replacingOccurrences(of: "Image", with: "Icon"))
        }
        //tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        tblData.reloadRows(at: [indexPath,currentlySelectedIndexPath], with: .fade)
        currentlySelectedIndexPath = indexPath
    }
    
//    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
//        tableView.cellForRow(at: indexPath)?.accessoryType = .none
//    }
//
    
}

