//
//  ContentView.swift
//  HabitSugoroku
//
//  Created by asaishugo on 2026/11/16.
//

import SwiftUI
import RealityKit

func printModelInfo(_ entity: Entity) {
    if let model = entity.components[ModelComponent.self] {
        print("===== \(entity.name) =====")

        // メッシュ
        let mesh = model.mesh
        print("bounds:", mesh.bounds.extents, "center:", mesh.bounds.center)
        for m in mesh.contents.models {
            print("model:", m.id)
            for part in m.parts {
                print("  part:", part.id,
                      "| materialIndex:", part.materialIndex,
                      "| 頂点:", part.positions.count,
                      "| 三角形:", (part.triangleIndices?.count ?? 0) / 3,
                      "| 法線:", part.normals != nil,
                      "| UV:", part.textureCoordinates != nil)
            }
        }

        // マテリアル
        print("materials:", model.materials.count)
        for (i, mat) in model.materials.enumerated() {
            print("[\(i)]", type(of: mat))

            if let pbr = mat as? PhysicallyBasedMaterial {
                print("  baseColor:", pbr.baseColor.tint, texInfo(pbr.baseColor.texture))
                print("  roughness:", pbr.roughness.scale, texInfo(pbr.roughness.texture))
                print("  metallic:", pbr.metallic.scale, texInfo(pbr.metallic.texture))
                print("  normal:", texInfo(pbr.normal.texture))
                print("  emissive:", pbr.emissiveColor.color, "強さ:", pbr.emissiveIntensity, texInfo(pbr.emissiveColor.texture))
                print("  blending:", pbr.blending)
                print("  faceCulling:", pbr.faceCulling)
            } else if let unlit = mat as? UnlitMaterial {
                print("  color:", unlit.color.tint, texInfo(unlit.color.texture))
            } else if let sg = mat as? ShaderGraphMaterial {
                print("  name:", sg.name)
                print("  params:", sg.parameterNames)
            }
        }
    }

    for child in entity.children {
        printModelInfo(child)
    }
}

func texInfo(_ tex: MaterialParameters.Texture?) -> String {
    guard let tex else { return "(テクスチャなし)" }
    return "(テクスチャ \(tex.resource.width)x\(tex.resource.height))"
}



struct ContentView: View {
    var body: some View {
        RealityView{content in
            let nullEntity = Entity()
            nullEntity.components.set(ImageBasedLightComponent(source: .none))
            content.add(nullEntity)
            
            do{let tile = try await Entity(named:"testtile")
                tile.position = SIMD3<Float>(0.04,0,0)
                content.add(tile)
                
                printModelInfo(tile)
                
            }catch{
                print("Load error:\(error)")
            }
        
            
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
