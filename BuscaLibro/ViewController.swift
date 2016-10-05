//
//  ViewController.swift
//  BuscaLibro
//
//  Created by Francisco Ulises Roldan Trejo on 25/09/16.
//  Copyright © 2016 Francisco Ulises Roldan Trejo. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

    
    @IBOutlet weak var lblTitulo: UILabel!
    @IBOutlet weak var lblAutores: UILabel!
    @IBOutlet weak var pvPortada: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        var vTexto = ""
        self.view.endEditing(true)
        vTexto = textField.text!
        let resConsulta:Array = (fnTraeDatLibro(vTexto))
        lblTitulo.text = resConsulta[0]
        lblAutores.text = "Autor(es): " + resConsulta[1]
        if resConsulta[2] != "" {
            if let url = URL(string: resConsulta[2]) {
                if let data = try? Data(contentsOf: url) {
                    pvPortada.image = UIImage(data: data)
                }
            }
        }else{
           //No se cuenta con la portada de este libro
           pvPortada.image = nil
        }
        
        
        //txtResConsulta.text = (fnTraeDatLibro(vTexto))
        return true
        
    }
    
    func fnTraeDatLibro(_ pTexto : String) -> [String] {
        var vRetorno : String = ""
        var vautores : String! = ""
        var urlPorts : String! = ""
        var vTitulo: String! = ""
        let vText = pTexto
        let urls =  "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:" + vText
        let url = URL(string: urls)
        //var dicoPortadas:NSDictionary! = nil
        
        if Reachability.isConnectedToNetwork() == true {
           let datos:Data? = try? Data(contentsOf: url!)
           do {
               let json = try JSONSerialization.jsonObject(with: datos!, options: JSONSerialization.ReadingOptions.mutableLeaves)
               let dico1 = json as! NSDictionary
               if  (json as AnyObject).count != 0 {
                   let dico2 = dico1["ISBN:"+vText] as? NSDictionary
                
                    //vTitulo = dico2!["title"] as! NSString as String
                    
                
                   vTitulo = dico2!["title"] as? String
                    
                   if let dicoAutores = dico2!["authors"] as? [AnyObject] {
                
                      for autores in dicoAutores {
                          if (vautores != "") {
                             vautores=vautores+","+String(describing: autores["name"]!!)
                          }else{
                             vautores = String(describing: autores["name"]!!)
                          }
                      }
                   }
                   do  {
                      if let dicoPortadas = dico2?["cover"] as? NSDictionary {
                       //urlPorts = String(dicoPortadas["medium"]!)
                         urlPorts = dicoPortadas["medium"] as? String
                      }else{
                         urlPorts = ""
                      }
                   }
               }else{
                   vTitulo = "No localizado"
               }
           }catch _ {
           }
            
            //vRetorno = vTitulo
            
        }else{
            fnMuestraAlerta()
            vRetorno = "Vuelva a intentarlo por favor!"
        }
        
        if vRetorno == "{}"{
           vRetorno = "No se encontró el registro con este ISBN. Vuleva a intentarlo!"
        }
        if (vautores == ""){
            vautores = " No se localizaron"
        }

        return ([vTitulo,vautores,urlPorts])
    }
    
    
    
    func fnMuestraAlerta() -> Void {
        let alertaDos = UIAlertController(title: "Verificación de red", message: "En este momento no se encuentra disponible el acceso a Internet, por favor inténtalo más tarde.", preferredStyle: UIAlertControllerStyle.alert)
        
        //Ahora es mucho mas sencillo, y podemos añadir nuevos botones y usar handler para capturar el botón seleccionado y hacer algo.
        
        alertaDos.addAction(UIAlertAction(title: "Salir" , style: UIAlertActionStyle.cancel ,handler: {alerAction in
            print("Pulsado el boton de Salir")}))
        
        //Para hacer que la alerta se muestre usamos presentViewController, a diferencia de Objective C que como recordaremos se usa [Show Alerta]
        
        self.present(alertaDos, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    

}

