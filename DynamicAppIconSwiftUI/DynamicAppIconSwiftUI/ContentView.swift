//
//  ContentView.swift
//  DynamicAppIconSwiftUI
//
//  Created by Nitin Bhatia on 17/07/23.
//

import SwiftUI

struct ImagesData: Identifiable, Hashable {
    let imageName : String?
    let id = UUID()
}

struct ContentView: View {
    @State var listOfImages : [ImagesData] = [ImagesData]()
    @State private var selectedItem : UUID?
   
    var body: some View {
       
            List(listOfImages,id: \.id, selection: $selectedItem ,rowContent: {item in
                
                HStack(alignment:.center , spacing:10) {
                    
                    Image(item.imageName?.replacingOccurrences(of: "Icon", with: "Image") ?? "")
                        .resizable()
                        .frame(width: 30,height: 30)
                    
                    Text(item.imageName ?? "")
                        .foregroundColor(Color.black)
                    Spacer()
                    
                    if item.id == selectedItem  {
                        Image(systemName: "checkmark")
                            .foregroundColor(.blue)
                    }
                    
                    
                }
                .contentShape(Rectangle())//this will help to add tap gesture to entire full list row
                
                
                .onTapGesture {
                    selectedItem = item.id
                    let imageName = item.imageName == "AppIcon" ? nil : item.imageName?.replacingOccurrences(of: "Image", with: "Icon")
                    updateAppIcon(imageName)
                }
                .listRowBackground(Color.clear)
                .padding([.top,.bottom], 10)
            })
            .listStyle(.inset)
            .onAppear(){
                listOfImages = getList()
                selectedItem = listOfImages.first(where: {
                    $0.imageName == getCurrentAppIconName()
                })?.id
            }
    }
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

func getList()->[ImagesData] {
    var data : [ImagesData] = [ImagesData]()
    let path = Bundle.main.path(forResource: "Info", ofType: "plist")!
    let dict = NSDictionary(contentsOfFile: path) as! [String:AnyObject]
    let iconDict = (dict["CFBundleIcons"] as! [String:AnyObject])["CFBundleAlternateIcons"] as! [String:AnyObject]
    let keys = iconDict.keys.sorted(by: {$0 < $1})
    
    data.append(ImagesData(imageName: "AppIcon"))
    
    keys.forEach({item in
        let tempData = ImagesData(imageName: item)
        if item != "AppImage" {
            data.append(tempData)
        }
    })
    
    
    
    //as app icon is defualt application's icon and not being displayed fron info.plist, so we are adding it manually
    
    return data
}

func getCurrentAppIconName() -> String {
    
    return UIApplication.shared.alternateIconName ?? "AppIcon"
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
