//
//  ViewController.swift
//  dictionary
//
//  Created by Handika Limanto on 14/02/21.
//

import UIKit
import CoreData

class SearchVC: UIViewController {

    @IBOutlet weak var searchTable: UITableView!
    @IBOutlet weak var searchET: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var notFoundTV: UILabel!
    let searchTexts = ["Owl", "Bear", "Dog", "Cat", "Penguin", "Persimmon", "Peach", "Row", "Water", "Friend"]
    var word: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Refresh", style: .plain, target: self, action: #selector(refreshButtonPressed))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Favorites", style: .plain, target: self, action: #selector(favoritesButtonPressed))
        
        searchTable.allowsSelection = false
        searchTable.delegate = self
        searchTable.dataSource = self
        refreshButtonPressed(self)
    }
    
    func reloadTableView(){
        searchTable.reloadData()
    }
    func presentAlert(_ title: String, _ message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let close = UIAlertAction(title: "Close", style: .cancel, handler: nil)
        alert.addAction(close)
        
        present(alert, animated: true, completion: nil)
    }
    func toggleVisibility(_ resultFound: Bool){
        Manager.definitions.removeAll()
        reloadTableView()
        if resultFound {
            if searchTable != nil{
                searchTable.isHidden = false
            }
            if saveButton != nil{
                saveButton.isHidden = false
            }
            if notFoundTV != nil{
                notFoundTV.isHidden = true
            }
        } else {
            if searchTable != nil{
                searchTable.isHidden = true
            }
            if saveButton != nil{
                saveButton.isHidden = true
            }
            if notFoundTV != nil{
                notFoundTV.isHidden = false
            }
        }
    }
    func showResult(_ text: String){
        word = text
        if saveButton != nil{
            saveButton.setTitle("Save '\(text)' to Favorites", for: .normal)
        }
        toggleVisibility(true)
        
        let searchURL = "\(Manager.baseURL)\(text)"
        let requestURL = URL(string: searchURL.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed) ?? "")!
        var request = URLRequest(url: requestURL)
        request.allHTTPHeaderFields = Manager.headers
        
        URLSession.shared.dataTask(with: request, completionHandler: {
            (data, response, error) in
                if error != nil {
                    print(error as Any)
                } else {
                    let httpResponse = response as? HTTPURLResponse
                    if httpResponse?.statusCode == 404 {
                        DispatchQueue.main.async {
                            self.presentAlert("Search Failed", "Word not found")
                            self.toggleVisibility(false)
                        }
                    } else if let json = try! JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any] {
                        if let definitions = json["definitions"] as? [[String:Any]] {
                            for definition in definitions {
                                if let imgUrl = definition["image_url"] as? String, let imgData = try? Data(contentsOf: URL(string: imgUrl.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed) ?? "")!){
                                    Manager.definitions.append(Definition(definition["type"]! as? String ?? "", definition["definition"]! as? String ?? "", imgData))
                                } else {
                                    Manager.definitions.append(Definition(definition["type"]! as? String ?? "", definition["definition"]! as? String ?? "", nil))
                                }
                            }
                        }
                        DispatchQueue.main.async {
                            self.reloadTableView()
                        }
                    }
                }
            }
        ).resume()
    }

    @IBAction func searchButtonPressed(_ sender: Any) {
        var error = ""
        let search = searchET.text!
        
        if search.count < 3{
            error = "Search requires at least 3 letters to function properly"
            toggleVisibility(false)
        } else {
            showResult(search)
        }
        
        if error.count > 0 {
            presentAlert("Search Failed", error)
        }
    }
    @IBAction func refreshButtonPressed(_ sender: Any) {
        showResult(searchTexts[Int.random(in: 0..<10)])
    }
    @IBAction func favoritesButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "hometofavorites", sender: self)
    }
    @IBAction func saveButtonPressed(_ sender: Any) {
        let addedWord = Word(word, Manager.definitions)
        coreDataAdd(addedWord)
    }
    
    func coreDataAdd(_ word: Word) {
        // Insert data
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Words")
        var result = [NSManagedObject]()
        do {
            result = try context.fetch(request) as! [NSManagedObject]
        } catch {
            // error here
            print("Failed to load data")
        }
        for item in result{
            if item.value(forKeyPath: "word") as? String == word.word{
                presentAlert("Error", "Duplicate word found")
                print("Duplicate word found")
                return
            }
        }
        let entity = NSEntityDescription.entity(forEntityName: "Words", in: context)
        let addedWord = NSManagedObject(entity: entity!, insertInto: context)
        addedWord.setValue(word.word , forKey: "word")
        addedWord.setValue(word.definitions, forKey: "definitions")
        Manager.words.append(addedWord)

        do {
            try context.save()
            presentAlert("Word Added", "New word added successfully")
            print("New word added successfully")
        } catch {
            print(error.localizedDescription)
        }
    }
    
}

extension SearchVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Manager.definitions.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "resultcell", for: indexPath) as! ResultCell
        cell.initView(Manager.definitions[indexPath.row])
        return cell
    }
    
}
