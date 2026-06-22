# Configuring lyxal_proxy via command line

The lyxal_proxy executable can be used to start the proxy, and configure it: adding new backend servers, reading metrics, etc.
It talks to the currently running proxy through a unix socket.

You can specify its path by adding to your `config.toml`:

```toml
command_socket = "path/to/your/command_folder/sock"
```

## Add a cluster with an http and https frontends

First you need to create a new cluster with an id and a load balancing policy (roundrobin or random):

```bash
lyxal_proxy --config /etc/lyxal_proxy/config.toml cluster add --id <my_cluster_id> --load-balancing-policy roundrobin
```

It won't show anything but you can verify that the cluster has been added successfully by querying lyxal_proxy:

```bash
lyxal_proxy --config /etc/lyxal_proxy/config.toml query clusters
```

Then you need to add a backend:

```bash
lyxal_proxy --config /etc/lyxal_proxy/config.toml backend add --address 127.0.0.1:3000 --backend-id <my_backend_id> --id <my_cluster_id>
```

### Add http frontend

And an http listener:

```bash
lyxal_proxy --config /etc/lyxal_proxy/config.toml listener http add --address 0.0.0.0:80 --tls-versions TLSv1.2 --tls-cipher-list ECDHE-ECDSA-AES256-GCM-SHA384 --tls-cipher-suites TLS_AES_256_GCM_SHA384 --tls-signature-algorithms ECDSA+SHA512 --tls-groups-list x25519 --expect-proxy
```

Finally you have to create a frontend to allow lyxal_proxy to send traffic from the listener to your backend:

```bash
lyxal_proxy --config /etc/lyxal_proxy/config.toml frontend http add --address 0.0.0.0:80 --hostname <my_cluster_hostname> id <my_cluster_id>
```

### Add https frontend

And an https listener:

```bash
lyxal_proxy --config /etc/lyxal_proxy/config.toml listener https add --address 0.0.0.0:443
```

Finally you have to create a frontend to allow lyxal_proxy to send traffic from the listener to your backend:

```bash
lyxal_proxy --config /etc/lyxal_proxy/config.toml frontend https add --address 0.0.0.0:443 --hostname <my_cluster_hostname> id <my_cluster_id>
```

## Check the status of lyxal_proxy

It shows a list of workers and show information about their statuses.

```bash
lyxal_proxy --config /etc/lyxal_proxy/config.toml status
```

## Get metrics and statistics

It will show global statistics about lyxal_proxy, workers and clusters metrics.

```bash
lyxal_proxy --config /etc/lyxal_proxy/config.toml query metrics
```

## Dump and restore state

If lyxal_proxy configurations (clusters, frontends & backends) are not written in the config file, you can save lyxal_proxy state to restore it later.

```bash
lyxal_proxy --config /etc/lyxal_proxy/config.toml state save --file state.json
```

Then shutdown gracefully lyxal_proxy:

```bash
lyxal_proxy --config /etc/lyxal_proxy/config.toml shutdown
```

Restart lyxal_proxy and restore its state:

```bash
lyxal_proxy --config /etc/lyxal_proxy/config.toml state load --file state.json
```

You should be able to request your cluster like before the shutdown.

### Monitor status of backends with events

This CLI command:

```bash
lyxal_proxy --config /path/to/config.toml events
```

listens to events sent by Sōzu workers whenever a backend is down, up again,
or when no backend is available.
