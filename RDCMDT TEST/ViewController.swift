//
//  ViewController.swift
//  RDCMDT TEST
//
//  Created by Zero One on 10/01/22.
//

import UIKit

var tempURL = "https://green-thumb-64168.uc.r.appspot.com"
var tokensave = ""
var usernamesave = ""

class ViewController: UIViewController {
    
    
    @IBOutlet weak var loadingIcon: UIActivityIndicatorView!
    
    
    var json: [String: Any] = [:]

    @IBOutlet weak var fieldUsername: UITextField!
    @IBOutlet weak var fieldPassword: UITextField!
    @IBOutlet weak var reqiredUsername: UILabel!
    @IBOutlet weak var reqiredPassword: UILabel!
    
    
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var btnRegister: UIButton!
    
    
    @IBAction func registerAct(_ sender: Any) {
        performSegue(withIdentifier: "goRegister", sender: self)
    }
    
    
    @IBAction func loginAct(_ sender: Any) {
        loadingIcon.startAnimating()
        loadingIcon.isHidden = false
        
        if fieldUsername.text != "" && fieldPassword.text != "" {
            reqiredUsername.isHidden = true
            reqiredPassword.isHidden = true
            
            let fillUsername = fieldUsername.text as! String
            let fillPassword = fieldPassword.text as! String
            
            json = ["username": "\(fillUsername)","password":"\(fillPassword)"]
            loginCheck(getJson: json)
            
            
            
            
        }else{
            if fieldUsername.text == ""{
                reqiredUsername.isHidden = false
            }else{
                reqiredUsername.isHidden = true
            }
            if fieldPassword.text == ""{
                reqiredPassword.isHidden = false
            }else{
                reqiredPassword.isHidden = true
            }
        }
        
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.btnLogin.layer.cornerRadius = self.btnLogin.bounds.height/2;
        self.btnLogin.clipsToBounds = true
        self.btnLogin.layer.borderWidth = 2
        self.btnLogin.layer.borderColor = UIColor.black.cgColor
        
        self.btnRegister.layer.cornerRadius = self.btnRegister.bounds.height/2;
        self.btnRegister.clipsToBounds = true
        self.btnRegister.layer.borderWidth = 2
        self.btnRegister.layer.borderColor = UIColor.black.cgColor
        
        
    }
    
    
    

    
    func loginCheck(getJson:[String:Any]){
        print(getJson)
        var statusLogin = ""
        var token = ""
        var accountno = ""
        var errorget = ""
        

                let jsonData = try? JSONSerialization.data(withJSONObject: getJson)

                
                let url = URL(string: "\(tempURL)/login")! 
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("\(String(describing: jsonData?.count))", forHTTPHeaderField: "Content-Length")
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
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
                            statusLogin = responseJSON["status"] as! String
                        }
                        
                        if ((responseJSON["token"] as? String) != nil){
                            token = responseJSON["token"] as! String
                            tokensave = token
                        }
                        
                        if ((responseJSON["accountno"] as? String) != nil){
                            accountno = responseJSON["accountno"] as! String
                        }
                        if ((responseJSON["username"] as? String) != nil){
                            usernamesave = responseJSON["username"] as! String
                        }
                        
                        
                        
                        if ((responseJSON["error"] as? String) != nil){
                            errorget = responseJSON["error"] as! String
                        }
                        
                        
                        
                        if statusLogin == "success"{
                            
                            DispatchQueue.main.async {
                                self.loadingIcon.stopAnimating()
                                self.loadingIcon.isHidden = true
                                self.performSegue(withIdentifier: "goHome", sender: self)
                                
                                print(token)
                                print("xx")
                            }
                            
                        }else if statusLogin == "failed"{
                            
                            
                            DispatchQueue.main.async {
                                
                                self.loadingIcon.stopAnimating()
                                self.loadingIcon.isHidden = true
                                
                            let alert = UIAlertController(title: "\(statusLogin)", message: "\(errorget)", preferredStyle: UIAlertController.Style.alert)
                            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: {(action:UIAlertAction) in
                                
                            }))
                            self.present(alert, animated: true, completion: nil)
                                
                            }
                            
                        }
                        
                        
                    }
                }

                task.resume()
        
        
        
        
    }

}

