﻿Shader "DOM/DOMEvlShader"
{
    Properties
    {
        _Color ("_Color", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Transparent"}
        LOD 100

        Pass
        {
            Cull Off
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            //Blend One One
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _LightDepthTex;
            sampler2D _OpacityMapTex;
            float4x4 _LightProjection;
            float4 _LightZBufferParams;

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 vertex   : SV_POSITION;
                float4 worldPos : TEXCOORD0;
            };

            float4 _Color;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                float4 worldPos = mul(UNITY_MATRIX_M, v.vertex);
                o.worldPos.xyz = worldPos.xyz;
				o.worldPos.w = 1;
                return o;
            }
            float LightLinear01Depth(float z)
            {
                return 1.0 / (_LightZBufferParams.x * z + _LightZBufferParams.y);
            }

            float GetOpacity(float2 texPos, float depth)
	            float near = 0.05; /*DecodeFloatRGBA(depthRGBA);*/
                float base = 0.1;
                layerDistance.x = near + base;
                layerDistance.y = layerDistance.x + base;
                layerDistance.z = layerDistance.y + base;
                layerDistance.w = layerDistance.z + base;

            fixed4 frag (v2f i) : SV_Target
            {
                float4 lightClipPos = mul(_LightProjection, i.worldPos);
                lightClipPos.xyz = lightClipPos.xyz / lightClipPos.w;
                float depth = LightLinear01Depth(lightClipPos.z);
                depth = 1.0 - depth;
                float2 texPos = lightClipPos.xy * 0.5 + 0.5;
                float opacity = GetOpacity(texPos, depth);
                return 1.0 - opacity;
            }
            ENDCG
        }
    }
}