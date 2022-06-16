FROM eclipse-temurin:11-jre-alpine as build
WORKDIR /workspace/app
COPY target/*.jar target/
RUN mkdir target/extracted
RUN java -Djarmode=layertools -jar target/*.jar extract --destination target/extracted

FROM eclipse-temurin:11-jre-alpine
ARG EXTRACTED=/workspace/app/target/extracted
VOLUME /tmp
EXPOSE 8080
RUN addgroup -S k8s && adduser -S k8s -G k8s
USER k8s
COPY --from=build ${EXTRACTED}/dependencies/ ./
COPY --from=build ${EXTRACTED}/spring-boot-loader/ ./
COPY --from=build ${EXTRACTED}/snapshot-dependencies/ ./
COPY --from=build ${EXTRACTED}/application/ ./
ENTRYPOINT ["java","org.springframework.boot.loader.JarLauncher"]