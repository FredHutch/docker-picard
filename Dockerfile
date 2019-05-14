FROM openjdk:8 

ARG build_command=shadowJar
ARG jar_name=picard.jar

# Install ant, git for building
RUN apt-get update && \
    apt-get --no-install-recommends install -y --force-yes \
    git \
    r-base \
    ant && \
    apt-get clean autoclean && \
    apt-get autoremove -y

# Assumes Dockerfile lives in root of the git repo. Pull source files into container
WORKDIR /usr/
RUN git clone https://github.com/broadinstitute/picard.git

# Check out a specific release by its tag
WORKDIR /usr/picard
RUN git fetch --all --tags && \
    git checkout tags/2.20.1

# Build the distribution jar, clean up everything else
RUN ./gradlew ${build_command} && \
    mv build/libs/${jar_name} picard.jar && \
    mv src/main/resources/picard/docker_helper.sh docker_helper.sh && \
    ./gradlew clean && \
    rm -rf src && \
    rm -rf gradle && \
    rm -rf .git && \
    rm gradlew && \
    rm build.gradle