FROM openjdk:8-jdk

RUN apt-get update && apt-get install -y wget unzip

RUN wget --quiet https://services.gradle.org/distributions/gradle-4.0-bin.zip \
    && unzip gradle-4.0-bin.zip

COPY . .

RUN gradle-4.0/bin/gradle --stacktrace --no-daemon shadowJar

CMD java -jar build/libs/groovy-client-all.jar
