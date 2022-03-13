//
//  ViewController.swift
//  TodoLIst
//
//  Created by Doy Kim on 2022/03/13.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // ---> UITableViewDataSource Stubs
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.checklistItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 셀 재사용
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell", for: indexPath)
        let item = self.checklistItems[indexPath.row]
        cell.textLabel?.text = item.title
        cell.accessoryType = item.isChecked ? .checkmark : .none
        
        return cell
    }
    
    // 편집모드에서 삭제 버튼이 눌렸을 때 어떤 셀이 눌렸는지 알려주는 메서드
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        self.checklistItems.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .left)
        if self.checklistItems.isEmpty {
            // 아이템이 없으면 편집모드 종료
            self.doneButtonTab()
        }
    }
    
    // 재정렬
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // 셀 정렬 순서대로 데이터 정렬되도록
        var items = self.checklistItems
        let item = items[sourceIndexPath.row]
        items.remove(at: sourceIndexPath.row)
        items.insert(item, at: destinationIndexPath.row)
        self.checklistItems = items
        
    }
    
    // ---> UITableViewDelegate Stubs
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        var item = checklistItems[indexPath.row]
        item.isChecked = !item.isChecked
        self.checklistItems[indexPath.row] = item
        //선택된 셀만 업데이트 하기. .automatic은 시스템이 알아서 애니메이션 결정
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    
    // ---> To-dos struct array variable
    var checklistItems = [checklistItem]() {
        // property observer
        didSet {
            self.saveChecklist()
        }
    }

    // ---> UITableView
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTab))
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.loadChecklist()
    }
    // Selector 타입으로 리턴하는 함수는 func 키워드 앞에 @objc를 붙여야한다. 오브젝트C와의 호환성 때문에
    
    @objc func doneButtonTab(){
        self.navigationItem.leftBarButtonItem = editButton
        // 편집모드 종료
        self.tableView.setEditing(false, animated: true)
    }

    // edit button outlet
    @IBOutlet var editButton: UIBarButtonItem!
    // done button
    var doneButton: UIBarButtonItem?
    
    
    // edit button Action Function
    @IBAction func editButtonTab(_ sender: UIBarButtonItem) {
        // 비어있지 않을 경우만 편집모드 활성화
        guard !self.checklistItems.isEmpty else { return }
        self.navigationItem.leftBarButtonItem = self.doneButton
        // 테이블 뷰를 편집모드로
        self.tableView.setEditing(true, animated: true)
        
        
    }
    
    
    // Add To-dos Button
    @IBAction func addButton(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add To-Dos", message: nil, preferredStyle: .alert )
        let registerButton = UIAlertAction(title: "Register", style: .default, handler: { [weak self]  _ in
            guard let title = alert.textFields?[0].text
            else { return }
            let item = checklistItem(title: title, isChecked: false)
            self?.checklistItems.append(item)
            self?.tableView.reloadData()
        })
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(cancelButton)
        alert.addAction(registerButton)
        alert.addTextField(configurationHandler: {
            textField in textField.placeholder = "Type to-do here"
        })
        self.present(alert, animated: true, completion: nil)
    }
    // userdefaults에 저장하는 함수
    func saveChecklist() {
        // .map을 이용하여 배열을 Dictionary 형태로 바꿈, userdefaults는 Key-value로 저장되기 때문에
        let data = self.checklistItems.map {
            [
                "title" : $0.title,
                "isChecked" : $0.isChecked
                
            ]
        }
        // userdefaults는 singletone이기 때문에 하나의 인스턴스만 존재
        let userDefaults = UserDefaults.standard
        // 저장
        userDefaults.set(data, forKey: "checklistItems")
    }
    func loadChecklist() {
        let userDefaults = UserDefaults.standard
        // 불러오기. Any타입으로 리턴되기 때문에 딕셔너리 데이터로 타입캐스팅
        guard let data = userDefaults.object(forKey: "checklistItems") as? [[String: Any]] else { return }
        self.checklistItems = data.compactMap {
            guard let title = $0["title"] as? String else {return nil}
            guard let isChecked = $0["isChecked"] as? Bool else {return nil}
            return checklistItem(title: title, isChecked: isChecked)
        }
    }
}


struct checklistItem {
    var title: String
    var isChecked: Bool
}


