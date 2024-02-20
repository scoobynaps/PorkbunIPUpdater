# Porkbun IP Updater

Porkbun IP Updater - Version 1.0

This Windows PowerShell script will help you update your dynamic IP address for Porkbun.  The script runs using Windows Task Scheduler and has the ability to create log files and send an email when it is determined there is an IP address update. It uses SendGrid to send the emails.  SendGrid's free account works well with the script.  Both log file creation and emails are an optional feature and are not required if you just want the script to update your IP address.

Please review the configuration descriptions at the top of the script for what each parameter does.  Also, please review the settings for Task Scheduler and understand that you may have to change your PowerShell execution policy to "remotesigned" or another less restrictive policy for this script to work.

It's pretty straight forward.  Have fun and enjoy!

If you find any bugs, let me know.
