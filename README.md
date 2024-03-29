# ha-backup

**Use with care, this script also removes files** 

Backup script for home assistant using `scp`. 

This script will download .tar files from a remote location using scp. 
it will then delete older (+7 days) backup files from the remote location as well as deleting old local backup files (+30 days)

## Setup

1. generate an ssh key with `ssh-keygen -t ed25519`
2. install `Terminal & SSH` in home assistant
3. add your generated public key in the config tab of `Terminal & SSH`
4. set up an automated backup job in home assistant that creates a new backup every night
5. run ha-backup.sh

## Usage

./ha-backup.sh <user@server> <source directory> <backup directory>

Example:
```
./ha-backup.sh user@github.com /root/backup/ /home/user/backup/
```

## Cron

Schedule as a cron job to run every night at 01:00 with `crontab -e` and add `0 1 * * * /path/to/your/ha-backup.sh <user@server> <source directory> <backup directory>`

## Docker

A sample of what to do to make this run in a docker container. To make use of this, set up a docker volume for `/home/user/backup/`

```
cp ~/.ssh/id_ed25519 .
docker build --build-arg SSH_KEY_FILE=id_ed25519 --build-arg SSH_HOST=server -t ha-backup .
rm id_ed25519
docker run --rm ha-backup root@server /root/backup/ /home/user/backup/
```