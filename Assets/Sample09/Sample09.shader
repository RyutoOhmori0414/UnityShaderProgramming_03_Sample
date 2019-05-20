﻿Shader "Sample/Sample09"
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

            #include "Sample09Lib.cginc"

            ENDCG
        }

        Pass
        {
            Tags
            {
                "LightMode" = "ForwardAdd"
            }

            Blend One One

            CGPROGRAM

            #pragma multi_compile_fwdadd
            #pragma vertex   vert
            #pragma fragment frag

            #include "Sample09Lib.cginc"

            ENDCG
        }
    }
}