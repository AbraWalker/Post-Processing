//--------------------------------------------------------------------------------------
// Colour Tint Post-Processing Pixel Shader
//--------------------------------------------------------------------------------------
// Just samples a pixel from the scene texture and multiplies it by a fixed colour to tint the scene

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

// Post-processing shader that tints the scene texture to a given colour
float4 main(PostProcessingInput input) : SV_Target
{
 
    const float offset[] = { 0.0, 1.0, 2.0, 3.0, 4.0 };
    const float weight[] = { 0.2270270270, 0.1945945946, 0.1216216216, 0.0540540541, 0.0162162162 };
    float3 ppColour = SceneTexture.Sample(PointSample, input.uv) * weight[0];
    float3 FragmentColor = float3(0.0f, 0.0f, 0.0f);
	
	
    float hstep = 1 / gViewportHeight * 5;
    float vstep = 1 / gViewportWidth * 5;
	
    for (int i = 1; i < 5; i++)
    {
        FragmentColor +=
        SceneTexture.Sample(PointSample, input.uv + float2(hstep * offset[i], vstep * offset[i])) * weight[i] +
        SceneTexture.Sample(PointSample, input.uv - float2(hstep * offset[i], vstep * offset[i])) * weight[i];

    }
    ppColour += FragmentColor;
    return float4(ppColour, 1.0);
