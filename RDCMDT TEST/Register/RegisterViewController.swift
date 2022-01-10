//
//  RegisterViewController.swift
//  RDCMDT TEST
//
//  Created by Zero One on 10/01/22.
//

import UIKit

class RegisterViewController: UIViewController {

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    @IBAction func back(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    @IBOutlet weak var loadingIcon: UIActivityIndicatorView!
    
    
    @IBOutlet weak var fieldUsername: UITextField!
    @IBOutlet weak var fieldPassword: UITextField!
    @IBOutlet weak var fieldPasswordConfirm: UITextField!
    
    @IBOutlet weak var requiredPassword: UILabel!
    @IBOutlet weak var btnRegister: UIButton!
    
    var json: [String: Any] = [:]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.btnRegister.layer.cornerRadius = self.btnRegister.bounds.height/2;
        self.btnRegister.clipsToBounds = true
        self.btnRegister.layer.borderWidth = 2
        self.btnRegister.layer.borderColor = UIColor.black.cgColor
        
    }
    
    @IBAction func registerAct(_ sender: Any) {
        self.loadingIcon.startAnimating()
        if fieldPassword.text == fieldPasswordConfirm.text && fieldUsername.text != "" {
            requiredPassword.isHidden = true
            
            let fillUsername = fieldUsername.text
            let fillPassword = fieldPassword.text
            
            json = ["username": "\(fillUsername)","password":"\(fillPassword)"]
            registerSubmit(getJson: json)
            
        }else{
            requiredPassword.isHidden = false
        }
        
    }
    
    func registerSubmit(getJson:[String:Any]){
        
        var statusLogin = ""
        var token = ""
        var accountno = ""
        var errorget = ""
        

                let jsonData = try? JSONSerialization.data(withJSONObject: getJson)

                
                let url = URL(string: "\(tempURL)/register")!
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
                        
                        
                        if ((responseJSON["error"] as? String) != nil){
                            errorget = responseJSON["error"] as! String
                        }
                        
                        
                        
                        if statusLogin == "success"{
                            DispatchQueue.main.async {
                                self.loadingIcon.stopAnimating()
                            let alert = UIAlertController(title: "Status", message: "\(statusLogin)", preferredStyle: UIAlertController.Style.alert)
                            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: {(action:UIAlertAction) in
                                
                                
                                self.performSegue(withIdentifier: "goHome", sender: self)
                            }))
                            self.present(alert, animated: true, completion: nil)
                                
                            }
                        }else if statusLogin == "failed"{
                            
                            DispatchQueue.main.async {
                                self.loadingIcon.stopAnimating()
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
