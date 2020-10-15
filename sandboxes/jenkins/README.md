Jenkins sandbox
===============

Jenkins sandbox for quick and isolated testing.

## Getting started

```shell
$ cp docker-compose.override.example.yml docker-compose.override.yml
$ docker-compose up -d jenkins
```

## Configuring

The following environment variables can be used to tune your installation

`ADMIN_USERNAME`, `ADMIN_PASSWORD` - information for creating admin user during the first run.

`EXTRA_PLUGINS_FILE` - path to `plugins.txt` inside container which contains extra plugins to be installed. Default not set.

`EXTRA_PLUGINS` - space separated list of plugins with (possibly) versions to install after the base package. Default not set.

`USE_JENKINS_PLUGIN_CLI` - use modern `jenkins-plugin-cli` (sometimes unstable) plugin manager instead of deprecated `install-plugins.sh`. Default `no`
