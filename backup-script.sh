#!/bin/bash

backup_dir="/home/Backup"
source_dirs="/var/www/ /etc/php /var/lib/mysql"

date_format=$(date -I)

keep_period=90

# SSH Angaben
remote_server="labtam032@10.26.30.32"
remote_dir="/home/labtam032/Backup"
pass_sh='Welcome$21'

if [ ! -d "$backup_dir" ]; then
    mkdir -p "$backup_dir"
fi

# Funktion Inkrementelles Backup
function create_incremental_backup {
    backup_type="incremental"
    backup_file="$backup_dir/$backup_type-$date_format.tar.gz"
        tar -czf "$backup_file" $source_dirs --listed-incremental="$backup_dir/incremental.snar"
}

# Funktion Vollbackup
function create_full_backup {
    backup_type="full"
    backup_file="$backup_dir/$backup_type-$date_format.tar.gz"
    tar -czf "$backup_file" $source_dirs
}

day_of_week=$(date +%u)
if [ $day_of_week -eq 1 ] || [ $day_of_week -eq 5 ]; then
    backup_type="full"
else
    backup_type="incremental"
fi

if [ $backup_type == "incremental" ]; then
    create_incremental_backup
else
    create_full_backup
fi

# Prüfung, ob ein Vollbackup innert 90 Tagen durchgeführt wurde
check_full_backup=$(find . -type f -name "full*" -ctime -$keep_period)

if [ -n "$check_full_backup"]; then
        find "$backup_dir" -type f -name "*.tar.gz" -mtime +$keep_period -exec rm -rf -- {} \;
        sshpass -p $pass_ssh ssh $remote_server 'find /home/labtam032/Backup -type f -name "*.tar.gz" -mtime +'"$keep_period"' -exec rm -rf -- {} \;'
fi

# SSH Verbindung
sshpass -p $pass_ssh scp -P 22 $backup_file $remote_server:$remote_dir
~                                                                          
