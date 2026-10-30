FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /workspace
COPY pom.xml .
RUN mvn -q -DskipTests dependency:go-offline
COPY src src
RUN mvn -q package

FROM amazoncorretto:21-al2023-headless
ARG SIGNING_HELPER_VERSION=1.8.5
# TARGETARCH is empty with the legacy builder (no buildx), so detect it at runtime.
RUN case "$(uname -m)" in \
         x86_64) helper_arch="X86_64"; helper_sha256="beec9ed1c492d93db809890f16713e3556353294b823c2184ad4e891f1b2b54d" ;; \
         aarch64) helper_arch="Aarch64"; helper_sha256="3d131aa888cd56da446f9c6bb460b1f0569f6c7edc74eae6193a2fe3928883ba" ;; \
         *) echo "Unsupported architecture: $(uname -m)" && exit 1 ;; \
       esac \
    && curl --fail --location --output /usr/local/bin/aws_signing_helper \
       "https://rolesanywhere.amazonaws.com/releases/${SIGNING_HELPER_VERSION}/${helper_arch}/Linux/Amzn2023/aws_signing_helper" \
    && echo "${helper_sha256}  /usr/local/bin/aws_signing_helper" | sha256sum -c - \
    && chmod 0755 /usr/local/bin/aws_signing_helper
WORKDIR /app
COPY --from=build /workspace/target/*.jar app.jar
COPY docker/entrypoint.sh /entrypoint.sh
RUN chmod 0755 /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]