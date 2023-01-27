// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Unity Shaders Book/Chapter 6/Specular Vertex-Level"
{
	Properties
	{
	_Diffuse("Diffuse",Color) = (1, 1, 1, 1)
	_Specular("Specular", Color) = (1, 1, 1, 1)
	_Gloss("Gloss", Range(8.0, 256)) = 20
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
			fixed4 _Diffuse;
	        //材质高光反射属性
			fixed4 _Specular;
			//材质反光度
			float _Gloss;

			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};
			struct v2f
			{
				float4 pos : SV_POSITION;
				fixed3 color : COLOR;
			};

			v2f vert(a2v v)
			{
				v2f o;
				//将顶点由模型空间转换到裁剪空间
				o.pos = UnityObjectToClipPos(v.vertex);
				//获取环境光
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				//将法向由模型空间转换到世界空间
				fixed3 worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
				//获取光源方向
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				//漫反射结果
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal,
					worldLightDir));
				//获取反射方向
				fixed3 reflectDir = normalize(reflect(-worldLightDir, worldNormal));
				//获取视角方向
				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - mul(unity_ObjectToWorld, v.vertex).xyz);
				//高光反射=入射光强度跟颜色*高光反射系数*反射方向跟视角方向的正点积的反光度次方
				fixed3 specular = _LightColor0.rgb * _Specular.rgb *
					pow(saturate(dot(reflectDir, viewDir)), _Gloss);
				//颜色结果=环境光+漫反射+高光反射
				o.color = ambient + diffuse + specular;

				return o;
			}

			fixed4 frag(v2f i) :SV_Target
			{
				//直接输出顶点颜色
				return fixed4(i.color,1.0);
			}
				
		    ENDCG
		}
	}
		Fallback "Specular"
}