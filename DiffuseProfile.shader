Shader "SSS/DiffuseProfile"
{
    Properties
    {
        _MaxRadiance("Max Radiance", float) = 1
        [KeywordEnum(NormDiff, G1, G2)] _Radiance ("Radiance Profile type", Float) = 0
        _D ("D", Vector) = (1,1,1,1)
        _DiffColor1 ("NormDiff Color 1", Color) = (1,1,1,1)
        _DiffColor2 ("NormDiff Color 2", Color) = (0,0,0,0)
        _DiffColor3 ("NormDiff Color 2", Color) = (0,0,0,0)
        _DiffColor4 ("NormDiff Color 2", Color) = (0,0,0,0)
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile _RADIANCE_NORMDIFF _RADIANCE_G1 _RADIANCE_G2

            #include "SSSCore.cginc"
            float _MaxRadiance;

            fixed4 frag (v2f i) : SV_Target
            {
                float2 distance = length(i.uv.xy - 0.5) * _MaxRadiance;
                fixed3 rgb = RadianceProfile(distance);
                return fixed4(rgb,1);
            }
            ENDCG
        }
    }
}
