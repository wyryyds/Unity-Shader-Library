Shader "Custom/CustomPBR"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _SpecColor ("Specular", Color) = (0.2, 0.2, 0.2)
        _SpecGlossMap ("Specular (RGB) Smoothness (A)", 2D) = "white" {}
        _BumpMap ("Normal Map", 2D) = "bump" {}
        _BumpScale("Bump Scale", Float) = 1.0
        _EmissionColor ("Color", Color) = (0, 0, 0) // 自发光颜色
        _EmissionMap ("Emission", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 300
        
        Pass
        {
            Tags {"LightMode" = "ForwardBase"}

            CGPROGRAM
            #pragma target 3.0

            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog
            #pragma vertex vert  
            #pragma fragment frag
            
            #include"Lighting.cginc"
            #include"AutoLight.cginc"
            #include"UnityCG.cginc"
            #include"HLSLSupport.cginc"
            
            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Glossiness;
            sampler2D _SpecGlossMap;
            float4 _SpecGlossMap_ST;
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            float _BumpScale;
            fixed4 _EmissionColor;
            sampler2D _EmissionMap;
            float4 _EmissionMap_ST;

            struct a2v {
                float4 vertex:POSITION;
                float3 normal:NORMAL;
                float4 tangent:TANGENT;
                float4 texcoord:TEXCOORD0;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 TtoW0 : TEXCOORD1;
                float4 TtoW1 : TEXCOORD2;
                float4 TtoW2 : TEXCOORD3;
                SHADOW_COORDS(4)
                UNITY_FOG_COORDS(5)
            };
            // 根据理论方程计算BRDF
            //// 计算漫反射项
            inline half3 CustomDisneyDiffuseTern(half NdotV, half NdotL, half LdotH, half roughness, half3 baseColor)
            {
                half FD90 = 0.5 + 2 * roughness * pow(LdotH, 2);
                half lightScatter = (1 + (FD90 - 1) * pow(1 - NdotL, 5));
                half viewScatter = (1 + (FD90 - 1) * pow(1 - NdotV, 5));

                return baseColor * UNITY_INV_PI * lightScatter * viewScatter;
            }
            //// 计算镜面反射项
            ////// 计算法线分布函数D
            inline half CustomGGXTern(half NdotH, half roughness)
            {
                return pow(roughness, 2) * UNITY_INV_PI / (pow((NdotH, 2) * (pow(roughness, 2) - 1) + 1, 2));
            }
            ////// 计算菲涅尔方程F
            inline half3 CustomFresnelTern(half3 c, half VdotH)
            {
                return c + (1 - c) * pow(1 - VdotH, 5);
            }
            ////// 计算几何函数G
            inline half CustomSmithJointGGXVisivilityTern(half NdotL, half NdotV, half roughness)
            {
                half a = pow((roughness + 1) / 2, 2);
                half k = a / 2;
                half GV = NdotV / (NdotV * (1 - k) + k);
                half GL = NdotL / (NdotL * (1 - k) + k);

                return GV * GL;
            }

            inline half3 CustomFresnelLerp(half c0, half3 c1, half cosA)
            {
                half t = pow(1 - cosA, 5);
                return lerp(c0, c1, t);
            }

            v2f vert(a2v v)
            {
                v2f o;
                UNITY_INITIALIZE_OUTPUT(v2f, o);
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
                fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
                fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;

                o.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
                o.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
                o.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);

                TRANSFER_SHADOW(o);

                UNITY_TRANSFER_FOG(o, o.pos);

                return o;
            }

            half4 frag(v2f i) : SV_Target
            {
                half4 specGloss = tex2D(_SpecGlossMap, i.uv);
                specGloss.a *= _Glossiness;
                half3 specColor = specGloss.rgb * _SpecColor.rgb;
                half roughness = 1 - specGloss.a;
                // 用于计算掠射角的反射颜色
                half oneMinusReflectivity = 1 - max(max(specColor.r, specColor.g), specColor.b);
                half3 diffColor = _Color.rgb * tex2D(_MainTex, i.uv).rgb * oneMinusReflectivity;

                half3 normalTangent = UnpackNormal(tex2D(_BumpMap, i.uv));
                normalTangent.xy *= _BumpScale;
                normalTangent.z = sqrt(1.0 - saturate(dot(normalTangent.xy, normalTangent.xy)));
                half3 normalWorld = normalize(half3(dot(i.TtoW0.xyz, normalTangent),
                    dot(i.TtoW1.xyz, normalTangent), dot(i.TtoW2.xyz, normalTangent)));

                float3 worldPos = float3(i.TtoW0.z, i.TtoW1.z, i.TtoW2.z);
                half3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
                half3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));

                half3 reflDir = reflect(-viewDir, normalWorld);

                UNITY_LIGHT_ATTENUATION(atten, i, worldPos);
                // BRDF
                half3 halfDir = normalize(lightDir + viewDir);
                half nv = saturate(dot(normalWorld, viewDir));
                half nl = saturate(dot(normalWorld, lightDir));
                half nh = saturate(dot(normalWorld, halfDir));
                half lv = saturate(dot(lightDir, viewDir));
                half lh = saturate(dot(lightDir, halfDir));
                //// 漫反射项
                half3 diffuseTern = CustomDisneyDiffuseTern(nv, nl, lh, roughness, diffColor);
                //// 镜面反射项
                half D = CustomGGXTern(nl, roughness);
                half3 F = CustomFresnelTern(specColor, lh);
                half G = CustomSmithJointGGXVisivilityTern(nl, nv, roughness);
                half3 specularTern = D * F * G / 4 * nl * nv;
                //// 自发光项
                half3 emisstionTern = tex2D(_EmissionMap, i.uv).rgb * _EmissionColor.rgb;
                // IBL
                half perceptualRoughness = roughness * (1.7 - 0.7 * roughness);
                half mip = perceptualRoughness * 6;
                half4 envMap = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, reflDir, mip);
                half grazingTern = saturate((1 - roughness) + (1 - oneMinusReflectivity));
                half surfaceReduction = 1.0 / (roughness * roughness + 1.0);
                half3 indirectSpecular = surfaceReduction * envMap.rgb * CustomFresnelLerp(specColor, grazingTern, nv);

                half3 col = emisstionTern + UNITY_PI * (diffuseTern + specularTern) * _LightColor0.rgb 
                    * nl * atten + indirectSpecular;

                UNITY_APPLY_FOG(i.fogCoord, c.rgb);

                return half4(col, 1);
            }

            ENDCG
        }

    }
}
