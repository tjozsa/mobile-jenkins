FROM jenkins/jenkins:lts

LABEL maintainer="tjozsa@gmail.com"
LABEL version="1.0"
LABEL description="Custom Mobile Jenkins Master"

USER root

COPY jenkins /home/

#install packages for build environemnt setup and Android SDK (32 bit libs)
RUN export DEBIAN_FRONTEND=noninteractive\
 && apt-get update\
 && apt-get dist-upgrade\
 && apt-get install -y unzip python libc6-i386 lib32stdc++6 lib32z1\
 && apt-get autoremove\
 && apt-get clean\
 && rm -rf /var/lib/apt/lists/*

#download android sdk cli

RUN cd /opt && \
	wget --output-document=android-sdk.zip --quiet https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip && \
	unzip -d android-sdk android-sdk.zip && \
	rm -f android-sdk.zip && \
	chown -R jenkins.jenkins android-sdk

ENV ANDROID_HOME=/opt/android-sdk

# Accept licenses before installing components, no need to echo y for each component
# License is valid for all the standard components in versions installed from this file
# Non-standard components: MIPS system images, preview versions, GDK (Google Glass) and Android Google TV require separate licenses, not accepted there
RUN yes | $ANDROID_HOME/tools/bin/sdkmanager --licenses

RUN touch ~/.android/repositories.cfg

# Update and install using sdkmanager 
RUN $ANDROID_HOME/tools/bin/sdkmanager "tools" "platform-tools"
RUN $ANDROID_HOME/tools/bin/sdkmanager "build-tools;28.0.0" "build-tools;27.0.3"
RUN $ANDROID_HOME/tools/bin/sdkmanager "platforms;android-28" "platforms;android-27"
RUN $ANDROID_HOME/tools/bin/sdkmanager "extras;android;m2repository" "extras;google;m2repository"

ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/jenkins.sh"]