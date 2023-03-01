Shader"Unity Shaders Book/Chapter 11/Billboard"
{
	Properties
	{
		_MainTex("Main Tex",2D)="white"{}
	    _Color("Color Tint",Color)=(1,1,1,1)
		//��ֱ�����Լ���̶�
		_VerticalBillboarding("Vertical Restraints",Range(0,1))=1
	}

	SubShader
	{
		Tags{"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "DisableBatching"="True"}

		Pass
		{
			Tags{"LightMode"="ForwardBase"}
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha
			Cull Off

			CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

			sampler2D _MainTex;
		    float4  _MainTex_ST;
			fixed4 _Color;
			float _VerticalBillboarding;

			struct a2v
			{
				float4 vertex : POSITION;
				float4 texcoord : TEXCOORD;
			};

			struct v2f
			{
				float4 pos: SV_POSITION;
				float2 uv: TEXCOORD0;
			};

			v2f vert(a2v v)
			{
				v2f o;
				//ѡ��ģ�Ϳռ��ԭ����Ϊ����Ƶ�ê��
				float3 center = float3(0, 0, 0);
				//��ȡģ�Ϳռ��µ��ӽ�λ��
				float3 viewer = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos, 1));
				float3 normalDir = viewer - center;
				normalDir.y = normalDir.y * _VerticalBillboarding;
				normalDir = normalize(normalDir);
				//���Լ�����������
				float3 upDir = abs(normalDir.y) > 0.999 ? float3(0, 0, 1) : float3(0, 1, 0);
				//����������������ʱ����ȷ���������������ϸ���������������.
				float3 rightDir = normalize(cross(upDir, normalDir));
				//���ݵõ�������������׼ȷ��������������ȷ�����������뷨����Ҳ����.
				upDir = normalize(cross(normalDir, rightDir));

				float3 centerOffs = v.vertex.xyz - center;
				float3 localPos = center + rightDir * centerOffs.x + upDir * centerOffs.y + normalDir * centerOffs.z;
				o.pos = UnityObjectToClipPos(float4(localPos, 1));
				o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);

				return o;
			}

			fixed4 frag(v2f i) :SV_Target
			{
				fixed4 c = tex2D(_MainTex,i.uv);
			    c.rgb *= _Color.rgb;
				
				return c;
			}
				ENDCG
        }

	}
FallBack"Transparent/VertexLit"
}