//
//  ARViewContainer.swift
//  RealityKit-CustomMaterial-Outline
//
//  Created by fuziki on 2024/01/09.
//

import Combine
import Foundation
import RealityKit
import SwiftUI

struct ARViewContainer: UIViewRepresentable {
    let gaming: Bool
    let width: Float
    let cameraRot: (yaw: Float, pitch: Float)

    // MARK: UIViewRepresentable
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero, cameraMode: .nonAR, automaticallyConfigureSession: false)
        context.coordinator.setup(arView: arView)
        context.coordinator.update(gaming: gaming, width: width, cameraRot: cameraRot)
        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {
        context.coordinator.update(gaming: gaming, width: width, cameraRot: cameraRot)
    }
}

extension ARViewContainer {
    class Coordinator {
        var arView: ARView!

        let camera = PerspectiveCamera()
        let cameraAnchor = AnchorEntity(world: .init(0, 70, 0))

        var targetPlayerRot: Float = 0
        var plane: Entity!
        var clone: Entity!
        var customMaterials: [CustomMaterial] = []

        var gaming: Bool = false
        var width: Float = 0.1
        let l: Float = 0.8
        var cameraRot: (yaw: Float, pitch: Float) = (yaw: 0, pitch: 0)

        var cancellables: Set<AnyCancellable> = []

        var offset: Int = 0

        // MARK: - Inputs
        func setup(arView: ARView) {
            self.arView = arView

            let scene = try! Projects.loadOutline()

            plane = scene.plane!

            let device = MTLCreateSystemDefaultDevice()!
            let library = device.makeDefaultLibrary()!
            let surfaceShader = CustomMaterial.SurfaceShader(named: "surfaceShader", in: library)
            let geometryShader = CustomMaterial.GeometryModifier(named: "geometryShader", in: library)
            clone = plane.clone(recursive: true)
            clone.modifyMaterials { original in
                var mat = try! CustomMaterial(from: original, surfaceShader: surfaceShader, geometryModifier: geometryShader)
                mat.faceCulling = .front
                customMaterials.append(mat)
                return mat
            }
            plane.addChild(clone)

            let newAnchor = AnchorEntity(world: .zero)
            newAnchor.addChild(scene)
            arView.scene.addAnchor(newAnchor)

            setupSkybox()
            setupLight()
            setupCamera()

            arView.scene
                .publisher(for:  SceneEvents.Update.self)
                .sink { [weak self] (_: SceneEvents.Update) in
                    self?.updateCamera()
                }
                .store(in: &cancellables)
        }

        func update(gaming: Bool, width: Float, cameraRot: (yaw: Float, pitch: Float)) {
            self.gaming = gaming
            self.width = width
            self.cameraRot = cameraRot
        }

        // MARK: - Skybox
        func setupSkybox() {
            // https://developer.apple.com/documentation/realitykit/environmentresource
            let skybox = try! EnvironmentResource.load(named: "alps_field_1k")
            arView.environment.background = .skybox(skybox)
        }

        // MARK: - Light
        func setupLight() {
            let directionalLight = DirectionalLight()
            directionalLight.light.color = .white
            directionalLight.light.intensity = 5000
            directionalLight.shadow?.maximumDistance = 5
            directionalLight.shadow?.depthBias = 5
            let lightAnchor = AnchorEntity(world: .zero)
            lightAnchor.position = .init(x: 0, y: 20, z: 5)
            directionalLight.look(at: .zero, from: lightAnchor.position, relativeTo: nil)
            lightAnchor.addChild(directionalLight)
            arView.scene.addAnchor(lightAnchor)
        }

        // MARK: - Camera
        func setupCamera() {
            camera.camera.fieldOfViewInDegrees = 60
            cameraAnchor.addChild(camera)
            arView.scene.addAnchor(cameraAnchor)
            updateCamera()
        }

        func updateCamera() {
            cameraAnchor.position = plane.position + .init(x: l * sin(cameraRot.yaw) * cos(cameraRot.pitch),
                                                           y: l * sin(cameraRot.pitch),
                                                           z: l * cos(cameraRot.yaw) * cos(cameraRot.pitch))
            camera.look(at: plane.position,
                        from: cameraAnchor.position,
                        relativeTo: nil)

            offset += 1
            offset %= 30
            clone.setCustomVector(vector: .init(x: gaming ? 1 : 0, y: Float(offset) / 30, z: 0, w: width))
        }
    }
}
