# the first stage of our build will extract the layers
#FROM eclipse-temurin:17-alpine as builder
FROM eclipse-temurin:17-alpine as builder
WORKDIR demo

# Copy the Maven wrapper 
COPY mvnw .
COPY .mvn .mvn

# Copy application
COPY src src
COPY pom.xml .

#ENTRYPOINT ["tail"]
#CMD ["-f","/dev/null"]

RUN ./mvnw install

COPY target/demo-0.0.1-SNAPSHOT.jar demo.jar
RUN java -Djarmode=layertools -jar demo.jar extract

# the second stage of our build will copy the extracted layers
FROM eclipse-temurin:17-jre-alpine
WORKDIR demo
COPY --from=builder demo/dependencies/ ./
COPY --from=builder demo/spring-boot-loader/ ./
COPY --from=builder demo/snapshot-dependencies/ ./
COPY --from=builder demo/application/ ./
ENTRYPOINT ["java", "org.springframework.boot.loader.JarLauncher"]
