plugins {
    application
}

repositories {
    mavenCentral()
}

// ./gradlew run -PmicronautVersion=4.10.33 to compare with 4.x
val micronautVersion = providers.gradleProperty("micronautVersion").getOrElse("5.2.22")

dependencies {
    implementation("io.micronaut:micronaut-inject:$micronautVersion")
    runtimeOnly("org.slf4j:slf4j-nop:2.0.17")
}

java {
    toolchain {
        languageVersion.set(JavaLanguageVersion.of(25))
    }
}

application {
    mainClass.set("repro.Repro")
}
