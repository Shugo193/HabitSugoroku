//
//  ModelInspector.swift
//  HabitSugoroku
//
//  Created by asaishugo on 2026/11/22.
//

import Foundation
import RealityKit

#if DEBUG
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
#else

#endif
