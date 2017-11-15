#!/bin/bash
# Default config
BASEDIR="."
BACKUPS_DIR=$BASEDIR/"data/backups"
BACKUP_FILE="dump`date +%d%b%Y`.sql.gz"
BACKUP_PATH=$BACKUPS_DIR/$BACKUP_FILE
ERROR_LOG_FILE=$BASEDIR/"data/logs/backup.log"

# Mail options
TO=''
SUBJECT="Database backup"
MESSAGE="The database backup has been created `date +%c`."

# DB config
DB_HOST="localhost"
DB_USER=""
DB_PASS=""
DB_NAME=""

# # Init DB config from file
# DOCTRINE_CONFIG_FILE=$BASEDIR/'config/autoload/doctrine.local.php'
# # Check if file exists or not
# if [ -f "$DOCTRINE_CONFIG_FILE" ]; then
#     # Init database config
#     DB_USER=$(grep -oP "'user'.+?'\K[^']+" $DOCTRINE_CONFIG_FILE)
#     DB_PASS=$(grep -oP "'password'.+?'\K[^']+" $DOCTRINE_CONFIG_FILE)
#     DB_HOST=$(grep -oP "'host'.+?'\K[^']+" $DOCTRINE_CONFIG_FILE)
#     DB_NAME=$(grep -oP "'dbname'.+?'\K[^']+" $DOCTRINE_CONFIG_FILE)
# else
#     echo "$DOCTRINE_CONFIG_FILE not found."
#     exit 1
# fi

# Check if directory exists or not
if [ ! -d "$BACKUPS_DIR" ]; then
    # Create the directory
    mkdir $BACKUPS_DIR
    # Permission
    chmod 755 $BACKUPS_DIR
    chown -R $(whoami):$(whoami) $BACKUPS_DIR
    # Add .gitignore file into the new backups dir
    echo "*\r\n!.gitignore" >> "$BACKUPS_DIR/.gitignore"
fi

# Check database config
if [ -z "$DB_USER" ] || [ -z "$DB_PASS" ] || [ -z "$DB_HOST" ] || [ -z "$DB_NAME" ]; then
    echo "Database config is undefined" >> $ERROR_LOG_FILE
    exit 1
else
    #create backup
    mysqldump -u$DB_USER -h$DB_HOST -p$DB_PASS $DB_NAME 2>> $ERROR_LOG_FILE | gzip -c | cat > $BACKUP_PATH
fi

# Send mail
if [ -z != $TO ]; then
    echo $MESSAGE | mail -s $SUBJECT $TO -A $BACKUP_PATH 2>> $ERROR_LOG_FILE
fi