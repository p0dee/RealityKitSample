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
        
        // 平面検知のアンカーを追加
        let planeAnchor = AnchorEntity(.plane(.horizontal, classification: .table, minimumBounds: .init(x: 0.1, y: 0.1)))
        arView.scene.addAnchor(planeAnchor)
        
        // モデルを追加
        let cubeMesh = MeshResource.generateBox(size: 0.025, cornerRadius: 0.025 * 0.05)
        var material = SimpleMaterial()
        material.metallic = .init(floatLiteral: 0.0)
        material.roughness = .init(floatLiteral: 0.05)
        material.color = .init(tint: .red, texture: nil)
        let cubeModel = ModelEntity(mesh: cubeMesh, materials: [material])
        planeAnchor.addChild(cubeModel)
        
        // モデルにジェスチャーを設定
        cubeModel.generateCollisionShapes(recursive: false)
        arView.installGestures(for: cubeModel)
        
        // モデルをタップ
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTap))
        tap.numberOfTouchesRequired = 1
        view.addGestureRecognizer(tap)
        
        // Component
        let sphereMesh = MeshResource.generateSphere(radius: 0.05)
        let sphereModel = ModelEntity(mesh: sphereMesh, materials: [material])
        planeAnchor.addChild(sphereModel)
        sphereModel.generateCollisionShapes(recursive: false)
        sphereModel.position = .init(x: 0, y: 0, z: 0.1)
        
        cubeModel.components[ModelKindComponent.self] = .init(kind: .cube)
        sphereModel.components[ModelKindComponent.self] = .init(kind: .sphere)
    }
    
    @objc func didTap(gest: UITapGestureRecognizer) {
        let loc = gest.location(in: arView)
        guard let entity = arView.entity(at: loc) as? ModelEntity else { return }
        var transform = Transform.identity
        transform.translation = .init(0, 0.01, 0)
//        entity.move(to: transform, relativeTo: entity, duration: 0.1)
        
        guard let kind = entity.kind else { return }
        switch kind {
        case .cube:
            entity.spin()
        case .sphere:
            entity.jiggle()
        }
    }
}

struct ModelKindComponent: Component, Codable {
    
    enum Kind: Codable {
        case cube, sphere
    }
    
    var kind: Kind
    
}

extension ModelEntity {
    
    var kind: ModelKindComponent.Kind? {
        guard let modelKindComponent = components[ModelKindComponent.self] as? ModelKindComponent else { return nil }
        return modelKindComponent.kind
    }
    
    func jiggle() {
        var transform = Transform.identity
        let scale: Float = 0.85
        transform.scale = .init(scale, scale, scale)
        move(to: transform, relativeTo: self, duration: 0.1)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let reversedScale: Float = 1 / self.transform.scale.x
            transform.scale = .init(reversedScale, reversedScale, reversedScale)
            self.move(to: transform, relativeTo: self, duration: 0.1)
        }
    }
    
    func spin() {
        let transform = Transform(pitch: 0, yaw: .pi, roll: 0)
        move(to: transform, relativeTo: self, duration: 0.3)
    }
    
}
