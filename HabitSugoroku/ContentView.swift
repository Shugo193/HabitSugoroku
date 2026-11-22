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
            
            let tileEntity = Entity()
            do{let tile = try await Entity(named:"testtile")
                tileEntity.addChild(tile)
                tileEntity.position = boxEntity.position + SIMD3<Float>(0.04,0,0)
                tileEntity.components.set(ImageBasedLightReceiverComponent(imageBasedLight: nullEntity))
                content.add(tileEntity)
                
            }catch{
                print("Load error:\(error)")
            }
            let piece8Entity = Entity()
            do{let tile = try await Entity(named:"8-piece")
                piece8Entity.addChild(tile)
                piece8Entity.position = tileEntity.position + SIMD3<Float>(0.04,0,0)
                piece8Entity.components.set(ImageBasedLightReceiverComponent(imageBasedLight: nullEntity))
                content.add(piece8Entity)
                
            }catch{
                print("Load error:\(error)")
            }
            
            let piece16Entity = Entity()
            do{let tile = try await Entity(named:"16-piece")
                piece16Entity.addChild(tile)
                piece16Entity.position = piece8Entity.position + SIMD3<Float>(0.04,0,0)
                piece16Entity.components.set(ImageBasedLightReceiverComponent(imageBasedLight: nullEntity))
                content.add(piece16Entity)
                
            }catch{
                print("Load error:\(error)")
            }
            
            let propEntity = Entity()
            do{let tile = try await Entity(named:"prop")
                propEntity.addChild(tile)
                propEntity.position = piece16Entity.position +  SIMD3<Float>(0.04,0,0)
                propEntity.components.set(ImageBasedLightReceiverComponent(imageBasedLight: nullEntity))
                content.add(propEntity)
                
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
