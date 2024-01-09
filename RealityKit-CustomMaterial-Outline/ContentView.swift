//
//  ContentView.swift
//  RealityKit-CustomMaterial-Outline
//
//  Created by fuziki on 2024/01/08.
//

import Combine
import RealityKit
import SwiftUI

struct ContentView : View {
    @State var gaming: Bool = true
    @State var width: Float = 0.8
    @State var beforeCameraRot: (yaw: Float, pitch: Float) = (yaw: 0, pitch: 0)
    @State var cameraRot: (yaw: Float, pitch: Float) = (yaw: 30 * .pi / 180, pitch: 30 * .pi / 180)

    var body: some View {
        ZStack(alignment: .bottom) {
            ARViewContainer(gaming: gaming, width: width, cameraRot: cameraRot)
                .edgesIgnoringSafeArea(.all)
                .gesture(DragGesture(minimumDistance: 0)
                    .onChanged { (value: DragGesture.Value) in
                        cameraRot = calcCameraRot(beforeCameraRot: beforeCameraRot, translation: value.translation)
                    }
                    .onEnded { (value: DragGesture.Value) in
                        cameraRot = calcCameraRot(beforeCameraRot: beforeCameraRot, translation: value.translation)
                        beforeCameraRot = cameraRot
                    }
                )
            VStack {
                Toggle("", isOn: $gaming)
                    .fixedSize(horizontal: true, vertical: false)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Slider(value: $width, in: 0.1...1)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 128)
        }
    }

    func calcCameraRot(beforeCameraRot: (yaw: Float, pitch: Float), translation: CGSize) -> (yaw: Float, pitch: Float) {
        (yaw: beforeCameraRot.yaw - Float(translation.width) * .pi / 180,
         pitch: min(max(beforeCameraRot.pitch + Float(translation.height) * .pi / 180, 0), .pi / 2))
    }
}
