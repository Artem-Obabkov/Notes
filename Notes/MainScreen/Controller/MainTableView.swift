//
//  MainTableView.swift
//  Notes
//
//  Created by pro2017 on 10/02/2021.
//

import UIKit
import RealmSwift

class MainTableView: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sortItemsButton: UIBarButtonItem!
    
    // Массив элементов с сортировкой по isFavourite
    var notes = realm.objects(Note.self).sorted(byKeyPath: "isFavourite", ascending: false)
    var filteredNotes: Results<Note>!
    
    // Доп переменная для сортировки элементов
    var isNotesSorted = false
    
    let searchController = UISearchController(searchResultsController: nil)
    
    private var isSearchBarEmpty: Bool {
        guard let text = searchController.searchBar.text else { return true }
        return text.isEmpty
    }
    
    // Если происходит фильтрация то возвращается true
    private var isFitering: Bool {
        return searchController.isActive && !isSearchBarEmpty
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tableFooterView = UIView()
        
        // Работа с searchViewController
        searchController.searchResultsUpdater = self
        
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        searchController.searchBar.tintColor = UIColor(named: "PrimaryText")
        navigationItem.searchController = searchController
        self.definesPresentationContext = true
    }
    
    // Работа с таблицей
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isFitering {
            return filteredNotes.count
        } else {
            return notes.isEmpty ? 0 : notes.count
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "noteCell") as! NoteCell
        
        cell.isFavourite.isHidden = true
        
        var note = Note()
        
        if isFitering {
            note = filteredNotes[indexPath.row]
        } else {
            note = notes[indexPath.row]
        }
        
        if note.isFavourite {
            cell.isFavourite.isHidden = false
        }
        
        cell.nameLabel.text = note.name
        cell.descriptionLabel.text = note.subName
        
        
        return cell
    }
    
    // Удаление значений
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            let note = notes[indexPath.row]
            realmManager.deleteData(note)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
         
    }
    
    
    @IBAction func sortItems(_ sender: UIBarButtonItem) {

        self.isNotesSorted.toggle()

        if self.isNotesSorted {
            
            // Сортировка элементов сразу по двум параметрам. Избранные всегда будут в начале списка и элементы будут сортироваться по дате
            let sortProperties = [SortDescriptor(keyPath: "isFavourite", ascending: false), SortDescriptor(keyPath: "date", ascending: true)]

            self.notes = realm.objects(Note.self).sorted(by: sortProperties)
            
            tableView.reloadData()

            self.navigationItem.leftBarButtonItem?.image = UIImage(
                systemName: "arrow.up",
                withConfiguration: UIImage.SymbolConfiguration(weight: .light))
            
        } else {

            let sortProperties = [SortDescriptor(keyPath: "isFavourite", ascending: false), SortDescriptor(keyPath: "date", ascending: false)]

            self.notes = realm.objects(Note.self).sorted(by: sortProperties)
            
            tableView.reloadData()

            self.navigationItem.leftBarButtonItem?.image = UIImage(
                systemName: "arrow.down",
                withConfiguration: UIImage.SymbolConfiguration(weight: .light))
        }
    }
    
    // Принимаем значения
    
    @IBAction func getNote(_ segue: UIStoryboardSegue) {
        
        guard let textVC = segue.source as? TextVC else { return }
        
        textVC.saveDate()
        self.tableView.reloadData()
        
    }
    
    
    // Редактирование элемента
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "editTextVC" {
            
            let textVC = segue.destination as! TextVC
            
            let indexPath = tableView.indexPathForSelectedRow!
            
            var note = Note()
            
            if isFitering {
                note = filteredNotes[indexPath.row]
            } else {
                note = notes[indexPath.row]
            }
            
            textVC.editNote = note
            
            // Преобразовываем дату
            let noteDate = note.date
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "d MMMM yyyy"
            let date = dateFormatter.string(from: noteDate)
            
            textVC.noteCreationDate = date
            
            
            textVC.segueID = "editTextVC"
            
        } else {
            
            let textVC = segue.destination as! TextVC
            
            textVC.segueID = "addTextVC"
            
        }
    }
    
    // Дополнительная кнопка при свайпе
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let action = isFavouriteAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    private func isFavouriteAction(at indexPath: IndexPath) -> UIContextualAction {
        
        let note = notes[indexPath.row]
        
        let action = UIContextualAction(style: .destructive, title: "") { (action, view, completion) in
            
            try! realm.write {
                note.isFavourite.toggle()
            }
            
            // Добавляем задержку к обновлению tableView
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.675) {
                
                // При обновлении tableView заметки с пометкой важные переносятся вверх экрана
                self.notes = self.notes.sorted(byKeyPath: "isFavourite", ascending: false)
                self.tableView.reloadData()
                
            }
            
            completion(true)
            
        }
        
        action.backgroundColor = UIColor(named: "ButtonColor")
        action.image = UIImage(systemName: "star",
                               withConfiguration: UIImage.SymbolConfiguration(weight: .light))
        
        return action
        
    }
    
}

// Работа с searchController
extension MainTableView: UISearchResultsUpdating, UISearchControllerDelegate {
    
    
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContent(searchController.searchBar.text!)
    }
    
    // Фильтрация контента
    private func filterContent(_ searchText: String) {
        
        filteredNotes = notes.filter("name CONTAINS[c] %@ OR subName CONTAINS[c] %@", searchText, searchText)
        
        tableView.reloadData()
    }
}
