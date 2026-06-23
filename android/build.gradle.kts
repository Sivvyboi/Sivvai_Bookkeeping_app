allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

// Inject namespace for plugins that don't have it (required for AGP 8+)
subprojects {
    afterEvaluate {
        if (project.hasProperty("android")) {
            val android = project.extensions.findByName("android")
            if (android != null) {
                try {
                    val getNamespace = android.javaClass.getMethod("getNamespace")
                    if (getNamespace.invoke(android) == null) {
                        val setNamespace = android.javaClass.getMethod("setNamespace", String::class.java)
                        setNamespace.invoke(android, "dev.isar.${project.name.replace("-", "_")}")
                    }
                } catch (e: Exception) {
                    // Ignore if the method doesn't exist or isn't accessible
                }
            }
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
