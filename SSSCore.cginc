#include "UnityCG.cginc"

float4 _D;
half4 _DiffColor1;
half4 _DiffColor2;
half4 _DiffColor3;
half4 _DiffColor4;
#define PI 3.141592654

struct appdata
{
    float4 vertex : POSITION;
    float2 uv : TEXCOORD0;
};

struct v2f
{
    float2 uv : TEXCOORD0;
    float4 vertex : SV_POSITION;
};
v2f vert (appdata v)
{
    v2f o;
    o.vertex = UnityObjectToClipPos(v.vertex);
    o.uv = v.uv;
    return o;
}

float G1(float Neg_r_2, float v)
{
    v =  1.414 * v;
    return 1.0/ sqrt(2.0 * PI * v) * exp(Neg_r_2 / (2 * v));
}


float G2(float Neg_r_2, float v)
{
    return 1.0/(2.0 * PI * v) * exp(Neg_r_2 / (2 * v));
}

float G(float Neg_r_2, float v)
{
    #if _RADIANCE_G1
        return G1(Neg_r_2,v);
    #else 
        return G2(Neg_r_2,v);
    #endif
}

float3 CalcGuss(float distance)
{
    float Neg_r_2 = -distance*distance;
    float3 rgb = float3(0.233,0.455,0.649) * G(Neg_r_2 , 0.0064)+\
        float3(0.100,0.336,0.344) * G(Neg_r_2 , 0.0484)+\
        float3(0.118,0.198,0.000) * G(Neg_r_2 , 0.1870)+\
        float3(0.113,0.007,0.007) * G(Neg_r_2 , 0.5670)+\
        float3(0.358,0.004,0.000) * G(Neg_r_2 , 1.9900)+\
        float3(0.078,0.000,0.000) * G(Neg_r_2 , 7.4100);
    return rgb;
}

float NormDiff(float r, float d)
{
    return (exp(-r/d) + exp(-r/(3 * d)) / (8 * PI * d * r));
}

float3 CalcNorm(float distance)
{
    float3 rgb = float3(0,0,0);
    // half sum = 1 / (_DiffColor1.a + _DiffColor2.a + _DiffColor3.a + _DiffColor4.a);
    half sum = 1;
    rgb += NormDiff(distance,_D.x) * _DiffColor1.rgb *  _DiffColor1.a * sum;
    rgb += NormDiff(distance,_D.y) * _DiffColor2.rgb *  _DiffColor2.a * sum;
    rgb += NormDiff(distance,_D.z) * _DiffColor3.rgb *  _DiffColor3.a * sum;
    rgb += NormDiff(distance,_D.w) * _DiffColor4.rgb *  _DiffColor4.a * sum;
    return rgb;
}

float3 RadianceProfile(float distance)
{
    #if _RADIANCE_NORMDIFF
        return CalcNorm(distance);
    #else
        return CalcGuss(distance);
    #endif
}