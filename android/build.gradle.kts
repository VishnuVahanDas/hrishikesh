import com.android.build.gradle.LibraryExtension
import com.android.build.gradle.tasks.ProcessLibraryManifest

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

subprojects {
    if (name == "device_apps") {
        plugins.withId("com.android.library") {
            extensions.configure<LibraryExtension> {
                namespace = "com.example.device_apps"
            }
            tasks.withType<ProcessLibraryManifest>().configureEach {
                doFirst {
                    val manifestFile = file("src/main/AndroidManifest.xml")
                    if (manifestFile.exists()) {
                        val original = manifestFile.readText()
                        val cleaned = original.replace("package=\"fr.g123k.deviceapps\"", "")
                        if (original != cleaned) {
                            manifestFile.writeText(cleaned)
                        }
                    }
                }
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
