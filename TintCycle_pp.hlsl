#include "Common.hlsli"


//--------------------------------------------------------------------------------------
// Textures (texture maps)
//--------------------------------------------------------------------------------------

// The scene has been rendered to a texture, these variables allow access to that texture
Texture2D    SceneTexture : register(t0);
SamplerState PointSample  : register(s0); // We don't usually want to filter (bilinear, trilinear etc.) the scene texture when
                                          // post-processing so this sampler will use "point sampling" - no filtering

//conversion taken from http://chilliant.blogspot.com/2010/11/rgbhsv-in-hlsl.html

float3 HSVtoRGB(float3 HSV)
{
    float3 RGB = 0;
    float C = HSV.z * HSV.y;
    float H = HSV.x * 6;
    float X = C * (1 - abs(fmod(H, 2) - 1));
    if (HSV.y != 0)
    {
        float I = floor(H);
        if (I == 0) { RGB = float3(C, X, 0); }
        else if (I == 1) { RGB = float3(X, C, 0); }
        else if (I == 2) { RGB = float3(0, C, X); }
        else if (I == 3) { RGB = float3(0, X, C); }
        else if (I == 4) { RGB = float3(X, 0, C); }
        else { RGB = float3(C, 0, X); }
    }
    float M = HSV.z - C;
    return RGB + M;
}

float3 RGBtoHSV(float3 RGB)
{
    float3 HSV = 0;
    float M = min(RGB.r, min(RGB.g, RGB.b));
    HSV.z = max(RGB.r, max(RGB.g, RGB.b));
    float C = HSV.z - M;
    if (C != 0)
    {
        HSV.y = C / HSV.z;
        float3 D = (((HSV.z - RGB) / 6) + (C / 2)) / C;
        if (RGB.r == HSV.z)
            HSV.x = D.b - D.g;
        else if (RGB.g == HSV.z)
            HSV.x = (1.0 / 3.0) + D.r - D.b;
        else if (RGB.b == HSV.z)
            HSV.x = (2.0 / 3.0) + D.g - D.r;
        if (HSV.x < 0.0) { HSV.x += 1.0; }
        if (HSV.x > 1.0) { HSV.x -= 1.0; }
    }
    return HSV;
}


float4 main(PostProcessingInput input) : SV_Target
{
    float3 colour1 = { 0.5f, 1.0f, 0.3f };
    float3 colour2 = { 0.7f, 0.5f, 0.2f };
    float3 col1 = RGBtoHSV(colour1);
    float3 col2 = RGBtoHSV(colour2);
    col1.r = 1 * gTintMod;
    col2.r = 1 * gTint2Mod;
    col1 = HSVtoRGB(col1);
    col2 = HSVtoRGB(col2);

    float3 colour = lerp(col1, col2, input.sceneUV.y);
    
    //Sanple a pixel from the scene...
    float3 tintColour = SceneTexture.Sample(PointSample, input.sceneUV).rgb * colour;

    //Softened circle
    float softEdge = 0.10f;
    float2 centreVector = input.areaUV - float2(0.5f, 0.5f);
    float centreLengthSq = dot(centreVector, centreVector);
    float alpha = 1.0f - saturate((centreLengthSq - 0.25f + softEdge) / softEdge);

    return float4(tintColour, alpha);

}