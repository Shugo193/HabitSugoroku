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
            let mesh = MeshResource.generateBox(size: 0.04)
            let material = SimpleMaterial(color: .systemBlue, isMetallic: true)
            let boxEntity = ModelEntity(mesh: mesh, materials: [material])
            boxEntity.position = SIMD3<Float>(0,0,-0.5)
            content.add(boxEntity)
        }
        .realityViewCameraControls(.orbit)

    }
}

#Preview {
    ContentView()
}
