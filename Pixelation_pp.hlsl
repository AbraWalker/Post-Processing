#include "Common.hlsli"

Texture2D SceneTexture : register(t0);
SamplerState PointSample : register(s0);

float4 main(PostProcessingInput input) : SV_TARGET
{
    
    //float pixels = 512.0; //1024 or 512
    float dx = 10 * (1.0 / gViewportWidth);
    float dy = 10 * (1.0 / gViewportHeight);
    float2 coord = float2(dx * floor(input.sceneUV.x / dx), dy * floor(input.sceneUV.y / dy));
  
    float3 scene = SceneTexture.Sample(PointSample, coord);
    
    return float4(scene,1.0f);
}