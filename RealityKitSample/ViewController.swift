//
//  ViewController.swift
//  RealityKitSample
//
//  Created by Takeshi Tanaka on 2022/04/01.
//  Copyright © 2022 Goodpatch. All rights reserved.
    

import UIKit
import RealityKit

class ViewController: UIViewController {
    
    @IBOutlet var arView: ARView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load the "Box" scene from the "Experience" Reality File
        let boxAnchor = try! Experience.loadBox()
        
        // Add the box anchor to the scene
        arView.scene.anchors.append(boxAnchor)
    }
}
