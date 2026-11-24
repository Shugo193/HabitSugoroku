//
//  ContentView.swift
//  HabitSugoroku
//
//  Created by asaishugo on 2026/11/16.
//

import SwiftUI
import RealityKit


func loadModel(name:String,lightSource:Entity)async throws->Entity{
    let entity = Entity()
    let model = try await Entity(named:name)
    entity.addChild(model)
    entity.components.set(ImageBasedLightReceiverComponent(imageBasedLight: lightSource))
    
    return entity
}


struct ContentView: View {
    var body: some View {
        RealityView{content in
            let nullEntity = Entity()
            nullEntity.components.set(ImageBasedLightComponent(source: .none))
            content.add(nullEntity)
            
            let mesh = MeshResource.generateBox(size: 0.04)
            let material = SimpleMaterial(color: .systemBlue, isMetallic: true)
            let boxEntity = ModelEntity(mesh: mesh, materials: [material])
            boxEntity.position = SIMD3<Float>(0,0.02,0)
            boxEntity.components.set(ImageBasedLightReceiverComponent(imageBasedLight: nullEntity))
            
            let planeMesh = MeshResource.generatePlane(width: 1, depth: 0.6)
            let planeMaterial = SimpleMaterial(color:.systemBrown,roughness:1.0,isMetallic: false)
            let planeEntity = ModelEntity(mesh: planeMesh,materials: [planeMaterial])
            planeEntity.position = [0,0,0]
            planeEntity.components.set(ImageBasedLightReceiverComponent(imageBasedLight: nullEntity))
            
            
            let camera = PerspectiveCamera()
            camera.position = [0.2,0.5,0.2]
            camera.camera.fieldOfViewInDegrees = 60
            camera.look(
                at:boxEntity.position,
                from: camera.position,
                relativeTo: nil)
            
            let spotlight = SpotLight()
            spotlight.light = SpotLightComponent(
                color: .white,
                intensity:10000
                ,
                innerAngleInDegrees: 20,
                outerAngleInDegrees:40,
                attenuationRadius: 5
            )
            spotlight.shadow = SpotLightComponent.Shadow()
            spotlight.look(at: boxEntity.position, from: [1,1,1], relativeTo: nil)
            
            content.add(boxEntity)
            content.add(planeEntity)
            content.add(camera)
            content.add(spotlight)
            
            do{
                let tileEntity = try  await loadModel(name: "testtile",lightSource: nullEntity)
                tileEntity.position = SIMD3<Float>(0.1,0,0.1)
                content.add(tileEntity)
                let piece8Entity = try await loadModel(name: "8-piece",  lightSource: nullEntity)
                printModelInfo(piece8Entity)
                piece8Entity.position = SIMD3<Float>(0,0.005,0)
                tileEntity.addChild(piece8Entity)
                let piece16Entity = try await loadModel(name: "16-piece", lightSource: nullEntity)
                printModelInfo(piece16Entity)
                piece16Entity .position = SIMD3<Float>(0.01,0.005,0)
                tileEntity.addChild(piece16Entity)
                let propEntity = try await loadModel(name: "prop",lightSource: nullEntity)
                propEntity.position = SIMD3<Float>(0,0.005,0.01)
                tileEntity.addChild(propEntity)
            }catch{
                print("Load error:\(error)")
            }

            
            
            content.camera = .virtual
            
            
        }
        .realityViewCameraControls(.orbit)
        .background(Color.black)
    }
}

#Preview {
    ContentView()
}
