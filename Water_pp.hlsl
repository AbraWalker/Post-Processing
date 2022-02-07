#include "Common.hlsli"

//--------------------------------------------------------------------------------------
// Textures (texture maps)
//--------------------------------------------------------------------------------------

// The scene has been rendered to a texture, these variables allow access to that texture
Texture2D SceneTexture : register(t0);
SamplerState PointSample : register(s0); // We don't usually want to filter (bilinear, trilinear etc.) the scene texture when
										  // post-processing so this sampler will use "point sampling" - no filtering


//--------------------------------------------------------------------------------------
// Shader code
//--------------------------------------------------------------------------------------

float4 main(PostProcessingInput input) : SV_Target
{
    const float EffectStrength = 0.02f;
    float ppAlpha = 1.0f;

// Haze is a combination of sine waves in x and y dimensions
    float SinX = sin(input.sceneUV.x * radians(1440.0f) + gWaterLevel);
    float SinY = sin(input.sceneUV.y * radians(3600.0f) + gWaterLevel * 0.7f);

// Offset for scene texture UV based on haze effect
// Adjust size of UV offset based on the constant EffectStrength, the overall size of area being processed, and the alpha value calculated above
    float2 hazeOffset = float2(SinY, SinX) * EffectStrength * ppAlpha;

// Get pixel from scene texture, offset using haze
    float ppColour = SceneTexture.Sample(PointSample, input.sceneUV + hazeOffset).b;

// Adjust alpha on a sine wave - better to have it nearer to 1.0 (but don't allow it to exceed 1.0)
    ppAlpha *= saturate(SinX * SinY * 0.33f + 0.55f);

    return float4(0, 0, ppColour, ppAlpha);
}