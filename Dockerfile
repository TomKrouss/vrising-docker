FROM cm2network/steamcmd:latest as base
LABEL maintainer="Thomas Krouß"

ENV DEBIAN_FRONTEND="noninteractive"
ENV USER="vrising"
ENV SERVERDIR="/home/${USER}/server"
ENV STEAMAPPID=1829350
ENV DATADIR="/home/${USER}/persistentData/"
ENV SETTINGSDIR="/home/${USER}/persistentData/Settings"

USER root

RUN useradd -m -G steam "${USER}" \
    && mkdir -p "${SETTINGSDIR}" \
    && chown -R "${USER}" "${DATADIR}" \
    && chmod -R g+rwx "${STEAMCMDDIR}" \
    && apt-get update -y \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends --no-install-suggests \
        wine \
        xvfb \
        tini \
    && apt-get remove --purge --auto-remove -y \
    && rm -rf /var/lib/apt/lists/*


FROM base as server

USER ${USER}

COPY --chown=${USER} ./ServerGameSettings.json ${SETTINGSDIR}/ServerGameSettings.json
COPY --chown=${USER} ./ServerHostSettings.json ${SETTINGSDIR}/ServerHostSettings.json

RUN mkdir -p "${SERVERDIR}" \
    && cd "${STEAMCMDDIR}" \
    && './steamcmd.sh' +force_install_dir "${SERVERDIR}" +login anonymous +app_update "${STEAMAPPID}" +quit 


FROM server as run

COPY --chown=${USER} ./entrypoint.sh /entrypoint.sh

RUN chmod u+x "/entrypoint.sh"

ENTRYPOINT ["/usr/bin/tini", "--", "/entrypoint.sh"]