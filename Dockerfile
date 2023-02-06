FROM rubensa/ubuntu-tini:22.04 as base
LABEL maintainer="Thomas Krouß"

ENV DEBIAN_FRONTEND="noninteractive"
ENV USER="vrising"
ENV SERVERDIR="/home/${USER}/server"
ENV STEAMCMDDIR="/home/${USER}/steamcmd"
ENV STEAMAPPID=1829350
ENV DATADIR="/home/${USER}/persistentData/"
ENV SETTINGSDIR="/home/${USER}/persistentData/Settings"

RUN useradd -m "${USER}" \
    && mkdir -p "${SETTINGSDIR}" \
    && chown -R "${USER}" "${DATADIR}" \
    && dpkg --add-architecture i386 \
    && apt-get update -y \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends --no-install-suggests \
        lib32gcc-s1 \
        ca-certificates \
        locales \
        curl \
        wine \
        xvfb \
    && sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
    && dpkg-reconfigure locales \
    && apt-get remove --purge --auto-remove -y \
    && rm -rf /var/lib/apt/lists/*


FROM base as steamcmd

USER ${USER}

RUN mkdir -p "${STEAMCMDDIR}" \
    && cd "${STEAMCMDDIR}" \
    && curl -fsSL 'https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz' | tar -xvzf - \
    && './steamcmd.sh' +quit


FROM steamcmd as server
 
RUN mkdir -p "${SERVERDIR}" \
    && cd "${STEAMCMDDIR}" \
    && './steamcmd.sh' +force_install_dir "${SERVERDIR}" +login anonymous +app_update "${STEAMAPPID}" +quit

COPY --chown=${USER} ./entrypoint.sh /entrypoint.sh
COPY --chown=${USER} ./ServerGameSettings.json ${SETTINGSDIR}/ServerGameSettings.json
COPY --chown=${USER} ./ServerHostSettings.json ${SETTINGSDIR}/ServerHostSettings.json

RUN chmod u+x "/entrypoint.sh"

ENTRYPOINT ["/usr/local/bin/tini", "--", "/entrypoint.sh"]