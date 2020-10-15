#!/bin/sh -e


PLUGINS_LOCKFILE="$JENKINS_HOME/.plugins_processed.lock"
INIT_SCRIPTS_LOCKFILE="$JENKINS_HOME/.init_scripts_processed.lock"

USE_JENKINS_PLUGIN_CLI=${USE_JENKINS_PLUGIN_CLI:-no}
JENKINS_PLUGIN_CLI="/bin/jenkins-plugin-cli"

EXTRA_PLUGINS_FILE=${EXTRA_PLUGINS_FILE:-}
EXTRA_PLUGINS=${EXTRA_PLUGINS:-}

logMessage() {
    echo "==> $1"
}

install_plugins() {
    if [ -x  "${JENKINS_PLUGIN_CLI}" -a "${USE_JENKINS_PLUGIN_CLI}" = "yes" ]; then
        logMessage "Using '$JENKINS_PLUGIN_CLI' for plugin management"
        if [ -n "$EXTRA_PLUGINS_FILE" -a -r "${EXTRA_PLUGINS_FILE}" ]; then
            logMessage "Installing plugins '$EXTRA_PLUGINS_FILE'"
            "${JENKINS_PLUGIN_CLI}" --plugin-file "$EXTRA_PLUGINS_FILE"
        fi

        if [ -n "${EXTRA_PLUGINS}" ]; then
            logMessage "Installing extra plugins '${EXTRA_PLUGINS}'"
            "${JENKINS_PLUGIN_CLI}" --plugins ${EXTRA_PLUGINS}
        fi
    else
        if [ -n "$EXTRA_PLUGINS_FILE" -a -r "${EXTRA_PLUGINS_FILE}" ]; then
            logMessage "Installing plugins from '$EXTRA_PLUGINS_FILE'"
            /usr/local/bin/install-plugins.sh < "$EXTRA_PLUGINS_FILE"
        fi
        if [ -n "${EXTRA_PLUGINS}" ]; then
            logMessage "Installing extra plugins '${EXTRA_PLUGINS}'"
            /usr/local/bin/install-plugins.sh ${EXTRA_PLUGINS}
        fi
    fi
}

#===========================================================================

if [ ! -e "$PLUGINS_LOCKFILE" ]; then
    install_plugins
    touch "$PLUGINS_LOCKFILE"
fi

if [ -e "$INIT_SCRIPTS_LOCKFILE" ]; then
    echo "==> Init scripts were already run from <${JENKINS_HOME}/init.groovy.d>"
    echo "==> Removing existsing <${JENKINS_HOME}/init.groovy.d/*.groovy> files "
    rm -f "${JENKINS_HOME}/init.groovy.d/"*.groovy
else
    echo "==> Copying '/init.groovy.d' -> '${JENKINS_HOME}/init.groovy.d'"
    cp -r /init.groovy.d "${JENKINS_HOME}/"
    touch "$INIT_SCRIPTS_LOCKFILE"
fi

exec /sbin/tini -- /usr/local/bin/jenkins.sh $@
