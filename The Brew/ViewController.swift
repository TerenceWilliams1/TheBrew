//
//  ViewController.swift
//  The Brew
//
//  Created by Terence Williams on 5/24/22.
//

import UIKit
import CloudKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var table: UITableView!
    let control = UIRefreshControl()
    
    private let database = CKContainer(identifier: "iCloud.TheBrew").publicCloudDatabase
    
    //change this
    var items = [Brew]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchItems()
        setupData()
        setupUI()
    }
    
    func setupData() {
        //register cell
        table.dataSource = self
        table.delegate = self
    }
    
    func setupUI() {
        self.title = "The Brew"
        control.addTarget(self, action: #selector(refreshitems), for: .valueChanged)
        table.refreshControl = control
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                            target: self,
                                                            action: #selector(didTapAdd))
    }

    //MARK: - Actions
    @objc func fetchItems() {
        let query = CKQuery(recordType: "BrewItem", predicate: NSPredicate(value: true))
        database.perform(query, inZoneWith: nil) { [weak self] drinks, error in
            guard let drinks = drinks, error == nil else {
                return
            }
            DispatchQueue.main.async {
                
                for drink in drinks {
                    
                    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                    let newBrewItem = BrewItem(context: context)
                    
                    newBrewItem.name = drink.value(forKey: "name") as? String ?? ""
                    newBrewItem.imageData = drink.value(forKey: "imageData") as? Data
                    newBrewItem.type = "coldDrinks"
                    newBrewItem.steps = drink.value(forKey: "steps") as! [String] as NSObject
                    (UIApplication.shared.delegate as! AppDelegate).saveContext()

                    
                    self?.items.append(Brew(name: drink.value(forKey: "name") as? String ?? "",
                                            imageData: drink.value(forKey: "imageData") as? NSData,
                                            type: .coldDrinks,
                                            steps: drink.value(forKey: "steps") as! [String]))
                }
                
                self?.table.reloadData()
            }
        }
    }
    
    @objc func refreshitems() {
        self.control.beginRefreshing()
        let query = CKQuery(recordType: "BrewItem", predicate: NSPredicate(value: true))
        database.perform(query, inZoneWith: nil) { [weak self] records, error in
            guard let records = records, error == nil else {
                return
            }
            DispatchQueue.main.async {
//                self?.items = records.compactMap({$0.value(forKey: "name") as? String})
                self?.table.reloadData()
                self?.control.endRefreshing()
                print(self?.items as Any)
            }
        }
    }
    
    @objc func didTapAdd() {
        saveItem(name: "Test..")
    }
    
    @objc func saveItem(name: String) {
        let steps = ["1", "2", "3"]
        let record = CKRecord(recordType: "BrewItem")
        record.setValue("Blueberry Kiwi", forKey: "name")
        record.setValue("Cold Drinks", forKey: "type")
        record.setValue(steps, forKey: "steps")
    
        guard
            let image = UIImage(named: "me.JPG"),
            var url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first,
            let data = image.jpegData(compressionQuality: 1.0) else { return }
        
        do {
            url = url.appendingPathComponent("me.JPG")
            try data.write(to: url)
            let asset = CKAsset(fileURL: url)
            record["image"] = asset
        } catch let error {
            print(error)
        }

        database.save(record) { [weak self] record, error in
            if record != nil, error == nil {
                print("Saved")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self?.fetchItems()
                }
            }
        }
    }
    
    @objc func deleteItem() {
//        database.delete(withRecordID: CKRecord.ID, completionHandler: <#T##(CKRecord.ID?, Error?) -> Void#>)
    }
    
    //MARK: - Table View
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = items[indexPath.row].name
        return cell
    }

}

