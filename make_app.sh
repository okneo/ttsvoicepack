

#!/data/data/com.termux/files/usr/bin/bash
set -e

mkdir -p app/src/main/java/com/example/ttsvoicepack
mkdir -p app/src/main/res/layout
mkdir -p app/src/main/res/values
mkdir -p app/src/main/res/xml
mkdir -p app/src/main/res/mipmap-anydpi-v26
mkdir -p .github/workflows
mkdir -p keystore

cat > settings.gradle <<'EOF'
pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}
rootProject.name = "TTSVoicePack"
include ':app'
EOF

cat > build.gradle <<'EOF'
plugins {
    id 'com.android.application' version '8.1.4' apply false
    id 'org.jetbrains.kotlin.android' version '1.9.22' apply false
}
EOF

cat > gradle.properties <<'EOF'
org.gradle.jvmargs=-Xmx2048m
android.useAndroidX=true
kotlin.code.style=official
EOF

cat > app/build.gradle <<'EOF'
plugins {
    id 'com.android.application'
    id 'org.jetbrains.kotlin.android'
}

android {
    namespace 'com.example.ttsvoicepack'
    compileSdk 34

    defaultConfig {
        applicationId "com.example.ttsvoicepack"
        minSdk 24
        targetSdk 34
        versionCode 1
        versionName "1.0"
    }

    buildTypes {
        release {
            minifyEnabled false
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_17
        targetCompatibility JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = '17'
    }
}

dependencies {
    implementation 'androidx.core:core-ktx:1.12.0'
    implementation 'androidx.appcompat:appcompat:1.6.1'
    implementation 'com.google.android.material:material:1.11.0'
    implementation 'androidx.constraintlayout:constraintlayout:2.1.4'
    implementation 'androidx.lifecycle:lifecycle-runtime-ktx:2.7.0'
    implementation 'org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.3'
}
EOF

cat > app/proguard-rules.pro <<'EOF'
EOF

cat > app/src/main/AndroidManifest.xml <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <application
        android:allowBackup="true"
        android:icon="@mipmap/ic_launcher"
        android:label="@string/app_name"
        android:supportsRtl="true"
        android:theme="@style/Theme.TTSVoicePack">
        <activity
            android:name=".MainActivity"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
        <provider
            android:name="androidx.core.content.FileProvider"
            android:authorities="${applicationId}.fileprovider"
            android:exported="false"
            android:grantUriPermissions="true">
            <meta-data
                android:name="android.support.FILE_PROVIDER_PATHS"
                android:resource="@xml/file_paths" />
        </provider>
    </application>
</manifest>
EOF

cat > app/src/main/res/xml/file_paths.xml <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<paths xmlns:android="http://schemas.android.com/apk/res/android">
    <external-files-path name="external_files" path="." />
</paths>
EOF

cat > app/src/main/res/values/strings.xml <<'EOF'
<resources>
    <string name="app_name">TTS语音包生成器</string>
</resources>
EOF

cat > app/src/main/res/values/themes.xml <<'EOF'
<resources>
    <style name="Theme.TTSVoicePack" parent="Theme.AppCompat.Light.DarkActionBar" />
</resources>
EOF

cat > app/src/main/res/values/colors.xml <<'EOF'
<resources>
    <color name="purple_500">#FF6200EE</color>
    <color name="purple_700">#FF3700B3</color>
    <color name="white">#FFFFFFFF</color>
</resources>
EOF

cat > app/src/main/res/layout/activity_main.xml <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<ScrollView xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent">
    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:orientation="vertical"
        android:padding="16dp">
        <TextView
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:text="每行一条，格式：文件名|文本"
            android:textSize="16sp"
            android:textStyle="bold" />
        <EditText
            android:id="@+id/editText"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:layout_marginTop="8dp"
            android:gravity="top|start"
            android:inputType="textMultiLine"
            android:minLines="8"
            android:hint="welcome|欢迎使用语音包生成器" />
        <Button
            android:id="@+id/btnGenerate"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:layout_marginTop="8dp"
            android:text="生成语音包" />
        <Button
            android:id="@+id/btnShare"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:layout_marginTop="8dp"
            android:enabled="false"
            android:text="分享 ZIP" />
        <ProgressBar
            android:id="@+id/progressBar"
            style="?android:attr/progressBarStyleHorizontal"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:layout_marginTop="8dp"
            android:visibility="gone" />
        <TextView
            android:id="@+id/tvStatus"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:layout_marginTop="8dp"
            android:text="准备中..."
            android:textSize="14sp" />
    </LinearLayout>
</ScrollView>
EOF

cat > app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@color/purple_500" />
    <foreground android:drawable="@color/white" />
</adaptive-icon>
EOF

cat > app/src/main/java/com/example/ttsvoicepack/MainActivity.kt <<'EOF'
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
EOF

cat > .github/workflows/build.yml <<'EOF'
name: Build APK
on:
  push:
    branches: [ main ]
  workflow_dispatch:
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-java@v4
        with:
          distribution: 'temurin'
          java-version: '17'
      - uses: gradle/actions/setup-gradle@v3
        with:
          gradle-version: 8.2
      - name: Build Debug APK
        run: gradle assembleDebug
      - name: Upload APK
        uses: actions/upload-artifact@v4
        with:
          name: app-debug
          path: app/build/outputs/apk/debug/app-debug.apk
EOF

echo "生成完毕：$PWD"
ls -R
