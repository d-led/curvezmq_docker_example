FROM gradle:latest

COPY . .

RUN gradle --stacktrace --no-daemon shadowJar

CMD java -jar build/libs/groovy-client-all.jar
