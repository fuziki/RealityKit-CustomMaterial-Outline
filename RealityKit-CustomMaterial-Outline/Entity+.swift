//
//  Entity+.swift
//  RealityKit-CustomMaterial-Outline
//
//  Created by fuziki on 2024/01/09.
//

import Foundation
import RealityKit

extension Entity {
    func modifyMaterials(_ closure: (Material) throws -> Material) rethrows {
        try children.forEach { try $0.modifyMaterials(closure) }

        guard var comp = components[ModelComponent.self] as? ModelComponent else { return }
        comp.materials = try comp.materials.map { try closure($0) }
        components[ModelComponent.self] = comp
    }

    func setCustomVector(vector: SIMD4<Float>) {
        children.forEach { $0.setCustomVector(vector: vector) }

        guard var comp = components[ModelComponent.self] as? ModelComponent else { return }
        comp.materials = comp.materials.map { (material) -> Material in
            if var customMaterial = material as? CustomMaterial {
                customMaterial.custom.value = vector
                return customMaterial
            }
            return material
        }
        components[ModelComponent.self] = comp
    }
}
