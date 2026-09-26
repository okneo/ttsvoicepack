package com.example.ttsvoicepack

import android.content.Intent
import android.os.Bundle
import android.speech.tts.TextToSpeech
import android.speech.tts.UtteranceProgressListener
import android.widget.*
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.FileProvider
import androidx.lifecycle.lifecycleScope
import kotlinx.coroutines.*
import java.io.*
import java.util.Locale
import java.util.UUID
import java.util.zip.ZipEntry
import java.util.zip.ZipOutputStream

class MainActivity : AppCompatActivity() {

    private lateinit var editText: EditText
    private lateinit var btnGenerate: Button
    private lateinit var btnShare: Button
    private lateinit var progressBar: ProgressBar
    private lateinit var tvStatus: TextView

    private var tts: TextToSpeech? = null
    private var ttsReady = false
    private var currentUtteranceId: String? = null
    private var currentDeferred: CompletableDeferred<Boolean>? = null
    private var lastZip: File? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        editText = findViewById(R.id.editText)
        btnGenerate = findViewById(R.id.btnGenerate)
        btnShare = findViewById(R.id.btnShare)
        progressBar = findViewById(R.id.progressBar)
        tvStatus = findViewById(R.id.tvStatus)

        editText.setText(
            "welcome|欢迎使用语音包生成器\n" +
            "hello|你好，很高兴见到你\n" +
            "bye|再见，祝你一路顺风"
        )

        initTts()

        btnGenerate.setOnClickListener {
            if (!ttsReady) {
                Toast.makeText(this, "TTS 还没准备好", Toast.LENGTH_SHORT).show()
                return@setOnClickListener
            }
            val lines = parseLines(editText.text.toString())
            if (lines.isEmpty()) {
                Toast.makeText(this, "请输入内容，格式：文件名|文本", Toast.LENGTH_SHORT).show()
                return@setOnClickListener
            }
            generatePack(lines)
        }

        btnShare.setOnClickListener {
            lastZip?.let { shareZip(it) }
        }
    }

    private fun initTts() {
        tts = TextToSpeech(this) { status ->
            if (status == TextToSpeech.SUCCESS) {
                val result = tts?.setLanguage(Locale.CHINA)
                if (result == TextToSpeech.LANG_MISSING_DATA ||
                    result == TextToSpeech.LANG_NOT_SUPPORTED) {
                    tvStatus.text = "中文语音数据未安装"
                } else {
                    ttsReady = true
                    tvStatus.text = "TTS 已就绪"
                }
                tts?.setOnUtteranceProgressListener(object : UtteranceProgressListener() {
                    override fun onStart(utteranceId: String?) {}
                    override fun onDone(utteranceId: String?) {
                        if (utteranceId == currentUtteranceId) {
                            currentDeferred?.complete(true)
                            currentUtteranceId = null
                            currentDeferred = null
                        }
                    }
                    @Deprecated("Deprecated in Java")
                    override fun onError(utteranceId: String?) {
                        if (utteranceId == currentUtteranceId) {
                            currentDeferred?.complete(false)
                            currentUtteranceId = null
                            currentDeferred = null
                        }
                    }
                })
            } else {
                tvStatus.text = "TTS 初始化失败"
            }
        }
    }

    private fun parseLines(input: String): List<Pair<String, String>> {
        return input.lineSequence()
            .map { it.trim() }
            .filter { it.isNotEmpty() && it.contains('|') }
            .map {
                val index = it.indexOf('|')
                it.substring(0, index).trim() to it.substring(index + 1).trim()
            }
            .filter { it.first.isNotEmpty() && it.second.isNotEmpty() }
            .toList()
    }

    private fun generatePack(lines: List<Pair<String, String>>) {
        btnGenerate.isEnabled = false
        btnShare.isEnabled = false
        progressBar.visibility = ProgressBar.VISIBLE
        progressBar.max = lines.size
        progressBar.progress = 0

        lifecycleScope.launch {
            val outDir = File(getExternalFilesDir(null), "VoicePack")
            if (outDir.exists()) outDir.deleteRecursively()
            outDir.mkdirs()

            var success = 0
            for ((index, line) in lines.withIndex()) {
                val (name, text) = line
                val safeName = name.replace(Regex("[^a-zA-Z0-9_\\-\\u4e00-\\u9fa5]"), "_")
                val wavFile = File(outDir, "$safeName.wav")
                tvStatus.text = "正在生成 ${index + 1}/${lines.size}：$safeName"
                if (synthesizeToFile(text, wavFile)) success++
                progressBar.progress = index + 1
            }

            val zipFile = withContext(Dispatchers.IO) {
                zipFolder(outDir, File(outDir, "voice_pack.zip"))
            }
            lastZip = zipFile
            tvStatus.text = "完成：成功 $success/${lines.size}\nZIP：${zipFile.absolutePath}"
            btnGenerate.isEnabled = true
            btnShare.isEnabled = true
            progressBar.visibility = ProgressBar.GONE
            Toast.makeText(this@MainActivity, "语音包已生成", Toast.LENGTH_LONG).show()
        }
    }

    private suspend fun synthesizeToFile(text: String, file: File): Boolean {
        val id = UUID.randomUUID().toString()
        val deferred = CompletableDeferred<Boolean>()
        currentUtteranceId = id
        currentDeferred = deferred
        val result = tts?.synthesizeToFile(text, Bundle(), file, id)
        if (result != TextToSpeech.SUCCESS) {
            currentUtteranceId = null
            currentDeferred = null
            return false
        }
        val ok = withTimeoutOrNull(30_000) { deferred.await() } ?: false
        if (currentUtteranceId == id) {
            currentUtteranceId = null
            currentDeferred = null
        }
        return ok
    }

    private fun zipFolder(srcDir: File, zipFile: File): File {
        ZipOutputStream(BufferedOutputStream(FileOutputStream(zipFile))).use { zos ->
            srcDir.listFiles()?.forEach { file ->
                if (file.isFile && file.name != zipFile.name) {
                    zos.putNextEntry(ZipEntry(file.name))
                    file.inputStream().use { it.copyTo(zos) }
                    zos.closeEntry()
                }
            }
        }
        return zipFile
    }

    private fun shareZip(zip: File) {
        val uri = FileProvider.getUriForFile(this, "$packageName.fileprovider", zip)
        val intent = Intent(Intent.ACTION_SEND).apply {
            type = "application/zip"
            putExtra(Intent.EXTRA_STREAM, uri)
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        }
        startActivity(Intent.createChooser(intent, "分享语音包"))
    }

    override fun onDestroy() {
        tts?.stop()
        tts?.shutdown()
        super.onDestroy()
    }
}
