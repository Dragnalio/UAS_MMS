//
//  FavoriteVC.swift
//  dictionary
//
//  Created by Handika Limanto on 14/02/21.
//

import UIKit
import CoreData

class FavoritesVC: UIViewController {

    @IBOutlet weak var favoritesTable: UITableView!
    @IBOutlet weak var notFoundTV: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        favoritesTable.delegate = self
        favoritesTable.dataSource = self
        
        reloadTableView()
    }
    
    func reloadTableView(){
        Manager.initCoreData(UIApplication.shared.delegate as! AppDelegate)
        coreDataLoad()
        favoritesTable.reloadData()
        if Manager.words.count > 0{
            toggleVisibility(true)
        } else {
            toggleVisibility(false)
        }
    }
    func presentAlert(_ title: String, _ message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let close = UIAlertAction(title: "Close", style: .cancel, handler: nil)
        alert.addAction(close)
        
        present(alert, animated: true, completion: nil)
    }
    func toggleVisibility(_ resultFound: Bool){
        if resultFound {
            if favoritesTable != nil{
                favoritesTable.isHidden = false
            }
            if notFoundTV != nil{
                notFoundTV.isHidden = true
            }
        } else {
            if favoritesTable != nil{
                favoritesTable.isHidden = true
            }
            if notFoundTV != nil{
                notFoundTV.isHidden = false
            }
        }
    }
    
    func coreDataLoad() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        Manager.words.removeAll()
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Words")
        do {
            let result = try context.fetch(request) as! [NSManagedObject]
            Manager.words = result
        } catch {
            // error here
            print("Failed to load data")
        }
    }
    func coreDataDelete(_ index: Int){
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Words")
        var result = [NSManagedObject]()
        do {
            result = try context.fetch(request) as! [NSManagedObject]
        } catch {
            // error here
            print("Failed to load data")
        }
        
        for item in result {
            if item.value(forKeyPath: "word") as? String == Manager.words[index].value(forKeyPath: "word") as? String {
                context.delete(item)
                Manager.words.remove(at: index)
                break
            }
        }
        
        do {
            try context.save()
//            presentAlert("Word Deleted", "Word deleted successfully")
            print("Word deleted successfully")
        } catch {
            print(error.localizedDescription)
        }
        return
    }
}

extension FavoritesVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            Manager.initCoreData(UIApplication.shared.delegate as! AppDelegate)
            coreDataDelete(indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            if Manager.words.count > 0{
                toggleVisibility(true)
            } else {
                toggleVisibility(false)
            }
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Manager.words.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "favoritecell", for: indexPath) as! FavoriteCell
        cell.initView(Manager.getWord(indexPath.row))
        return cell
    }
    
}
