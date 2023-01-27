// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader"Unity Shaders Book/Chapter 6/Diffuse Pixel-Level"
{

	Properties{
		_Diffuse("Diffuse",Color) = (1,1,1,1)
	}

		SubShader{
			Pass{
				Tags{"LightMode" = "ForwardBase"}

				CGPROGRAM


				#pragma vertex vert
				#pragma fragment frag

				#include"Lighting.cginc"

				fixed4 _Diffuse;

				struct a2v
				{
					float4 vertex : POSITION;
					float3 normal : NORMAL;
				};
				struct v2f
				{
					float4 pos : SV_POSITION;
					float3 worldNormal : TEXCOORDO;
				};

				v2f vert(a2v v)
				{
					v2f o;
					o.pos = UnityObjectToClipPos(v.vertex);
				    //顶点着色器只需要将法线从模型空间转换到世界空间传递给片元着色器
					o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);

					return o;
				}
				fixed4 frag(v2f i) :SV_Target
				{
					//获取环境光
					fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				    //世界空间下的表面法线
				    fixed3 worldNormal = normalize(i.worldNormal);
					//获得光源方向
					fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
					//漫反射光照=入射光颜色强度*材质漫反射系数*表面法向量与光源方向的正点积
					fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal,
						worldLightDir));
					//光照结果=环境光结果+漫反射结果
					fixed3 color = ambient + diffuse;
					
					return fixed4(color, 1.0);
				}
				ENDCG
		}
	}
		Fallback "Diffuse"
}