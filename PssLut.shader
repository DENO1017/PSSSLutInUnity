Shader "SSS/PssLut"
{
    Properties
    {
        _Max1R("Max 1/Radiance", float) = 1
        _Test("Test", Range(-3,3)) = 0
        [KeywordEnum(NormDiff, G1, G2)] _Radiance ("Radiance Profile type", Float) = 0
        _D ("D", Vector) = (1,1,1,1)
        _DiffColor1 ("NormDiff Color 1", Color) = (1,1,1,1)
        _DiffColor2 ("NormDiff Color 2", Color) = (0,0,0,0)
        _DiffColor3 ("NormDiff Color 2", Color) = (0,0,0,0)
        _DiffColor4 ("NormDiff Color 2", Color) = (0,0,0,0)
        [KeywordEnum(None, Uncharted, ACES)] _Tone ("Tone type", Float) = 0
        _AdaptedLum ("Uncharted-AdaptedLum", float) = 1
        [Toggle] _Gamma ("Gamma", Float) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #pragma shader_feature _GAMMA_ON
            #pragma multi_compile _RADIANCE_NORMDIFF _RADIANCE_G1 _RADIANCE_G2
            #pragma multi_compile _TONE_NONE _TONE_UNCHARTED _TONE_ACES
            #include "SSSCore.cginc"
            float _Max1R;
            float _AdaptedLum;
            float _Test;


            float3 F(float3 x)
            {
                float A = 0.15;
                float B = 0.50;
                float C = 0.10;
                float D = 0.20;
                float E = 0.02;
                float F = 0.30;

                return ((x * ( A * x + C * B) + D * E) / (x * (A * x + B) + D * F)) - E/F;
            }

            float3 Uncharted2ToneMapping(float3 color)
            {
                const float WHITE = 11.2f;
                return F(1.6f * _AdaptedLum * color) / F(WHITE);
            }

            float3 ACESToneMapping(float3 x)
            {
                float a = 2.51f;
                float b = 0.03f;
                float c = 2.43f;
                float d = 0.59f;
                float e = 0.14f;
                return saturate((x*(a*x+b))/(x*(c*x+d)+e));
            }

            float3 IntegrateDiffuseScatteringOnRing(float uvx,float Radius)
            {
                float theta =acos(uvx);
                float a = 0;
                float b = 0;
                float3 totalWeights = float3(0,0,0);
                float3 totalLight = float3(0,0,0);
                while(b <= 0.5 * PI)
                {
                    a = 0;
                    while (a <= 2 * PI)
                    {
                        // float sampleDist = 2 * Radius * sin(0.5 * a);
                        float sampleDist = sqrt(2 - 2 * cos(a) * cos(b)) * Radius;
                        
                        // float diffuse = saturate(cos(theta + a));
                        float diffuse = saturate(cos(b) * cos(theta + a));

                        float3 weight = RadianceProfile(sampleDist);
                        totalLight += diffuse * weight;
                        totalWeights += weight;
                        a += 0.05;
                    }
                    b += 0.05;
                }
                totalLight *= 2;
                #if _TONE_UNCHARTED
                    float3 rgb = Uncharted2ToneMapping(totalLight/totalWeights);
                #elif _TONE_ACES
                    float3 rgb = ACESToneMapping(totalLight/totalWeights);
                #else
                    float3 rgb = totalLight/totalWeights;
                #endif

                #if _GAMMA_ON
                    rgb = pow(rgb, 1/2.2);//转换到Gamma空间
                #endif
                return rgb;
            }
            fixed4 frag (v2f i) : SV_Target
            {
                float radians = 1.0/((i.uv.y * _Max1R+0.0001));

                float3 rgb = IntegrateDiffuseScatteringOnRing(lerp(-1,1,i.uv.x),radians);
                return float4(rgb,1);
            }
            ENDCG
        }
    }
}