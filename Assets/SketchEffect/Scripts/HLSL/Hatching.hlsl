
//This hatching function applies the hatch textures onto the object based on the UV and the camera distance

void Hatching_float(float2 _uv, float _intensity, float _dist, UnityTexture2D _Hatch0, UnityTexture2D _Hatch1, UnitySamplerState ss, out float3 hatching)
{
    float log2_dist = log2(_dist);
				
    float2 floored_log_dist = floor( (log2_dist + float2(0.0, 1.0) ) * 0.5) *2.0 - float2(0.0, 1.0);				
    float2 uv_scale = min(1, pow(2.0, floored_log_dist));
    
    //It blends between two samples of the texture, to allow for tiling the texture when you zoom in.
    float uv_blend = abs(frac(log2_dist * 0.5) * 2.0 - 1.0);
    
    

    float2 scaledUVA = _uv / uv_scale.x; // 16
    float2 scaledUVB = _uv / uv_scale.y; // 8 

    //sample the hatch textures based on the scaled UVs
    float3 hatch0A = SAMPLE_TEXTURE2D(_Hatch0, ss, scaledUVA).rgb;
    float3 hatch1A = SAMPLE_TEXTURE2D(_Hatch1, ss, scaledUVA).rgb;

    float3 hatch0B = SAMPLE_TEXTURE2D(_Hatch0, ss, scaledUVB).rgb;
    float3 hatch1B = SAMPLE_TEXTURE2D(_Hatch1, ss, scaledUVB).rgb;

    float3 hatch0 = lerp(hatch0A, hatch0B, uv_blend);
    float3 hatch1 = lerp(hatch1A, hatch1B, uv_blend);

    float3 overbright = max(0, _intensity - 1.0);

    //we apply weights to each of the six hatch textures that has been obtained 
    //from the dark and bright texture inputs
    float3 weightsA = saturate((_intensity * 6.0) + float3(-0, -1, -2));
    float3 weightsB = saturate((_intensity * 6.0) + float3(-3, -4, -5));

    weightsA.xy -= weightsA.yz;
    weightsA.z -= weightsB.x;
    weightsB.xy -= weightsB.yz;

    hatch0 = hatch0 * weightsA;
    hatch1 = hatch1 * weightsB;

    hatching = overbright + hatch0.r +
        hatch0.g + hatch0.b +
        hatch1.r + hatch1.g +
        hatch1.b;
}

// this is the simplified form of the above hatching function without the camera distance factor
void Hatching2_float(float2 _uv, float _intensity, UnityTexture2D _Hatch0, UnityTexture2D _Hatch1, UnitySamplerState ss, out float3 hatching)
{
    float3 hatch0 = SAMPLE_TEXTURE2D(_Hatch0, ss, _uv).rgb;
				float3 hatch1 = SAMPLE_TEXTURE2D(_Hatch1, ss, _uv).rgb;

				float3 overbright = max(0, _intensity - 1.0);

				float3 weightsA = saturate((_intensity * 6.0) + float3(-0, -1, -2));
				float3 weightsB = saturate((_intensity * 6.0) + float3(-3, -4, -5));

				weightsA.xy -= weightsA.yz;
				weightsA.z -= weightsB.x;
				weightsB.xy -= weightsB.yz;

				hatch0 = hatch0 * weightsA;
				hatch1 = hatch1 * weightsB;

				hatching = overbright + hatch0.r +
					hatch0.g + hatch0.b +
					hatch1.r + hatch1.g +
					hatch1.b;
}

