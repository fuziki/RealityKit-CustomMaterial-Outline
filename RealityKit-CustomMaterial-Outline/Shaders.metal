//
//  Shaders.metal
//  RealityKit-CustomMaterial-Outline
//
//  Created by fuziki on 2024/01/08.
//

#include <metal_stdlib>
#include <RealityKit/RealityKit.h>
using namespace metal;

[[visible]]
void geometryShader(realitykit::geometry_parameters params) {
    float3 norm = params.geometry().normal();

    params.geometry().set_model_position_offset(norm * params.uniforms().custom_parameter().w);
    params.geometry().set_normal(-norm);
}

half3 hue2Rgba(half h) {
    half hueDeg = h * 360.0;
    half x = (1 - abs(fmod(hueDeg / 60.0, 2) - 1));
    half3 rgba;
    if (hueDeg < 60) rgba = half3(1, x, 0);
    else if (hueDeg < 120) rgba = half3(x, 1, 0);
    else if (hueDeg < 180) rgba = half3(0, 1, x);
    else if (hueDeg < 240) rgba = half3(0, x, 1);
    else if ( hueDeg < 300) rgba = half3(x, 0, 1);
    else rgba = half3(1, 0, x);
    return rgba;
}

[[visible]]
void surfaceShader(realitykit::surface_parameters params) {
    auto cp = params.uniforms().custom_parameter();
    float4 position = params.geometry().screen_position();
    params.surface().set_base_color(cp.x > 0.5 ? hue2Rgba(position.x / 2000 + cp.y) : half3());
    params.surface().set_ambient_occlusion(cp.x > 0.5 ? 1 : 0);
}
