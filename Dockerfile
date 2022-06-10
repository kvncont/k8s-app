FROM mcr.microsoft.com/openjdk/jdk:11-ubuntu AS build

WORKDIR /workspace/app

COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .
COPY src src

RUN ./mvnw package
RUN mkdir -p target/dependency && (cd target/dependency; jar -xf ../*.jar)


FROM mcr.microsoft.com/openjdk/jdk:11-ubuntu

VOLUME /tmp

ARG DEPENDENCY=/workspace/app/target/dependency

COPY --from=build ${DEPENDENCY}/BOOT-INF/lib /app/lib
COPY --from=build ${DEPENDENCY}/META-INF /app/META-INF
COPY --from=build ${DEPENDENCY}/BOOT-INF/classes /app

ENTRYPOINT ["java","-cp","app:app/lib/*","com.github.kvncont.k8s.app.Application"]