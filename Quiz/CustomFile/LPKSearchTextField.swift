import UIKit
import CoreData

struct SearchData:Codable{
    let id:String
    let name:String
}

protocol LPKSearchTextFieldDelegate {
    func OnSelect(textField: UITextField, selectedData:SearchData)
}

class LPKSearchTextField: UITextField{
    
    var dataList : [SearchData] = [SearchData]()
    var resultsList : [SearchData] = [SearchData]()
    var tableView: UITableView?
    var LPKSearchdelegate:LPKSearchTextFieldDelegate?
    var selectedData:SearchData?
    var isFilter = true
    
    // Connecting the new element to the parent view
    open override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        tableView?.removeFromSuperview()
    }
    
    override open func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        self.addTarget(self, action: #selector(LPKSearchTextField.textFieldDidChange), for: .editingChanged)
        self.addTarget(self, action: #selector(LPKSearchTextField.textFieldDidBeginEditing), for: .editingDidBegin)
        self.addTarget(self, action: #selector(LPKSearchTextField.textFieldDidEndEditing), for: .editingDidEnd)
        self.addTarget(self, action: #selector(LPKSearchTextField.textFieldDidEndEditingOnExit), for: .editingDidEndOnExit)
        
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        buildSearchTableView()
        
    }
    
    
    //////////////////////////////////////////////////////////////////////////////
    // Text Field related methods
    //////////////////////////////////////////////////////////////////////////////
    
    @objc open func textFieldDidChange(){
        print("Text changed ...")
        filter()
        updateSearchTableView()
        tableView?.isHidden = false
    }
    
    @objc open func textFieldDidBeginEditing() {
        print("Begin Editing")
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.3, execute: {
            DispatchQueue.main.async {
                self.filter()
                self.updateSearchTableView()
                self.tableView?.isHidden = false
            }
        });
        
    }
    
    @objc open func textFieldDidEndEditing() {
        print("End editing")
        tableView?.isHidden = true
        
    }
    
    @objc open func textFieldDidEndEditingOnExit() {
        print("End on Exit")
    }
    
    //////////////////////////////////////////////////////////////////////////////
    // Data Handling methods
    //////////////////////////////////////////////////////////////////////////////
    
    
    // MARK: Filtering methods
    
    fileprivate func filter() {
        
        if !self.isFilter{
            resultsList = self.dataList
            tableView?.reloadData()
            return
        }
        resultsList = self.dataList.filter{($0.name.lowercased()).contains(self.text!.lowercased())}
        if self.text?.count == 0{
            resultsList = self.dataList
        }
        tableView?.reloadData()
    }
    
    
}

extension LPKSearchTextField: UITableViewDelegate, UITableViewDataSource {
    
    
    //////////////////////////////////////////////////////////////////////////////
    // Table View related methods
    //////////////////////////////////////////////////////////////////////////////
    
    
    // MARK: TableView creation and updating
    
    // Create SearchTableview
    func buildSearchTableView() {
        
        if let tableView = tableView {
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: "LPKSearchTextFieldCell")
            tableView.delegate = self
            tableView.dataSource = self
            
            tableView.tableFooterView = UIView()
            tableView.layer.backgroundColor = UIColor.clear.cgColor
            tableView.separatorColor = .lightGray
            tableView.layer.borderColor = UIColor.white.cgColor
            tableView.layer.borderWidth = 1.5
           // tableView.elevate(elevation: 1.8)
            
            self.window?.addSubview(tableView)
            
        } else {
            //addData()
            print("tableView created")
            tableView = UITableView(frame: CGRect.zero)
        }
        
        updateSearchTableView()
    }
    
    // Updating SearchtableView
    func updateSearchTableView() {
        
        if let tableView = tableView {
            superview?.bringSubviewToFront(tableView)
            var tableHeight: CGFloat = (self.window?.frame.height)! - (self.frame.height + self.frame.origin.y)
          //  tableHeight = tableView.contentSize.height
            tableView.contentSize.height += 0
            
            if tableHeight > tableView.contentSize.height{
                tableHeight = tableView.contentSize.height
            }
            // Set a bottom margin of 10p
            if tableHeight < tableView.contentSize.height {
                tableHeight -= 10
            }
            
            // Set tableView frame
            var tableViewFrame = CGRect(x: 0, y: 5, width: frame.size.width - 4, height: tableHeight)
            tableViewFrame.origin = self.convert(tableViewFrame.origin, to: nil)
            tableViewFrame.origin.x += 2
            tableViewFrame.origin.y += frame.size.height + 2
            UIView.animate(withDuration: 0.2, animations: { [weak self] in
                self?.tableView?.frame = tableViewFrame
            })
            
            //Setting tableView style
            tableView.layer.masksToBounds = true
            tableView.separatorInset = UIEdgeInsets.zero
            
            tableView.layer.cornerRadius = 5.0
            tableView.separatorColor = Apps.BASIC_COLOR
            tableView.backgroundColor = UIColor.white.withAlphaComponent(0.4)
            tableView.layer.borderWidth = 1
            tableView.layer.borderColor = Apps.BASIC_COLOR_CGCOLOR
            
            if self.isFirstResponder {
                superview?.bringSubviewToFront(self)
            }
            
            tableView.reloadData()
        }
    }
    
    // MARK: TableViewDataSource methods
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultsList.count
    }
    
    // MARK: TableViewDelegate methods
    
    //Adding rows in the tableview with the data from dataList
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LPKSearchTextFieldCell", for: indexPath) as UITableViewCell
        cell.textLabel?.textColor = Apps.BASIC_COLOR
        cell.backgroundColor = UIColor.white
        cell.textLabel?.text = resultsList[indexPath.row].name
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected row")
        self.text = resultsList[indexPath.row].name
        tableView.isHidden = true
        self.endEditing(true)
        self.selectedData = resultsList[indexPath.row]
        self.LPKSearchdelegate?.OnSelect(textField: self, selectedData: resultsList[indexPath.row])
    }
    
    // MARK: Early testing methods
    func addData(data:[SearchData]){
        dataList = data
    }
    
}
