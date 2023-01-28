// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unity Shaders Book/Chapter 7/Single Texture"
{
	Properties
	{
		_Color("Color Tint",Color)=(1,1,1,1)
		_MainTex("Main Tex",2D)="white"{}
		_Specular("Specular",Color) = (1,1,1,1)
		_Gloss("Gloss",Range(8.0,256)) = 20
	}

		SubShader
		{
			Pass
			{
				Tags{"LightMode" = "ForwardBase"}

				CGPROGRAM

				#pragma vertex vert
				#pragma fragment frag

				#include "Lighting.cginc"

				fixed4 _Color;
		        sampler2D _MainTex;
				//得到纹理的缩放平移值,.xz存放缩放值，.zw存储偏移值
				float4 _MainTex_ST;
				fixed4 _Specular;
				float _Gloss;

				struct a2v
				{
					float4 vertex:POSITION;
					float3 normal:NORMAL;
					float4 texcoord:TEXCOORD0;
				};

				struct v2f
				{
					float4 pos:SV_POSITION;
					float3 worldNormal:TEXCOORD0;
					float3 worldPos:TEXCOORD1;
					float2 uv:TEXCOORD2;
				};

				v2f vert(a2v v)
				{
					v2f o;
					//将顶点坐标从模型空间转换到裁剪空间
					o.pos = UnityObjectToClipPos(v.vertex);
					//将法向从模型空间转到世界空间
					o.worldNormal = UnityObjectToWorldNormal(v.normal);
					//将顶点坐标从模型空间转换到世界空间
					o.worldPos = mul(unity_ObjectToWorld, v.vertex).xzy;
					//纹理坐标变换，先计算缩放，在加上偏移
					o.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
					return o;
				}

				fixed4 frag(v2f i) :SV_Target
				{
					//法向归一
					fixed3 worldNormal = normalize(i.worldNormal);
				    //内置API获取光源方向
				    fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
					//纹理采样结果乘以颜色属性来作为材质的反射率
					fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
					//环境光结果，需要乘上反射率
					fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xzy * albedo;
					//漫反射结果,这里是以材质反射率作为系数
					fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(worldNormal, worldLightDir));
					//根据API获取视线方向
					fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
					//BlinnPhong模型
					fixed3 halfDir = normalize(worldLightDir + viewDir);
					//高光结果
					fixed3 specular = _LightColor0.rgb * _Specular.rgb *
						pow(max(0, dot(worldNormal, halfDir)), _Gloss);

					return fixed4(ambient + diffuse + specular, 1.0);
				}
					ENDCG
            }
			
		}
			Fallback"Specular"
}