
This script installs Chkrootkit, rkhunter, xterm, gnome-terminal, cron and netstat in your system if not present and runs them. 
It saves the logs in /home/$USER/Documents/Logs directory. 
If you wish to save logs to a desired directory, please check the staging file in config directory.

After cloning the repository, run the "init" bash script present in the directory only once. 
That script adds the "startup" script and config file to "/usr/local/bin" folder.
Then, It creates a cronjob to run the script after every reboot.

Don't forget to change permissions of all the files in this repo , you can do that using the following command. Run the command only while you are in the scripts directory.

chmod 755 * 

mail : prudhvir14@pm.me
