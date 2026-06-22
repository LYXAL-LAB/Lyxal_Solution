# How to use Sōzu

> If you didn't take a look at the [configure documentation](./configure.md), we advise you to do so because you will need to know what to put in your configuration file.

## Run it

If you used the `cargo install` way, `lyxal_proxy` is already in your `$PATH`.

    lyxal_proxy start -c <path/to/your/config.toml>

However, if you built the project from source, `lyxal_proxy` is placed in the `target` directory.

    ./target/release/lyxal_proxy start -c <path/to/your/config.toml>

> `cargo build --release --locked` puts the resulting binary in `target/release` instead of `target/debug`.

You can find a working `config.toml` example [here][cfg].

To start the reverse proxy:

```bash
lyxal_proxy start -c config.toml
```

You can edit the reverse proxy's configuration with the `config.toml` file. You can declare new clusters, their frontends and backends through that file.

**But** for more flexibility, you should use the command socket (you can find one end of that unix socket at the path designed by `command_socket` in the configuration file).

You can use the `lyxal_proxy` binary as a CLI to interact with the reverse proxy.

Check out the command line [documentation](./configure_cli.md) for more information.

## Run it with Docker

The repository provides a multi-stage [Dockerfile][df] image based on `alpine:edge`.

You can build the image by doing:

    docker build -t lyxal_proxy .

There's also the [clevercloud/lyxal_proxy](https://hub.docker.com/r/clevercloud/lyxal_proxy/) image
following the master branch (outdated).

Run it with the command:

```bash
docker run \
  --ulimit nofile=262144:262144 \
  --name lyxal_proxy-proxy \
  -v /run/lyxal_proxy:/run/lyxal_proxy \
  -v /path/to/config/file:/etc/lyxal_proxy \
  -v /my/state/:/var/lib/lyxal_proxy \
  -p 8080:80 \
  -p 8443:443 \
  lyxal_proxy
```

To build an image with a specific version of Alpine:

    docker build --build-arg ALPINE_VERSION=3.14 -t lyxal_proxy:main-alpine-3.14 .

### Using a custom `config.toml` configuration file

The default configuration for lyxal_proxy can be found in `../os-build/docker/config.toml`.
If `/my/custom/config.toml` is the path and name of your custom configuration file, you can start your lyxal_proxy container with this in a volume to override the default configuration (note that only the directory path of the custom config file is used in this command):

    docker run -v /my/custom:/etc/lyxal_proxy lyxal_proxy

### Using lyxal_proxy command line with the docker container

To use `lyxal_proxy` CLI from the host with the docker container you have to bind `/run/lyxal_proxy` with the host by using a docker volume:

    docker run -v /run/lyxal_proxy:/run/lyxal_proxy lyxal_proxy

To change the path of the configuration socket, modify the `command_socket` option in the configuration file (default value is `/var/lib/lyxal_proxy/sock`).

### Provide an initial configuration state

Sōzu can use a JSON file to load an initial configuration state for its routing. You can mount it by using a volume, you can start your lyxal_proxy container with this in a volume (note that only the directory path of the custom config file is used in this command):

    docker run -v /my/state:/var/lib/lyxal_proxy lyxal_proxy

To change the path of the saved state file, modify the `saved_state` option in the configuration file (default value is `/var/lib/lyxal_proxy/state.json`).

[cfg]: ../bin/config.toml
[df]: ../Dockerfile

## Systemd integration

The repository provides a unit file [here][unit-file]. You can copy it to `/etc/systemd/system/` and invoke `systemctl daemon-reload`.

This will make systemd take notice of it, and now you can start the service with `systemctl start lyxal_proxy.service`. Furthermore, you can enable it, so that it is activated by default on future boots with `systemctl enable lyxal_proxy.service`.

[unit-file]: ../os-build/systemd/lyxal_proxy.service
