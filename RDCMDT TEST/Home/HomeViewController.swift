//
//  HomeViewController.swift
//  RDCMDT TEST
//
//  Created by Zero One on 11/01/22.
//

import UIKit

var arrGHeaderDate : [String] = []
var arrGHeaderDateDic = Dictionary<String, [HomeViewController.Transaction]>()

class HomeViewController: UIViewController, UITableViewDataSource,UITableViewDelegate {
    let refreshControl = UIRefreshControl()
    struct Transaction {
        let name : String
        let headerdate : String
        let amount : Double
        let accountno : String
        
    }
    
    @IBOutlet weak var btnMaketranfer: UIButton!
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return arrGHeaderDate[section]
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrGHeaderDate.count
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let myLabel = UILabel()
        myLabel.frame = CGRect(x: 10, y: 8, width: 320, height: 40)
        myLabel.font = UIFont.boldSystemFont(ofSize: 18)
        myLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
        
        let headerView = UIView()
        headerView.addSubview(myLabel)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        let carKey = arrGHeaderDate[section]
        if let carValues = arrGHeaderDateDic[carKey] {
            return carValues.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableViewTransaction.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TransactionTableViewCell
        
        cell.selectionStyle = .none
        
        let keys = arrGHeaderDate
        let section = keys[indexPath.section]
        let trans = arrGHeaderDateDic[section]!
        let row = trans[indexPath.row]
        
        cell.nameLbl.text = row.name
        cell.accountnoLbl.text = row.accountno
        cell.valueLbl.text = "\(row.amount)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    var arrTransDate :[String] = []
    var arrTransName :[String] = []
    var arrTransValue :[Double] = []
    var arrTransAccountno :[String] = []

    @IBOutlet weak var logoutBtn: UIButton!
    
    @IBOutlet weak var valueHave: UILabel!
    @IBOutlet weak var accountNo: UILabel!
    @IBOutlet weak var accountHolder: UILabel!
    
    @IBOutlet weak var tableViewTransaction: UITableView!
    
    
    @IBAction func logoutAct(_ sender: Any) {
        performSegue(withIdentifier: "goLogin", sender: self)
    }
    
    @IBOutlet weak var viewBackground: UIView!
    
    func roundCorners(view :UIView, corners: UIRectCorner, radius: CGFloat){
            let path = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            view.layer.mask = mask
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewBackground.clipsToBounds = true
        self.roundCorners(view: viewBackground, corners: [.bottomRight, .topRight], radius: 15)
        self.btnMaketranfer.layer.cornerRadius = self.btnMaketranfer.bounds.height/2;
        self.btnMaketranfer.clipsToBounds = true
        self.btnMaketranfer.layer.borderWidth = 2
        self.btnMaketranfer.layer.borderColor = UIColor.black.cgColor
        
        accountHolder.text = usernamesave
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
           refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
           tableViewTransaction.addSubview(refreshControl)

        
    }
    @objc func refresh(_ sender: AnyObject) {
       requestBalance()
        requestTransaction()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: animated)
        requestBalance()
        requestTransaction()
    }
    func sliceString(str: String, start: Int, end: Int) -> String {
        let data = Array(str)
        return String(data[start..<end])
    }
    
