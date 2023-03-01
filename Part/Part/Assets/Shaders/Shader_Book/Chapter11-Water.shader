Shader"Unity Shaders Book/Chapter 11/Water"
{
	Properties
	{
		_MainTex("Main Tex",2D)="white"{}
	    _Color("Color Tint",Color)=(1,1,1,1)
		//水流波动幅度
		_Magnitude("Distortion Magnitude",Float)=1
		//控制波动频率
		_Frequency("Distortion Frequency",Float)=1
		//控制波长的倒数
		_InvWaveLength("Distortion Inverse Wava Length",Float)=10
		//控制纹理移动速度
		_Speed("Speed",Float)=0.5
	}

	SubShader
	{
		//取消批处理"DisableBatching"="True"
		Tags{"Queue"="Transparent" "IgnoreProject"="True" "RenderType"="Transparent" "DisableBatching"="True"}

		Pass
		{
			Tags{"LightMode"="ForwardBase"}
			//关闭深度写入
			Zwrite Off
			Blend SrcAlpha OneMinusSrcAlpha
			//关闭剔除功能
			Cull Off

			CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

			sampler2D _MainTex;
		    float4 _MainTex_ST;
			fixed4 _Color;
			float _Magnitude;
			float _Frequency;
			float _InvWaveLength;
			float _Speed;

			struct a2v
			{
				float4 vertex : POSITION;
				float4 texcoord : TEXCOORD;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

	        v2f vert(a2v v)
			{
				v2f o;
				float4 offset;
				offset.yzw = float3(0.0, 0.0, 0.0);
				offset.x = sin(_Frequency * _Time.y + v.vertex.x * _InvWaveLength +
					v.vertex.y * _InvWaveLength + v.vertex.z * _InvWaveLength) * _Magnitude;
				o.pos = UnityObjectToClipPos(v.vertex + offset);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.uv += float2(0.0, _Time.y * _Speed);
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