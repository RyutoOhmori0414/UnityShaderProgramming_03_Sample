#ifndef PHONG_INCLUDED
#define PHONG_INCLUDED

#include "UnityCG.cginc"
#include "Lighting.cginc"
#include "AutoLight.cginc"

// 鏡面反射光を表現するために、金属などに見られる鋭い反射(ハイライト)を表現する
// 物体に入射したした光が正反射して視界に入る光を「鏡面反射光」という
// 鏡面反射光を表すベクトル R と、ある面から見た視線の方向を表すベクトル V の差が小さいほど視界に多くの光が入るとみなす
// 光源の面積は考慮しないため、鏡面反射する範囲を広げて近似させる

// 「Phongの反射モデル」を使ったシェーディングのことを、「Phongシェーディング」と呼んでいることがあるが
// ところが本来のPhongシェーディングはラスタライズ時に、法線を線形補完するシェーディングのことです。

struct v2f
{
    float4 vertex  : SV_POSITION;
    float3 vertexW : TEXCOORD0;
    float3 normal  : TEXCOORD1;
};

float4 _MainColor;
// 反射された光は基本的に物体の色を反映しません。
// 鏡面反射光に対して任意の色を与えられるように、_SpecularColorを用意しています
float4 _SpecularColor;
// 鏡面反射のしやすさ、光沢の度合いを制御するパラメータ。値が大きいほど鋭い反射となりつるつるに見える。
float  _Shiness;

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
    // カメラの座標は_WorldCameraPosによって取得できます。ワールド座標なので引き算で視線ベクトルに直しています
    // 注意点として、視線ベクトルは面から視点にむかって伸びるベクトルであることに留意する
    float3 view   = normalize(_WorldSpaceCameraPos - i.vertexW);
    // 反射ベクトルを求めるための、reflect関数が用意されている
    float3 rflt   = normalize(reflect(-light, normal));
    //     rflt   = normalize(-light + normal * saturate(dot(normal, light)) * 2);

    float  diffuse  = saturate(dot(normal, light));
    // 視線ベクトルと反射ベクトルの内積を求めて、Cosθが返ってくる
    float  specular = pow(saturate(dot(view, rflt)), _Shiness);
    float3 ambient  = ShadeSH9(half4(normal, 1));

    fixed4 color = diffuse * _MainColor * _LightColor0 * attenuation
                 + specular * _SpecularColor * _LightColor0 * attenuation;

    color.rgb += ambient * _MainColor;

    return color;
}

#endif // PHONG_INCLUDED