    func requestTransaction(){
        
        
        
        
        var statusRequest = ""
        var errorget = ""
        
       
                
                let url = URL(string: "\(tempURL)/transactions")!
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.setValue("\(tokensave)", forHTTPHeaderField: "Authorization")
        
                
                

                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    guard let data = data, error == nil else {
                        print(error?.localizedDescription ?? "No data")
                        return
                    }
                    let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                    if let responseJSON = responseJSON as? [String: Any] {
                        print(responseJSON)
                        
                        if ((responseJSON["status"] as? String) != nil){
                            statusRequest = responseJSON["status"] as! String
                        }
                        if ((responseJSON["error"] as? String) != nil){
                            errorget = responseJSON["error"] as! String
                        }
                        
                        
                        if let blogs = responseJSON["data"] as? [[String: AnyObject]] {
                            for blog in blogs {
                            if let getValueJSON = blog["transactionDate"] as? String {
                                self.arrTransDate.append(self.sliceString(str: getValueJSON, start: 0, end: 10))
                            }
                            if let getValueJSON = blog["amount"] as? Double {
                                self.arrTransValue.append(getValueJSON)
                            }
                                
                                
                                if let receipient = blog["receipient"] as? [String:String]{
                                    if let getValueJSON = receipient["accountNo"] {
                                        self.arrTransAccountno.append(getValueJSON)
                                    }
                                    if let getValueJSON = receipient["accountHolder"] {
                                        self.arrTransName.append(getValueJSON)
                                    }
                                }
                                
                            
                            }
                        }
                        
                        
                        
                        
                        if statusRequest == "success"{
                            DispatchQueue.main.async {
                            
                                self.refreshControl.endRefreshing()
                                do {
                                    try self.generateGrouping()
                                } catch {
                                    print(error)
                                    print(error.localizedDescription)
                                }
                                
                                self.tableViewTransaction.reloadData()
                                
                            }
                        }else if statusRequest == "failed"{
                            
                            DispatchQueue.main.async {
                            let alert = UIAlertController(title: "\(statusRequest)", message: "\(errorget)", preferredStyle: UIAlertController.Style.alert)
                            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: {(action:UIAlertAction) in
                                
                            }))
                            self.present(alert, animated: true, completion: nil)
                                
                            }
                            
                        }
                        
                        
                    }
                }

                task.resume()
        
        
        
        
    }
    
    func requestBalance(){
        
        
        
        
        var statusRequest = ""
        var errorget = ""
        var accountnoget = ""
        var accountbalance = ""
       
                
                let url = URL(string: "\(tempURL)/balance")!
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.setValue("\(tokensave)", forHTTPHeaderField: "Authorization")
        
                
                

                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    guard let data = data, error == nil else {
                        print(error?.localizedDescription ?? "No data")
                        return
                    }
                    let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                    if let responseJSON = responseJSON as? [String: Any] {
                        print(responseJSON)
                        
                        if ((responseJSON["status"] as? String) != nil){
                            statusRequest = responseJSON["status"] as! String
                        }
                        if ((responseJSON["error"] as? String) != nil){
                            errorget = responseJSON["error"] as! String
                        }
                        
                        if ((responseJSON["accountNo"] as? String) != nil){
                            accountnoget = (responseJSON["accountNo"] as! String)
                        }
                        if ((responseJSON["balance"] as? Double) != nil){
                           accountbalance = "SGD \(responseJSON["balance"]!)"
                        }
                        
                        
                        
                        
                        
                        if statusRequest == "success"{
                            DispatchQueue.main.async {
                                self.refreshControl.endRefreshing()
                            self.accountNo.text = accountnoget
                            self.valueHave.text = accountbalance
                            }
                        }else if statusRequest == "failed"{
                            
                            DispatchQueue.main.async {
                            let alert = UIAlertController(title: "\(statusRequest)", message: "\(errorget)", preferredStyle: UIAlertController.Style.alert)
                            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: {(action:UIAlertAction) in
                                
                            }))
                            self.present(alert, animated: true, completion: nil)
                                
                            }
                            
                        }
                        
                        
                    }
                }

                task.resume()
        
        
        
        
    }
    var transactionGroup : [Transaction] = []
    func generateGrouping(){
        
        
        arrGHeaderDateDic.removeAll()
        transactionGroup.removeAll()
        arrGHeaderDate.removeAll()
        for i in 0 ..< arrTransDate.count{
            
            
            
            
            transactionGroup.append(Transaction(name: arrTransName[i],
                                      headerdate: arrTransDate[i],
                                      amount : arrTransValue[i],
                                      accountno : arrTransAccountno[i]))
        }
        arrGHeaderDateDic = Dictionary(grouping: transactionGroup, by: {$0.headerdate })
        
        if arrTransDate.count != 0{
            for i in 0 ..< arrTransDate.count{
                if arrGHeaderDate.firstIndex(of: arrTransDate[i]) != nil {
                    
                }else{
                    arrGHeaderDate.append(arrTransDate[i])
                }
                
            }
        }
        
    }
    

   

}

