FROM maven:3.9.7-eclipse-temurin-21 AS build
WORKDIR /workspace
COPY . .
RUN mvn -pl services/gateway-bff -am -DskipTests package

FROM eclipse-temurin:21-jre
LABEL org.opencontainers.image.title="glx-gateway-bff"
RUN apt-get update && apt-get install -y --no-install-recommends curl && rm -rf /var/lib/apt/lists/* \
    && useradd --create-home --uid 10001 glx && mkdir /tmp/glx && chown -R glx:glx /tmp/glx
WORKDIR /app
COPY --from=build /workspace/services/gateway-bff/target/gateway-bff-0.1.0-SNAPSHOT.jar app.jar
USER 10001
ENV JAVA_TOOL_OPTIONS="-Djava.io.tmpdir=/tmp/glx"
EXPOSE 8080
HEALTHCHECK --interval=10s --timeout=3s --retries=20 CMD curl --fail http://localhost:8080/actuator/health/readiness
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
