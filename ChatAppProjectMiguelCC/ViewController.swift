//
//  ViewController.swift
//  ChatAppProjectMiguelCC
//
//  Created by Escuela de Tecnologías Aplicadas on 3/2/23.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //backgound de la aplicacion
    @IBOutlet weak var arasakaWallpapper: UIImageView!
    
    //caja de texto del chat
    @IBOutlet weak var chatWriteBox: UITextField!
    //boton de enviar los mensajes
    @IBOutlet weak var sendViewButton: UIButton!
    //tableview con las celdas
    @IBOutlet weak var tableView: UITableView!
    //constraint inferior la caja de texto
    @IBOutlet weak var chatWriteBoxConst: NSLayoutConstraint!
    //constraint inferior del boton de enviar
    @IBOutlet weak var sendButtonConst: NSLayoutConstraint!
    
    //implementar el userdefault de forma global
    let defaults = UserDefaults.standard
    
    let userToken = "06f5267fba3cfd31ca36aa53f09934ba2694eba816b0c642eb6439c46b603f97"
    
    // el array que contiene los mensajes
    public var mensajes : [[String]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        //atributos de la caja de escritura
        self.chatWriteBox.layer.borderColor = UIColor.systemPink.cgColor
        self.chatWriteBox.layer.borderWidth = 1
        self.chatWriteBox.layer.cornerRadius = 3
        
        //attributos de la imagen del background
        self.arasakaWallpapper.layer.borderColor = UIColor.systemPink.cgColor
        self.arasakaWallpapper.layer.borderWidth = 1
        self.arasakaWallpapper.layer.cornerRadius = 3
        
        
        
        //conexion entre appdelegate y viewController
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.viewController = self
        
        //obserbador de las notificaciones
        NotificationCenter.default.addObserver(
        self,
        selector: #selector(self.keyboardWillShow),
        name: UIResponder.keyboardWillShowNotification,
        object: nil)

        NotificationCenter.default.addObserver(
        self,
        selector: #selector(self.keyboardWillHide),
        name: UIResponder.keyboardWillHideNotification,
        object: nil)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))

        view.addGestureRecognizer(tap)
        
        //al iniciar la app el aray de mensajes estara vacio, por tanto lo cargara con los mensajes guardados
        if mensajes.isEmpty == true {
            mensajes = defaults.object(forKey: "SavedMensajes") as? [[String]] ?? [[String]]()
        }
        
        
        
    }
    
    //Usando la funcion del ciclo de vida
    override func viewWillDisappear(_ animated: Bool) {
        
        //Guardamos el contenido del array de mensajes
        defaults.set(mensajes, forKey: "SavedMensajes")
        
    }
    
    @objc func keyboardWillShow(_ notification: NSNotification) {
            // mover los elementos cuando el textfield esta siendo editado
            if chatWriteBox.isEditing {
                moveViewWithKeyboard(notification: notification, viewBottomConstraint: [self.chatWriteBoxConst, self.sendButtonConst], keyboardWillShow: true)
            }
    }
        
    @objc func keyboardWillHide(_ notification: NSNotification) {
        moveViewWithKeyboard(notification: notification, viewBottomConstraint: [self.chatWriteBoxConst, self.sendButtonConst], keyboardWillShow: false)
    }
    
    @objc func dismissKeyboard() {
        //detectar cuando el textfield no esta siendo usado
        chatWriteBox.endEditing(true)
    }
    
    
    func moveViewWithKeyboard(notification: NSNotification, viewBottomConstraint: [NSLayoutConstraint?], keyboardWillShow: Bool) {
        // Tamaño del teclado
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        let keyboardHeight = keyboardSize.height
        
        // Duración de la animación del teclado
        let keyboardDuration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        
        // la curva de la animacion del teclado
        let keyboardCurve = UIView.AnimationCurve(rawValue: notification.userInfo![UIResponder.keyboardAnimationCurveUserInfoKey] as! Int)!
        
        for itemBottomConstraint in viewBottomConstraint{
            // cambiar la posicion de los objetos en la vista
            if keyboardWillShow {
                let safeAreaExists = (self.view?.window?.safeAreaInsets.bottom != 0) // comprobar si existe el safe area
                let bottomConstant: CGFloat = 20
                itemBottomConstraint!.constant = keyboardHeight + (safeAreaExists ? 0 : bottomConstant)
            }else {
                itemBottomConstraint!.constant = 20
            }
        }
        
        
        // La anmimacion de la vista ira a la par de la animacion del teclado
        let animator = UIViewPropertyAnimator(duration: keyboardDuration, curve: keyboardCurve) { [weak self] in
            // actualización de los constraints de los objetos
            self?.view.layoutIfNeeded()
        }
        
        // ejecutar la animacion
        animator.startAnimation()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return mensajes.count
    }
    
    //instanciador de celdas i contenidos
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        

        
        
        if mensajes[indexPath.row][0] == "e" {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "sendCell", for: indexPath) as! TableChatCell
            cell.textMessage.text = mensajes[indexPath.row][1]
            cell.textMessage.backgroundColor = UIColor.black
            cell.textMessage.textColor = UIColor.cyan
            cell.textMessage.layer.cornerRadius = 3
            cell.textMessage.layer.borderWidth = 1
            cell.textMessage.layer.borderColor = UIColor.cyan.cgColor
            cell.textArrow.tintColor = UIColor.cyan
            cell.textMessage.layer.masksToBounds = true
            return cell
        }else{
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "reciveCell", for: indexPath) as! TableChatCell

            cell.textMessage.text = mensajes[indexPath.row][1]
            cell.textMessage.backgroundColor = UIColor.black
            cell.textMessage.textColor = UIColor.magenta
            cell.textMessage.layer.cornerRadius = 3
            cell.textMessage.layer.borderWidth = 1
            cell.textMessage.layer.borderColor = UIColor.magenta.cgColor
            cell.textArrow.tintColor = UIColor.magenta
            cell.textMessage.layer.masksToBounds = true
            return cell
        }

    }
    
    //accion del botonenviar
    @IBAction func sendMessage(_ sender: Any) {
        if chatWriteBox.text!.isEmpty != true && chatWriteBox.text! != " " {
            let mensa = chatWriteBox.text!
           
            print("Full")
            chatWriteBox.text = ""
            mensajes.append(["e", mensa])
            print("\(mensajes)")
            tableView.reloadData()
            
            //codificacion para los espacios en blanco
            let swiftArtisanEncode = mensa.replacingOccurrences(of: " ", with: "%20")
            
            let url = URL(string:"https://test3.qastusoft.com.es/MiguelCarpio/push.php?TokenPush=\(userToken)&message=\(swiftArtisanEncode)")
            
            let task = URLSession.shared.dataTask(with: url!) { data, response, error in
                if let data = data {
                    print("HTTP Request Success \(response)")
                } else if let error = error {
                    print("HTTP Request Failed \(error)")
                }
            }

            task.resume()
            
        }else{
            print("Empty field")
        }
    }
    
    //eliminar mensajes al manterner pulsado y despues soltar
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("\(mensajes[indexPath.row]) was remove")
        mensajes.remove(at: indexPath.row)
        //tableView.deleteRows(at: [indexPath], with: .automatic)
        tableView.reloadData()
    }
    
}

