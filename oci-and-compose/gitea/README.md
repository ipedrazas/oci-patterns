# Docker Compose and OCI - Gitea with Postgres

This compose file runs a [gitea](https://gitea.com) server with a postgres database as the backend. It has a `profile` that allows you to execute certain services by default (`gitea` and `db`) and others that you can call explicitly.

```
docker compose up -d
```

This commands creates the gitea server and the postgres server. If it's the first time, go and configure it, default settings are fin. The first user that you register becomes the `admin`. Once it's up and running, create a couple of repositories.

Now, go back to the terminal and execute:

```
docker compose run push-data
```

This command is going to back up the postgres database and push that backup to Docker Hub as an OCI image. Once the image has been pushed, the backup is complete. Stop the containers by running:

```
docker compose down
```

And delete the database volume. This volume contains the data that you have created. Now, let's destroy the volume:

```
docker volume rm gitea_db_data
```

and start the compose file again:

```
docker compose up -d
```

Go back to the UI and check that you cannot login with your user. Head to the terminal and do

```
docker compose run restore
```

Once it's finished, go to the UI and try to log back in. You should see the repos that you had created earlier.

The point of this exercise is not to show how to backup and restore a database using compose, but to illustrate the possibilities of using OCI as a remote Data Store.

## Troubleshooting

If you get an error similar to this one:

```
docker compose run restore
[+] Running 2/0
 ⠿ Container gitea-db-1         Running                                                                                                                        0.0s
 ⠿ Container gitea-data-pull-1  Created                                                                                                                        0.0s
[+] Running 0/0
 ⠋ Container gitea-data-pull-1  Starting                                                                                                                       0.0s
Error response from daemon: network b8a2c03948163f6668562900288c507068e563c54b504e13af8f3d111cd7a3c2 not found
```

Try to start compose with the `--force-recreate` flag after pruning the system:

```
docker compose down
docker system prune
docker compose up -d --force-recreate
```

And then execute the restore command, the error should not happen again.
