//
//  AddEditViewController.swift
//  Carangas
//
//  Created by Eric Brito.
//  Copyright © 2017 Eric Brito. All rights reserved.
//

import UIKit

class AddEditViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var tfBrand: UITextField!
    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var tfPrice: UITextField!
    @IBOutlet weak var scGasType: UISegmentedControl!
    @IBOutlet weak var btAddEdit: UIButton!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    
    
    var car: Car!

    // MARK: - Super Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        if car != nil{
            tfBrand.text = car.brand
            tfName.text = car.name
            tfPrice.text = "\(car.price)"
            scGasType.selectedSegmentIndex = car.gasType
            btAddEdit.setTitle("Alterar carro", for: .normal)
        }
        
    }
    
    // MARK: - IBActions
    @IBAction func addEdit(_ sender: UIButton) {
        if car == nil{
            car = Car()
        }
        car.name = tfName.text!
        car.brand = tfBrand.text!
        if tfPrice.text!.isEmpty{tfPrice.text = "0 "
            car.price = Double(tfPrice.text!)!            
        }
        car.gasType = scGasType.selectedSegmentIndex
        

        if car._id == nil{
            REST.save(car: car) { (success) in
                self.goBack()
            }
        }else{
            REST.update(car: car, onComplete: { (success) in
                self.goBack()
                    
                })
            }
        }
    func goBack(){
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }
}








