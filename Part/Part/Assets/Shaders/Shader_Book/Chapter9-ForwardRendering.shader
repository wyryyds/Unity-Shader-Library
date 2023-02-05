Shader"Unity Shaders Book/Chapter 9/ForwardRendering "
{
	Properties
	{
		_Diffuse("Diffuse",Color) = (1,1,1,1)
		_Specular("Specular",Color) = (1,1,1,1)
		_Gloss("Gloss",Range(8.0,256)) = 20
	}

		SubShader
	{
		Tags{"RenderType" = "Opaque"}
		//前向渲染中的Base Pass,一个逐像素的平行光以及所有逐顶点和SH光源
		Pass
		{
			Tags{"LightMode" = "ForwardBase"}

			CGPROGRAM

		    //保证shader中使用的光照衰减等光照变量可以被正常赋值
			#pragma multi_compile_fwdbase
			#pragma vertex vert
			#pragma fragment frag

			#include"Lighting.cginc"

			fixed4 _Diffuse;
	        fixed4 _Specular;
			float _Gloss;

			struct a2v
			{
				float4 vertex:POSITION;
				float3 normal:NORMAL;
			};

			struct v2f
			{
				float4 pos:SV_POSITION;
				float3 worldNormal:TEXCOORD0;
				float3 worldPos:TEXCOORD1;
			};

			v2f vert(a2v v)
			{
				v2f o;

				o.pos = UnityObjectToClipPos(v.vertex);

				o.worldNormal = UnityObjectToWorldNormal(v.normal);

				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

				return o;
			}

			fixed4 frag(v2f i) :SV_Target
			{
				fixed3 worldNormal = normalize(i.worldNormal);

			    fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				//在base pass中计算环境光，环境光只会被计算一次
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				//传递最强的平行光交给BasePass进行逐像素处理
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * max(0, dot(worldNormal, worldLightDir));

				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);

				fixed3 halfDir = normalize(worldLightDir + viewDir);

				fixed3 specular = _LightColor0.rgb * _Specular.rgb
					* pow(max(0, dot(worldNormal, halfDir)), _Gloss);

				fixed atten = 1.0;

				return fixed4(ambient + (diffuse + specular) * atten, 1.0);
			}
				ENDCG
	    }
		//ForwardAdd Pass
		Pass {
				Tags { "LightMode" = "ForwardAdd" }
				//开启混合，Additional Pass中的光照结果将会与帧缓存中的光照结果叠加.
				//如果不开启，将会覆盖掉之前的光照结果.
				Blend One One

				CGPROGRAM

				#pragma multi_compile_fwdadd

				#pragma vertex vert
				#pragma fragment frag

				#include "Lighting.cginc"
				#include "AutoLight.cginc"

				fixed4 _Diffuse;
				fixed4 _Specular;
				float _Gloss;

				struct a2v {
					float4 vertex : POSITION;
					float3 normal : NORMAL;
				};

				struct v2f {
					float4 pos : SV_POSITION;
					float3 worldNormal : TEXCOORD0;
					float3 worldPos : TEXCOORD1;
				};

				v2f vert(a2v v) {
					v2f o;
					o.pos = UnityObjectToClipPos(v.vertex);

					o.worldNormal = UnityObjectToWorldNormal(v.normal);

					o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

					return o;
				}
				//计算方式基本与Base Pass一致，需要去掉环境光，自发光，逐顶点光照与SH光照部分
				//添加一些对不同光源类型的支持
				fixed4 frag(v2f i) : SV_Target {
					fixed3 worldNormal = normalize(i.worldNormal);
					#ifdef USING_DIRECTIONAL_LIGHT
						fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
					#else
						fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz - i.worldPos.xyz);
					#endif

					fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * max(0, dot(worldNormal, worldLightDir));

					fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
					fixed3 halfDir = normalize(worldLightDir + viewDir);
					fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss);

					#ifdef USING_DIRECTIONAL_LIGHT
						fixed atten = 1.0;
					#else
						#if defined (POINT)
							float3 lightCoord = mul(unity_WorldToLight, float4(i.worldPos, 1)).xyz;
							fixed atten = tex2D(_LightTexture0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
						#elif defined (SPOT)
							float4 lightCoord = mul(unity_WorldToLight, float4(i.worldPos, 1));
							fixed atten = (lightCoord.z > 0) * tex2D(_LightTexture0, lightCoord.xy / lightCoord.w + 0.5).w * tex2D(_LightTextureB0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
						#else
							fixed atten = 1.0;
						#endif
					#endif

					return fixed4((diffuse + specular) * atten, 1.0);
				}

				ENDCG
			}
	}
	FallBack"Specular"

}