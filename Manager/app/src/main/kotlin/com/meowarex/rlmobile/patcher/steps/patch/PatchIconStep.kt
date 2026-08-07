package com.meowarex.rlmobile.patcher.steps.patch

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import androidx.core.graphics.scale
import com.meowarex.rlmobile.R
import com.meowarex.rlmobile.patcher.StepRunner
import com.meowarex.rlmobile.patcher.steps.StepGroup
import com.meowarex.rlmobile.patcher.steps.base.Step
import com.meowarex.rlmobile.patcher.steps.base.StepState
import com.meowarex.rlmobile.patcher.steps.download.CopyDependenciesStep
import com.meowarex.rlmobile.ui.screens.patchopts.PatchOptions
import com.github.diamondminer88.zip.ZipReader
import com.github.diamondminer88.zip.ZipWriter
import org.koin.core.component.KoinComponent
import org.koin.core.component.inject
import java.io.ByteArrayOutputStream

class PatchIconStep(
    private val options: PatchOptions,
) : Step(), KoinComponent {

    private val context: Context by inject()

    override val group = StepGroup.Patch
    override val localizedName = R.string.patch_step_patch_icon

    private val densities = mapOf(
        "mdpi" to 1.0,
        "hdpi" to 1.5,
        "xhdpi" to 2.0,
        "xxhdpi" to 3.0,
        "xxxhdpi" to 4.0,
    )
    private val baseSizeDp = 48

    override suspend fun execute(container: StepRunner) {
        val iconId = options.selectedIconId
        if (iconId == null) {
            state = StepState.Skipped
            return
        }

        container.log("Loading bundled icon: $iconId")
        val resId = ICON_RESOURCES[iconId]
            ?: throw IllegalStateException("Unknown icon id: $iconId")
        val sourceBitmap = BitmapFactory.decodeResource(context.resources, resId)

        val apk = container.getStep<CopyDependenciesStep>().apk

        container.log("Repacking apk with custom icon")
        val repacked = apk.resolveSibling(apk.name + ".repack")
        repacked.delete()

        ZipReader(apk).use { reader ->
            ZipWriter(repacked, /* append = */ false).use { writer ->
                for (name in reader.entryNames) {
                    if (name.endsWith("/")) continue

                   val density = densities.keys.firstOrNull { d ->
    name == "res/mipmap-$d-v4/icon.png" || 
        name == "res/mipmap-$d-v4/icon_background.png" ||
        name == "res/mipmap-$d-v4/icon_foreground.png"
}

                    val bytes = if (density != null) {
                        val factor = densities.getValue(density)
                        val px = (baseSizeDp * factor).toInt()
                        resizeToPng(sourceBitmap, px)
                    } else {
                        reader.openEntry(name)!!.read()
                    }
                    writer.writeEntry(name, bytes)
                }
            }
        }

        if (!apk.delete() || !repacked.renameTo(apk))
            throw Error("Failed to replace apk with custom icon variant")
    }

    private fun resizeToPng(bitmap: Bitmap, sizePx: Int): ByteArray {
        val scaled = bitmap.scale(sizePx, sizePx)
        return ByteArrayOutputStream().use { stream ->
            scaled.compress(Bitmap.CompressFormat.PNG, 100, stream)
            stream.toByteArray()
        }
    }

    companion object {
        val ICON_RESOURCES = mapOf(
            "alt1" to R.drawable.ic_launcher_alt1,
            "alt2" to R.drawable.ic_launcher_alt2,
            "alt3" to R.drawable.ic_launcher_alt3,
            "alt4" to R.drawable.ic_launcher_alt4,
            "alt5" to R.drawable.ic_launcher_alt5,
            "alt6" to R.drawable.ic_launcher_alt6,
            "alt7" to R.drawable.ic_launcher_alt7,
        )
    }
}