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
				    //������ɫ��ֻ��Ҫ�����ߴ�ģ�Ϳռ�ת��������ռ䴫�ݸ�ƬԪ��ɫ��
					o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);

					return o;
				}
				fixed4 frag(v2f i) :SV_Target
				{
					//��ȡ������
					fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				    //����ռ��µı��淨��
				    fixed3 worldNormal = normalize(i.worldNormal);
					//��ù�Դ����
					fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
					//���������=�������ɫǿ��*����������ϵ��*���淨�������Դ����������
					fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal,
						worldLightDir));
					//���ս��=��������+��������
					fixed3 color = ambient + diffuse;
					
					return fixed4(color, 1.0);
				}
				ENDCG
		}
	}
		Fallback "Diffuse"
}