﻿#ifndef SAMPLE13ALIB_INCLUDED
#define SAMPLE13ALIB_INCLUDED

#include "UnityCG.cginc"
#include "Lighting.cginc"
#include "AutoLight.cginc"

struct v2f
{
    float4 vertex  : SV_POSITION;
    float3 vertexW : TEXCOORD0;
    float3 normal  : TEXCOORD1;
};

float4 _MainColor;
float4 _SpecularColor;
float  _Roughness;
float  _Fresnel;

float dTermBeckmann(float dotNH, float roughness)
{
    dotNH = dotNH * dotNH;
    roughness = roughness * roughness;

    return exp((dotNH - 1) / (roughness * dotNH)) / (3.141592 * roughness * dotNH * dotNH);
}

float gTermTorrance(float dotNL, float dotNV, float dotNH, float dotVH)
{
    return min(1, min(2 * dotNH * dotNV / dotVH,
                      2 * dotNH * dotNL / dotVH));
}

float fresnelSchlick(float dotNV, float fresnel)
{
    return saturate(fresnel + (1 - fresnel) * pow(1 - dotNV, 5));
}

float fresnelFast(float dotNV, float fresnel)
{
    return saturate(fresnel + (1 - fresnel) * exp(-6 * dotNV));
}

v2f vert(appdata_base v)
{
    v2f o;

    o.vertex  = UnityObjectToClipPos(v.vertex);
    o.vertexW = mul(unity_ObjectToWorld, v.vertex);
    o.normal  = UnityObjectToWorldNormal(v.normal);

    return o;
}

fixed4 frag(v2f i) : SV_Target
{
    UNITY_LIGHT_ATTENUATION(attenuation, i, i.vertexW)

    float3 normal = normalize(i.normal);
    float3 light  = normalize(_WorldSpaceLightPos0.w == 0 ?
                              _WorldSpaceLightPos0.xyz :
                              _WorldSpaceLightPos0.xyz - i.vertexW);
    float3 view   = normalize(_WorldSpaceCameraPos - i.vertexW);
    float3 hlf    = normalize(light + view);

    float dotNL = dot(normal, light);
    float dotNV = dot(normal, view);
    float dotNH = dot(normal, hlf);
    float dotVH = dot(view,   hlf);

    float dTerm = dTermBeckmann(dotNH, _Roughness);
    float gTerm = gTermTorrance(dotNL, dotNV, dotNH, dotVH);
    float fTerm = fresnelSchlick(dotNV, _Fresnel);

    // return dTerm;
    // return gTerm;
    // return fTerm;

    float  diffuse  = saturate(dotNL);
    float  specular = saturate(dTerm * gTerm * fTerm / (dotNL * dotNV * 4) * dotNL);
    float3 ambient  = ShadeSH9(half4(normal, 1));

    fixed4 color = diffuse * _MainColor * _LightColor0 * attenuation
                 + specular * _SpecularColor * _LightColor0 * attenuation;

    color.rgb += ambient * _MainColor
               + ambient * _SpecularColor * fTerm;

    return color;
}

#endif // SAMPLE13ALIB_INCLUDED