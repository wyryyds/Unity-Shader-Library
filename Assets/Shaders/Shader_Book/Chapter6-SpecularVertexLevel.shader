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
	        //���ʸ߹ⷴ������
			fixed4 _Specular;
			//���ʷ����
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
				//��������ģ�Ϳռ�ת�����ü��ռ�
				o.pos = UnityObjectToClipPos(v.vertex);
				//��ȡ������
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				//��������ģ�Ϳռ�ת��������ռ�
				fixed3 worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
				//��ȡ��Դ����
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				//��������
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal,
					worldLightDir));
				//��ȡ���䷽��
				fixed3 reflectDir = normalize(reflect(-worldLightDir, worldNormal));
				//��ȡ�ӽǷ���
				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - mul(unity_ObjectToWorld, v.vertex).xyz);
				//�߹ⷴ��=�����ǿ�ȸ���ɫ*�߹ⷴ��ϵ��*���䷽����ӽǷ����������ķ���ȴη�
				fixed3 specular = _LightColor0.rgb * _Specular.rgb *
					pow(saturate(dot(reflectDir, viewDir)), _Gloss);
				//��ɫ���=������+������+�߹ⷴ��
				o.color = ambient + diffuse + specular;

				return o;
			}

			fixed4 frag(v2f i) :SV_Target
			{
				//ֱ�����������ɫ
				return fixed4(i.color,1.0);
			}
				
		    ENDCG
		}
	}
		Fallback "Specular"
}