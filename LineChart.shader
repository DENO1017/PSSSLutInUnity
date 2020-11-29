Shader "SSS/LineChart"
{
    Properties
    {
        _LineWidth ("Line Width", Range(0.001,0.1)) = 0.001
        _Axis ("AxisXY", Vector) = (1,1,1,1)
        [KeywordEnum(NormDiff, G1, G2)] _Radiance ("Radiance Profile type", Float) = 0
        _D ("D", Vector) = (1,1,1,1)
        _DiffColor1 ("NormDiff Color 1", Color) = (1,1,1,1)
        _DiffColor2 ("NormDiff Color 2", Color) = (0,0,0,0)
        _DiffColor3 ("NormDiff Color 2", Color) = (0,0,0,0)
        _DiffColor4 ("NormDiff Color 2", Color) = (0,0,0,0)
    }
    SubShader
    {
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile _RADIANCE_NORMDIFF _RADIANCE_G1 _RADIANCE_G2

            #include "SSSCore.cginc"
            float _LineWidth;
            float4 _Axis;


            fixed4 frag (v2f i) : SV_Target
            {
                float2 axis = i.uv.xy * _Axis.xy;
                fixed3 rgb = RadianceProfile(axis.x);
                rgb = _LineWidth / abs(axis.x * rgb / axis.y - 1) / i.uv.y;
                return fixed4(rgb,1);
            }
            ENDCG
        }
    }
}
