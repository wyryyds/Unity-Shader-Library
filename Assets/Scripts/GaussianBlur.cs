using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GaussianBlur : PostEffectsBase
{
    public Shader gussianBlurShader;
    private Material gaussianBlurMaterial=null;
    public Material Material
    {
        get
        {
            gaussianBlurMaterial = CheckShaderAndCreateMaterial(gussianBlurShader, gaussianBlurMaterial);
            return gaussianBlurMaterial;
        }
    }
    //高斯模糊迭代次数
    [Range(0, 4)]
    public int iterations=3;
    //模糊范围
    [Range(0.2f, 3.0f)]
    public float blurSpread = 0.6f;
    //缩放系数
    [Range(1, 8)]
    public int downSample = 2;

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if(Material!=null)
        {
            //对图像缩放降采样
            int rtw = source.width / downSample;
            int rth = source.height / downSample;
            //降采样之后分配一块小于原屏幕分辨率尺寸的缓存区
            RenderTexture buffer0 = RenderTexture.GetTemporary(rtw, rth, 0);
            //设置渲染纹理的滤波模式为双线性
            buffer0.filterMode = FilterMode.Bilinear;
            //存储缩放后的图像纹理
            Graphics.Blit(source, buffer0);

            for(int i = 0; i < iterations; i++)
            {
                Material.SetFloat("_BlurSize", 1.0f + i * blurSpread);
                RenderTexture buffer1 = RenderTexture.GetTemporary(rtw, rth, 0);

                //执行第一个Pass，以buffer0为输入，buffer1为输出
                //第一个Pass中使用竖直方向的一维高斯核进行滤波
                Graphics.Blit(buffer0, buffer1, Material, 0);

                //利用GetTemporary申请内存之后必须回收
                RenderTexture.ReleaseTemporary(buffer0);

                //将输出buffer1存储到buffer0中
                buffer0 = buffer1;

                //重新分配buffer1
                buffer1 = RenderTexture.GetTemporary(rtw, rth, 0);

                //执行第二个Pass，以第一个Pass的输出作为输入。
                //使用水平方向的一维高斯核进行滤波
                Graphics.Blit(buffer0, buffer1, Material, 1);
                //迭代
                RenderTexture.ReleaseTemporary(buffer0);
                buffer0 = buffer1;
            }
            Graphics.Blit(buffer0, destination);
            RenderTexture.ReleaseTemporary(buffer0);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }

}
