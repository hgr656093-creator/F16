package com.recon.app

import android.content.Context
import java.io.File
import java.io.FileOutputStream
import java.net.URL
import java.util.zip.ZipInputStream

object BinariesManager {

    fun setupBinaries(context: Context, onProgress: (String) -> Unit) {
        val binDir = File(context.filesDir, "bin")
        if (!binDir.exists()) {
            binDir.mkdirs()
        }

        val tools = mapOf(
            "subfinder" to "https://github.com/projectdiscovery/subfinder/releases/download/v2.6.5/subfinder_2.6.5_linux_arm64.zip",
            "httpx" to "https://github.com/projectdiscovery/httpx/releases/download/v1.6.8/httpx_1.6.8_linux_arm64.zip",
            "gau" to "https://github.com/lc/gau/releases/download/v2.2.1/gau_2.2.1_linux_arm64.tar.gz",
            "nuclei" to "https://github.com/projectdiscovery/nuclei/releases/download/v3.2.9/nuclei_3.2.9_linux_arm64.zip"
        )

        tools.forEach { (toolName, urlString) ->
            val toolFile = File(binDir, toolName)
            if (!toolFile.exists()) {
                onProgress("جاري تحميل أداة $toolName...")
                try {
                    val zipFile = File(context.cacheDir, "$toolName.zip")
                    URL(urlString).openStream().use { input ->
                        FileOutputStream(zipFile).use { output ->
                            input.copyTo(output)
                        }
                    }

                    unzip(zipFile, binDir)
                    zipFile.delete()

                    toolFile.setExecutable(true, false)
                } catch (e: Exception) {
                    e.printStackTrace()
                }
            }
        }
    }

    private fun unzip(zipFile: File, targetDirectory: File) {
        ZipInputStream(zipFile.inputStream()).use { zis ->
            var zi = zis.nextEntry
            while (zi != null) {
                val newFile = File(targetDirectory, zi.name)
                if (zi.isDirectory) {
                    newFile.mkdirs()
                } else {
                    newFile.parentFile?.mkdirs()
                    FileOutputStream(newFile).use { fos ->
                        zis.copyTo(fos)
                    }
                }
                zis.closeEntry()
                zi = zis.nextEntry
            }
        }
    }
}
