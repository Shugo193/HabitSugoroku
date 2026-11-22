//
//  ContentView.swift
//  HabitSugoroku
//
//  Created by asaishugo on 2026/11/16.
//

import SwiftUI
import RealityKit

struct ContentView: View {
    var body: some View {
        RealityView{content in
            let nullEntity = Entity()
            content.add(nullEntity)
            
            nullEntity.components.set(ImageBasedLightComponent(source: .none))
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
            content.camera = .virtual
            
            
        }
        .realityViewCameraControls(.orbit)
        .background(Color.black)
    }
}

#Preview {
    ContentView()
}
