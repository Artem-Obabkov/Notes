//
//  TextVC.swift
//  Notes
//
//  Created by pro2017 on 11/02/2021.
//

import UIKit

class TextVC: UIViewController {
    
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var dataLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var bottomConstrainINTextview: NSLayoutConstraint!
    
    var segueID = ""
    var editNote: Note!
    var noteCreationDate = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.delegate = self
        setupDesign()
        
        // Создаем 2 obervers, которые следят за положением клавиатуры
        NotificationCenter.default.addObserver(self, selector: #selector(changeTextLocationInTextView(notification: )), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(changeTextLocationInTextView(notification: )), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        if segueID == "editTextVC" {
            // Присваиваем значения оутлетам
            getDataFromNote(self.editNote)
            self.dataLabel.text = noteCreationDate
        }
        
    }

    @IBAction func saveNewNote(_ sender: UIBarButtonItem) {
        self.segueID = ""
    }
    
    
    private func setupDesign() {
        
        self.navigationController?.navigationBar.tintColor = UIColor(named: "ButtonColor")
        
        // Настройка даты
        // Будет активироваться только при переходе по кнопке добавить
        if segueID == "addTextVC" {
            let currentDate = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "d MMMM yyyy"
            let date = dateFormatter.string(from: currentDate)
            self.dataLabel.text = date
        }
        
        
        textView.keyboardAppearance = UIKeyboardAppearance.dark
        
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        
    }
    
    
    // Save data
    
    func saveDate() {
        
        if !textView.text.isEmpty && textView.text != "Hi..." {
            
            let noteResult = getTitleFromTextView()
            
            
            let note = Note(name: noteResult.name, subName: noteResult.desc, isFavourite: false, noteText: noteResult.noteText)
            
            // Сохраняем изменения в отредактированной заметке 
            if editNote != nil {
                
                try! realm.write {
                    editNote.name = note.name
                    editNote.subName = note.subName
                    editNote.isFavourite = note.isFavourite
                    editNote.noteText = note.noteText
                }
                
            } else {
                realmManager.saveDate(note)
            }
            
        }
    }
    
    // Присваиваем переданные значения для редактировки оутлетам view
    private func getDataFromNote(_ note: Note) {
        
        self.textView.text = note.name
        
        self.textView.text = note.noteText
        
        guard let subName = note.subName else { return }
        guard subName != "No description" else { return }
        
        
        
    }
    
    deinit {
        print("text vc was deinited")
    }
    
}

// Работаем с textView
extension TextVC: UITextViewDelegate {
    
    // Убирает начальный текст
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    // Логика перемещения текста при появлении клавиатуры
    @objc func changeTextLocationInTextView(notification: Notification) {
        
        guard let userInfo = notification.userInfo as? [String: Any], let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
        // Если происходит скрытие клавиатуры
        if notification.name == UIResponder.keyboardWillHideNotification {
            textView.contentInset = UIEdgeInsets.zero
        } else {
            // Если происходит появление клавиатуры
            textView.contentInset = UIEdgeInsets(
                top: 0,
                left: 0,
                bottom: keyboardFrame.height + bottomConstrainINTextview.constant,
                right: 0)
            textView.scrollIndicatorInsets = textView.contentInset
            textView.scrollRangeToVisible(textView.selectedRange)
            
        }
        
    }
    
    // Отвечает за логику присвоения имени и описания. Лучше туда не лезть
    private func getTitleFromTextView() -> (name: String, desc: String, noteText: String) {

        // Проверяем не пустой ли textView
       
        guard var text = self.textView.text, let noteText = self.textView.text else { return (name: "", desc: "", noteText: "") }
        
        var name = ""
        var count = 0
        
        
        // Достаем первую строку из текста
            
        for character in text.indices {
                
            name.append(text[character])
            
            if text[character] == "\n" {
                
                // Если первый символ - перенос строки, то возвращаем NewNote
                if count == 0 {
                    
                    for character in text.indices {
                        
                        if text[character] != "\n" {
                            
                            let range = text.index(text.startIndex, offsetBy: 0)..<text.firstIndex(of: text[character])!
                            text.removeSubrange(range)
                            
                            for character in text.indices {
                                
                                name.append(text[character])
                                
                                if text[character] == "\n" {
                                    
                                    let range = text.index(text.startIndex, offsetBy: 0)..<text.index(after: character)
                                    text.removeSubrange(range)
                                    
                                    for character in text.indices {
                                        
                                        if text[character] != "\n" {
                                            
                                            let range = text.index(text.startIndex, offsetBy: 0)..<text.firstIndex(of: text[character])!
                                            text.removeSubrange(range)
                                            
                                            return (name: name.replacingOccurrences(of: "\n", with: ""), desc: text, noteText: noteText)
                                        }
                                    }
                                }
                            }
                            return (name: text, desc: "No description", noteText: noteText)
                        }
                    }
                }
                
                // С помощью определенного интервала достаем description
                let range = text.index(text.startIndex, offsetBy: 0)..<text.index(after: character)
                text.removeSubrange(range)
                
                for character in text.indices {
                    if text[character] != "\n" {
                        let range = text.index(text.startIndex, offsetBy: 0)..<text.firstIndex(of: text[character])!
                        text.removeSubrange(range)
                        return (name: name, desc: text, noteText: noteText)
                    }
                }
                return (name: name, desc: "No description", noteText: noteText)
                
            }
            
            count += 1
            
        }
        
        return (name: name, desc: "No description", noteText: noteText)
    }
    
    // Скрытие клавиатуры
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.textView.resignFirstResponder()
    }
    
}
