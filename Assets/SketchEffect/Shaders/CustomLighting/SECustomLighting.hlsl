// Sketch Effect Custom Lighting

// References: 
// https://nedmakesgames.medium.com/creating-custom-lighting-in-unitys-shader-graph-with-universal-render-pipeline-5ad442c27276
// https://github.com/Cyanilux/URP_ShaderGraphCustomLighting

#ifndef SE_CUSTOM_LIGHTING_INCLUDED
#define SE_CUSTOM_LIGHTING_INCLUDED

// This is a neat trick to work around a bug in the shader graph when
// enabling shadow keywords. Created by @cyanilux
// https://github.com/Cyanilux/URP_ShaderGraphCustomLighting
#ifndef SHADERGRAPH_PREVIEW
    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
    #if (SHADERPASS != SHADERPASS_FORWARD)
        #undef REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR
    #endif
#endif

struct CustomLightingData {
    // Position and orientation
    float3 positionWS;
    float3 normalWS;
    float3 viewDirectionWS;
    float4 shadowCoord;
    
    // Surface attributes
    float3 albedo;
    float smoothness;
    float metallic;
    float ambientOcclusion;

    // Baked lighting
    float3 bakedGI;
};

// Translate a [0, 1] smoothness value to an exponent 
float GetSmoothnessPower(float rawSmoothness) {
    return exp2(10 * rawSmoothness + 1);
}

#ifndef SHADERGRAPH_PREVIEW
float3 CustomGlobalIllumination(CustomLightingData d) {
    float3 indirectDiffuse = d.albedo * d.bakedGI * d.ambientOcclusion;

    return indirectDiffuse;
}

float3 CustomLightHandling(CustomLightingData d, Light light) {

    float3 radiance = light.color * (light.distanceAttenuation * light.shadowAttenuation);

    float diffuse = saturate(dot(d.normalWS, light.direction));
    float specularDot = saturate(dot(d.normalWS, normalize(light.direction + d.viewDirectionWS)));
    float specular = pow(specularDot, GetSmoothnessPower(d.smoothness)) * diffuse * d.metallic;

    float3 color = d.albedo * radiance * (diffuse + specular);

    return color;
}
#endif

float3 CalculateCustomLighting(CustomLightingData d) {
    #ifdef SHADERGRAPH_PREVIEW
        // In preview, estimate diffuse + specular
        float3 lightDir = float3(0.5, 0.5, 0);
        float intensity = saturate(dot(d.normalWS, lightDir)) +
            pow(saturate(dot(d.normalWS, normalize(d.viewDirectionWS + lightDir))), GetSmoothnessPower(d.smoothness));
        return d.albedo * intensity;
    #else
        // Get the main light. Located in URP/ShaderLibrary/Lighting.hlsl
        Light mainLight = GetMainLight(d.shadowCoord, d.positionWS, 1);
        // In mixed subtractive baked lights, the main light must be subtracted
        // from the bakedGI value. This function in URP/ShaderLibrary/Lighting.hlsl takes care of that.
        MixRealtimeAndBakedGI(mainLight, d.normalWS, d.bakedGI);
        float3 color = CustomGlobalIllumination(d);
        // Shade the main light
        color += CustomLightHandling(d, mainLight); 

         #ifdef _ADDITIONAL_LIGHTS
            // Shade additional cone and point lights. Functions in URP/ShaderLibrary/Lighting.hlsl
            uint numAdditionalLights = GetAdditionalLightsCount();
            for (uint lightI = 0; lightI < numAdditionalLights; lightI++) {
                Light light = GetAdditionalLight(lightI, d.positionWS, 1);
                color += CustomLightHandling(d, light);
            }
        #endif

        return color;
    #endif
}

void CalculateCustomLighting_float(float3 Position, float3 Normal, float3 ViewDirection, float3 Albedo, float Smoothness, float Metallic,
    float AmbientOcclusion, float2 LightmapUV, out float3 Color) {

    CustomLightingData d;
    d.positionWS = Position;
    d.normalWS = Normal;
    d.viewDirectionWS = ViewDirection;
    d.albedo = Albedo;
    d.smoothness = Smoothness;
    d.metallic = Metallic;
    d.ambientOcclusion = AmbientOcclusion;

    #ifdef SHADERGRAPH_PREVIEW
        // In preview, there's no shadows or bakedGI
        d.shadowCoord = 0;
        d.bakedGI = 0;
    #else
        // Calculate the main light shadow coord
        // There are two types depending on if cascades are enabled
        float4 positionCS = TransformWorldToHClip(Position);
        #if SHADOWS_SCREEN
            d.shadowCoord = ComputeScreenPos(positionCS);
        #else
            d.shadowCoord = TransformWorldToShadowCoord(Position);
        #endif

        // The lightmap UV is usually in TEXCOORD1
        // If lightmaps are disabled, OUTPUT_LIGHTMAP_UV does nothing
        float2 lightmapUV;
        OUTPUT_LIGHTMAP_UV(LightmapUV, unity_LightmapST, lightmapUV);
        // Samples spherical harmonics, which encode light probe data
        float3 vertexSH;
        OUTPUT_SH(Normal, vertexSH);
        // This function calculates the final baked lighting from light maps or probes
        d.bakedGI = SAMPLE_GI(lightmapUV, vertexSH, Normal);
    #endif

    Color = CalculateCustomLighting(d);
}

#endif