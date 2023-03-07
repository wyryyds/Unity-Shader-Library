using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class PostEffectsBase : MonoBehaviour
{
    /// <summary>
    /// 检测资源
    /// </summary>
    protected void CheckResources()
    {
        bool isSupported = CheckSupport();
        if (isSupported == false)
            NotSupported();
    }
    /// <summary>
    /// 平台是否支持相应的渲染功能
    /// </summary>
    /// <returns></returns>
    protected bool CheckSupport()
    {
        if(SystemInfo.supportsGraphicsFence == false|| SystemInfo.SupportsRenderTextureFormat(RenderTextureFormat.Default)==false)
        {
            return false;
        }
        return true;
    }
    protected void NotSupported()
    {
        enabled = false;
    }

    protected void Start()
    {
        CheckResources();
    }
    /// <summary>
    /// 检测shader并且创建材质
    /// </summary>
    /// <param name="shader">使用的shader</param>
    /// <param name="material">用于后处理的材质</param>
    /// <returns></returns>
    protected Material CheckShaderAndCreateMaterial(Shader shader, Material material)
    {
        if (shader == null) return null;

        if (shader.isSupported && material && material.shader == shader) return material;

        if (!shader.isSupported) return null;
        else
        {
            material = new Material(shader);
            material.hideFlags = HideFlags.DontSave;
            if (material) return material;

            return null;
        }
    }
}
