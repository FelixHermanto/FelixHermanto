//
//  TranferViewController.swift
//  RDCMDT TEST
//
//  Created by Zero One on 10/01/22.
//

import UIKit

class TranferViewController: UIViewController, UIPickerViewDelegate,UIPickerViewDataSource {
    
    @IBOutlet weak var loadingIcon: UIActivityIndicatorView!
    
    @IBOutlet weak var btnTranfernow: UIButton!
    
    var json: [String: Any] = [:]
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return arrPayeeID.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return arrPayeeName[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        fieldPayee.text = arrPayeeName[row]
        self.view.endEditing(true)
    }
    
    var payeePicker: UIPickerView!

    
    
    @IBOutlet weak var fieldPayee: UITextField!
    @IBOutlet weak var fieldAmount: UITextField!
    @IBOutlet weak var fieldDesc: UITextField!
    
    @IBOutlet weak var errorMsg: UILabel!

    
    
    var arrPayeeID :[String] = []
    var arrPayeeName :[String] = []
    var arrPayeeAccountno :[String] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.btnTranfernow.layer.cornerRadius = self.btnTranfernow.bounds.height/2;
        self.btnTranfernow.clipsToBounds = true
        self.btnTranfernow.layer.borderWidth = 2
        self.btnTranfernow.layer.borderColor = UIColor.black.cgColor
        
        payeePicker = UIPickerView()

        payeePicker.dataSource = self
        payeePicker.delegate = self

        fieldPayee.inputView = payeePicker
        
        
    }
    
    
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: animated)
        requestPayee()
    }
    
    func requestPayee(){
        
        print("requestedxxx")
        
        arrPayeeID.removeAll()
        arrPayeeName.removeAll()
        arrPayeeAccountno.removeAll()
        
        var statusRequest = ""
        var errorget = ""
       
                
                let url = URL(string: "\(tempURL)/payees")!
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
                            if let getValueJSON = blog["id"] as? String {
                                self.arrPayeeID.append(getValueJSON)
                            }
                            if let getValueJSON = blog["name"] as? String {
                                self.arrPayeeName.append(getValueJSON)
                            }
                            if let getValueJSON = blog["accountNo"] as? String {
                                self.arrPayeeAccountno.append(getValueJSON)
                            }
                            }
                        }
                        
                        
                        
                        if statusRequest == "success"{
                            print(self.arrPayeeName)
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
    
    
    func tranferSubmit(getJson:[String:Any]){
        
        var statusrequest = ""
        var transactionId = ""
        var errorget = ""
        
        print(getJson)

                let jsonData = try? JSONSerialization.data(withJSONObject: getJson)

                
                let url = URL(string: "\(tempURL)/transfer")!
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("\(String(describing: jsonData?.count))", forHTTPHeaderField: "Content-Length")
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.setValue("\(tokensave)", forHTTPHeaderField: "Authorization")

                
                request.httpBody = jsonData

                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    guard let data = data, error == nil else {
                        print(error?.localizedDescription ?? "No data")
                        return
                    }
                    let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                    if let responseJSON = responseJSON as? [String: Any] {
                        print(responseJSON)
                        
                        if ((responseJSON["status"] as? String) != nil){
                            statusrequest = responseJSON["status"] as! String
                        }
                        if ((responseJSON["transactionId"] as? String) != nil){
                            transactionId = responseJSON["transactionId"] as! String
                        }
                        
                        
                        
                        if ((responseJSON["error"] as? String) != nil){
                            errorget = responseJSON["error"] as! String
                        }
                        
                        
                        
                        if statusrequest == "success"{
                            DispatchQueue.main.async {
                                self.loadingIcon.stopAnimating()
                            let alert = UIAlertController(title: "Status", message: "\(statusrequest), transactionId : \(transactionId)", preferredStyle: UIAlertController.Style.alert)
                            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: {(action:UIAlertAction) in
                                
                                self.fieldDesc.text = ""
                                self.fieldAmount.text = ""
                                self.errorMsg.isHidden = true
                            }))
                            self.present(alert, animated: true, completion: nil)
                                
                            }
                        }else if statusrequest == "failed"{
                            
                            DispatchQueue.main.async {
                                self.loadingIcon.stopAnimating()
                                self.errorMsg.text = "\(errorget)"
                                self.errorMsg.isHidden = false
                                
                            }
                            
                        }
                        
                        
                    }
                }

                task.resume()
        
        
        
        
    }

    @IBAction func tranferAct(_ sender: Any) {
        
        loadingIcon.startAnimating()
        if fieldPayee.text == ""{
            errorMsg.isHidden = false
            errorMsg.text = "Please select Payee"
        }else{
            errorMsg.isHidden = true
            
            let indexof = arrPayeeName.firstIndex(where: {$0 == fieldPayee.text})
            
            let fillpayee = arrPayeeAccountno[indexof!]
            var fillamount = fieldAmount.text
            let filldesc = fieldDesc.text!
            
            
            
            json = ["receipientAccountNo": "\(fillpayee)","amount":Int(fillamount!),"description":"\(filldesc)"]
            tranferSubmit(getJson: json)
        }
        
        
        
        
    }
    

}
