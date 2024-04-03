# bash-scripts

Starting to delve into the world of Linux and BASH after getting a taste for automation and scripting from using PowerShell. Most likely these scripts will be laughably bad, and are nothing more than idle amusements to satisfy my own curiosity.

## rsync_backup.sh
Small tool built using rsync to perform incremental backups by making use of the `--link-dest` feature. It allows for specificaiton of a number of retention points, and will remove items that have passed this point. So, for example, you can tell it to only keep the 5 most recent backup jobs. Additionally on the first time it is called, it will send whole-file backups which (supposedly) yeilds a faster first-run experience.
