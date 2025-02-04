﻿Shader "Sample/ColoredLight"
{
    Properties
    {
        _MainColor ("Main Color", Color) = (1, 1, 1, 1)
    }

    SubShader
    {
        Pass
        {
            Tags
            {
                "LightMode" = "ForwardBase"
            }

            CGPROGRAM

            #pragma vertex   vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD0;
            };

            float4 _MainColor;

            v2f vert(appdata_base v)
            {
                v2f o;

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // 新たに出力に_LightColor0が乗算されている
                // _LightColor0にはIntencityパラメータのが乗算されているため、乗算によって反射する光
                // を求める手法は現実の光の挙動とは異なる点に注意

                float3 normal = normalize(i.normal);
                float3 light  = normalize(_WorldSpaceLightPos0.xyz);

                float diffuse = saturate(dot(normal, light));

                return diffuse * _MainColor * _LightColor0;
            }

            ENDCG
        }
    }
}