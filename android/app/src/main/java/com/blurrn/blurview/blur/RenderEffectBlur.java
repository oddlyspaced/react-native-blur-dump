package com.blurrn.blurview.blur;

import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.RenderEffect;
import android.graphics.RenderNode;
import android.graphics.Shader;

import androidx.annotation.NonNull;

/**
 * Leverages the new RenderEffect.createBlurEffect API to perform blur.
 * Hardware accelerated.
 * Blur is performed on a separate thread - native RenderThread.
 * It doesn't block the Main thread, however it can still cause an FPS drop,
 * because it's just in a different part of the rendering pipeline.
 */
public class RenderEffectBlur {

    private final RenderNode node = new RenderNode("BlurViewNode");

    private int height, width;

    public RenderEffectBlur() {
    }

    public Bitmap blur(@NonNull Bitmap bitmap, float blurRadius) {

        if (bitmap.getHeight() != height || bitmap.getWidth() != width) {
            height = bitmap.getHeight();
            width = bitmap.getWidth();
            node.setPosition(0, 0, width, height);
        }
        Canvas canvas = node.beginRecording();
        canvas.drawBitmap(bitmap, 0, 0, null);
        node.endRecording();
        node.setRenderEffect(RenderEffect.createBlurEffect(blurRadius, blurRadius, Shader.TileMode.MIRROR));
        // returning not blurred bitmap, because the rendering relies on the RenderNode
        return bitmap;
    }

    public void destroy() {
        node.discardDisplayList();
    }

    public boolean canModifyBitmap() {
        return true;
    }

    @NonNull
    public Bitmap.Config getSupportedBitmapConfig() {
        return Bitmap.Config.ARGB_8888;
    }

    public void render(@NonNull Canvas canvas, @NonNull Bitmap bitmap) {
        canvas.drawRenderNode(node);
    }

}
