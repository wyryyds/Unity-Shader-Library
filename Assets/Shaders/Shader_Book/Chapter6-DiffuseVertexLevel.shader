Shader"Unity Shaders Book/Chapter 6/Diffuse Vertex-Level"
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

		        //材质漫反射属性
				fixed4 _Diffuse;

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
                    //将顶点位置从模型空间转到裁剪空间
					o.pos = UnityObjectToClipPos(v.vertex);
					//获得环境光
					fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
					//将法线从模型空间变换到世界空间
					fixed3 worldNormal = normalize(mul((v.normal), (float3x3)unity_WorldToObject));
					//获得光源方向
					fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
					//漫反射光照=入射光颜色强度*材质漫反射系数*表面法向量与光源方向的正点积
					fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLight));

					//光照结果=环境光结果+漫反射结果
					o.color = ambient + diffuse;

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
		Fallback "Diffuse"
}