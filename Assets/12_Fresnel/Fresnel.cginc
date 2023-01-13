#ifndef FRESNEL_INCLUDED
#define FRESNEL_INCLUDED

#include "UnityCG.cginc"
#include "Lighting.cginc"
#include "AutoLight.cginc"

// フレネル反射とは、光が異なる屈折率を持つ物質へ入射するとき
// 入射角が垂直に近いほど屈折(侵入)する光が大きくなり、水平に近いほど反射する光が多くなります

struct v2f
{
    float4 vertex  : SV_POSITION;
    float3 vertexW : TEXCOORD0;
    float3 normal  : TEXCOORD1;
};

float4 _MainColor;
float4 _SpecularColor;
float  _Shiness;
float  _Fresnel;

// フレネルによって提唱された算出方法は、計算量などを理由にゲームで用いられることはほぼありません
// 普通は近似した値を返す式を使用します。
float fresnelSchlick(float3 view, float3 normal, float fresnel)
{
    return saturate(fresnel + (1 - fresnel) * pow(1 - dot(view, normal), 5));
} // こちらはSchlickが提唱した方程式を実装したものです

float fresnelFast(float3 view, float3 normal, float fresnel)
{
    return saturate(fresnel + (1 - fresnel) * exp(-6 * dot(view, normal)));
} //こちらは「Far Cry 3」が採用したものです。
// どちらもfrenelという引数には物質ごとの反射率を与えます

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

    float  diffuse  = saturate(dot(normal, light));
    float  specular = pow(saturate(dot(normal, hlf)), _Shiness);
    float  fresnel  = fresnelFast(view, normal, _Fresnel);
    float3 ambient  = ShadeSH9(half4(normal, 1));

    fixed4 color = diffuse * _MainColor * _LightColor0 * attenuation
                 + specular * _SpecularColor * _LightColor0 * attenuation;

    // フレネル反射は鏡面反射のため、_specularColorを反映します。
    // 基本的に鏡面反射は物質の色に影響されない
    color.rgb += ambient * _MainColor
               + ambient * _SpecularColor * fresnel;

    // return fresnel;
    return color;
}

#endif // FRESNEL_INCLUDED