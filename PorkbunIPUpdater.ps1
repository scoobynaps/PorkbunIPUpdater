
# **********************************
# PORKBUN IP UPDATER - VERSION 1.0 *
# **********************************

# ******************************************************************************
# *                         CONFIGURATION DESCRIPTIONS                         *
# ******************************************************************************

# PorkbunAPIKey = API key from Porkbun
# --------------------------------------------------------------------------
# PorkbunSecretKey = Secret key from Porkbun
# --------------------------------------------------------------------------
# PorkbunDomain = Domain without the subdomain. Example: "yourdomain.com"
# --------------------------------------------------------------------------
# PorkbunType = Type of record you want to update. This is most likely an
#               "A" record.
# --------------------------------------------------------------------------
# PorkbunSubdomain = Subdomain that needs updated. Example: "www" or
#                    "johnscomputer" where the full address would be
#                    www.yourdomain.com or johnscomputer.yourdomain.com.
# --------------------------------------------------------------------------
# PorkbunTTL = Porkbun does not support below 600. Leave at default 600
#              setting unless you need to change it for some reason.
# --------------------------------------------------------------------------
# CreateLogFile = This will create a log file at the specified path.
#                 This can be set to "true" or "false".
# --------------------------------------------------------------------------
# DetailedLogs = This can be "true" or "false".  Leave at false unless you
#                need detailed logs for troubleshooting.
# --------------------------------------------------------------------------
# LogFilePath = Location where log files should be stored locally.  You
#               must include the ending "\" in the path. Do not store
#               anything other than log files in this directory since any
#               files will be deleted based on what you specify for
#               "DeleteLogsAfter".
# --------------------------------------------------------------------------
# DeleteLogsAfter = Any files in the "LogPath" will be deleted after the
#                   number of days specified.  Only store log files in the
#                   "LogPath".
# --------------------------------------------------------------------------
# SendIPChangeEmail = Use SendGrid to send an email when there is an IP
#                     update. This can be "true" or "false". This
#                     parameter is optional. NOTE: If set to "false", the
#                     rest of the email settings can be skipped.
# --------------------------------------------------------------------------
# SendGridAPIKey = API key from SendGrid
# --------------------------------------------------------------------------
# FromEmail = The SendGrid email address you are sending emails from. This
#             should have the same domain name if you want SPF and DKIM
#             to pass and prevent your emails from being marked as spam.
#             Example: Domain "yourdomain.com" would have a from address
#             of "johndoe@yourdomain.com". 
# --------------------------------------------------------------------------
# FromName = This is the display name of the sender. You can make this
#            whatever you want.  Example: John Doe
# --------------------------------------------------------------------------
# ToEmail = This is the email address of the recipient you are sending
#           the email to.
# --------------------------------------------------------------------------
# ToName = This is the display name of the recipient. You can make this
#          whatever you want.  Example: Jane Doe
# --------------------------------------------------------------------------
#
# NOTE: IF THE WAN IP OR DOMAIN IP IS NOT DETECTED THIS SCRIPT WILL EXIT
#       TO PREVENT INACCURATE LOG FILES OR EMAILS. IF LOG FILES AND/OR
#       EMAIL IS ENABLED AND YOU ARE NOT RECEIVING EITHER, USE POWERSHELL
#       TO RUN THIS SCRIPT TO SEE IF ONE OF THE IP ADDRESSES IS NOT BEING
#       DETECTED PROPERLY.

# ******************************************************************************
# *                       START CONFIGURATION EDITS HERE                       *
# ******************************************************************************

# ------------------
# PORKBUN SETTINGS -
#-------------------

$PorkbunAPIKey = "porkbun-api-key-here"
$PorkbunSecretKey = "porkbun-secret-key-here"
$PorkbunDomain = "yourdomain.com"
$PorkbunType = "A"
$PorkbunSubdomain = "www"
$PorkbunTTL = "600"

# -----------------------------
# LOG FILE SETTINGS (OPTIONAL -
#------------------------------

$CreateLogFile = "false"
$DetailedLogs = "false"
$LogFilePath = 'C:\Files\PorkbunIPUpdater\Logs\'
$DeleteLogsAfter = "30"

# ---------------------------
# EMAIL SETTINGS (OPTIONAL) -
#----------------------------
 
$SendIPChangeEmail = "false"
$SendGridAPIKey = "sendgrid-api-key-here"
$FromEmail = "sender@yourdomain.com"
$FromName = "Sender Name"
$ToEmail = "recipient@whatever.com"
$ToName = "Recipient Name"

# ******************************************************************************
# *                        END CONFIGURATION EDITS HERE                        *
# ******************************************************************************

# ******************************************************************************
# *                  !!!!! DO NOT EDIT BELOW THIS POINT !!!!!                  *
# *                                                                            *
# *                                 START CODE                                 *
# ******************************************************************************

# ----------------------------------------
# CREATE FUNCTION TO DISPLAY INFORMATION -
# ----------------------------------------

$ShowIPDetails = $(

$script:UseBasic = @{UseBasicParsing=$true}

# --------------------
# GET CURRENT WAN IP -
# --------------------

$RequestBody = "{`"secretapikey`": `"$PorkbunSecretKey`", `"apikey`": `"$PorkbunAPIKey`"}"
$queryParams = @{
                 Uri = "https://api.porkbun.com/api/json/v3/ping"
                 Method = 'POST'
                 Body = $RequestBody
                 ErrorAction = 'Stop'
                }
$response = Invoke-RestMethod @queryParams @script:UseBasic
$wip = $response.yourIp

# -----------------------
# GET CURRENT DOMAIN IP -
# -----------------------

$queryParams = @{
                 Uri = "https://api.porkbun.com/api/json/v3/dns/retrieveByNameType/$PorkbunDomain/$PorkbunType/$PorkbunSubdomain"
                 Method = 'POST'
                 Body = $RequestBody
                 ErrorAction = 'Stop'
                }
$response = Invoke-RestMethod @queryParams @script:UseBasic
$dip = $response.records.content

# *** WRITE THE RESULTS OR EXIT SCRIPT IF WAN IP OR DOMAIN IP IS BLANK ***
if (-not [string]::IsNullOrWhiteSpace($wip) -and -not [string]::IsNullOrWhiteSpace($dip)) {
                                                                                      echo "WAN IP: $wip"
                                                                                      echo "Domain IP: $dip"
                                                                                     }
else {
      if (-not [string]::IsNullOrWhiteSpace($wip)) {
                                                    echo "WAN IP: $wip"
                                                   }
      else {
            echo "WAN IP: NOT DETECTED!"
           }
      if (-not [string]::IsNullOrWhiteSpace($dip)) {
                                                    echo "Domain IP: $dip"
                                                   }
      else {
            echo "Domain IP: NOT DETECTED!"
           }
      exit
     }

# -------------------------------------------------------------
# COMPARE CURRENT WAN IP TO DOMAIN IP AND UPDATE IF NOT EQUAL -
# -------------------------------------------------------------

if ($wip -ne $dip) {
	$RequestBody = "{`"secretapikey`": `"$PorkbunSecretKey`", `"apikey`": `"$PorkbunAPIKey`", `"content`": `"$wip`", `"ttl`": `"$PorkbunTTL`"}"
	$queryParams = @{
			 Uri = "https://api.porkbun.com/api/json/v3/dns/editByNameType/$PorkbunDomain/$PorkbunType/$PorkbunSubdomain"
			 Method = 'POST'
			 Body = $RequestBody
			 ErrorAction = 'Stop'
		        }
	$response = Invoke-RestMethod @queryParams @script:UseBasic
	
        # *** WRITE THE RESULTS ***
        echo $response
}

else {
      # *** WRITE THE RESULTS ***
      echo "CURRENT IP MATCHES RECORDED IP. NO UPDATE REQUIRED!"
     }
)

# -------------------------------------
# END FUNCTION TO DISPLAY INFORMATION - 
# -------------------------------------

# ------------------------------------------------------------
# DISPLAY INFORMATION (FOR OUTPUT TO POWERSHELL WINDOW ONLY) -
# ------------------------------------------------------------

# *** WRITE THE RESULTS ***
if ($CreateLogFile -eq "true" -and $DetailedLogs -eq "true") {
                                                              # Do not display since Start-Transcript will display output
                                                             }
else {
      echo $ShowIPDetails
     }

# -----------------------------------
# GET DATE AND CREATE LOG FILE NAME -
# -----------------------------------

$LogDate = Get-Date -format 'MMddyyy_HHmmss'

if ($wip -ne $dip) {
                    $LogFileName = 'log_' + $LogDate + ' - updated.txt'
                   }
else {
      $LogFileName = 'log_' + $LogDate + '.txt'
     }

# ------------------------------------
# CREATE SIMPLE OR DETAILED LOG FILE -
# ------------------------------------

if ($CreateLogFile -eq "true") {
                               if ($DetailedLogs -eq "true") {
                                                              # *** WRITE THE RESULTS ***
                                                              Start-Transcript -Path ($LogFilePath + $LogFileName)
                                                              $ShowIPDetails
                                                              Stop-Transcript
                                                             }
                               else {
                                     # *** WRITE THE RESULTS ***
                                     echo $ShowIPDetails | Out-File ($LogFilePath + $LogFileName)
                                    }
                              }
else {
      # Do not write log file
     }


# ------------
# SEND EMAIL -
# ------------

if ($wip -ne $dip -and $SendIPChangeEmail -eq "true") {

# ******************************************************************************
# *                             START EMAIL SCRIPT                             *
# ******************************************************************************

function Send-SendGridEmail {

                             param(
                                   [Parameter(Mandatory = $true)]
                                   [String] $RecipientEmail,
                                   [Parameter(Mandatory = $true)]
                                   [String] $RecipientName,
                                   [Parameter(Mandatory = $true)]
                                   [String] $subject,
                                   [Parameter(Mandatory = $false)]
                                   [string]$contentType = 'text/plain',
                                   [Parameter(Mandatory = $true)]
                                   [String] $contentBody
                                  )

                             $apiKey = $SendGridAPIKey
                             $SenderEmail = $FromEmail
                             $SenderName = $FromName
                             $headers = @{
                                          'Authorization' = 'Bearer ' + $apiKey
                                          'Content-Type'  = 'application/json'
                                         }
  
                             $body = @{
                                       personalizations = @(
                                                            @{
                                                              to = @(
                                                                     @{
                                                                       email = $RecipientEmail
                                                                       name = $RecipientName
                                                                      }
                                                                    )
                                                             }
                                                           )
                                       from = @{
                                                email = $SenderEmail
                                                name = $SenderName
                                               }
                                       subject = $subject
                                       content = @(
                                                   @{
                                                     type  = $contentType
                                                     value = $contentBody
                                                    }
                                                  )
                                      }
  
                             try {
                                  $bodyJson = $body | ConvertTo-Json -Depth 4
                                 }
                             catch {
                                    $ErrorMessage = $_.Exception.message
                                    write-error ('Error converting body to json ' + $ErrorMessage)
                                    Break
                                   }
  
                             try {
                                  Invoke-RestMethod -Uri https://api.sendgrid.com/v3/mail/send -Method Post -Headers $headers -Body $bodyJson 
                                 }
                             catch {
                                    $ErrorMessage = $_.Exception.message
                                    write-error ('Error with Invoke-RestMethod ' + $ErrorMessage)
                                    Break
                                   }
                            }

# ---------------------
# BUILD EMAIL MESSAGE -
# ---------------------

$htmlBody = @"
Hello,
<br /><br />
The Porkbun IP address for $PorkbunSubdomain.$PorkbunDomain has been updated.
<br /><br />
OLD: $dip<br />
NEW: $wip
"@

$splat = @{
           RecipientEmail = $ToEmail
           RecipientName = $ToName
           subject = 'Porkbun IP Address Updated for ' + $PorkbunSubdomain + '.' + $PorkbunDomain
           contentType = 'text/html'
           contentBody = $htmlBody
          }

# ---------------------
# SEND EMAIL MESSAGE  -
# ---------------------

Send-SendGridEmail @splat

# ******************************************************************************
# *                              END EMAIL SCRIPT                              *
# ******************************************************************************

                                                      }
else {
      # No change and do not send email
     }

# ----------------------
# DELETE OLD LOG FILES -
# ----------------------

if ($CreateLogFile -eq "true") {
                               Get-ChildItem -Path $LogFilePath | Where-Object {$_.LastWriteTime -lt (Get-Date).AddDays(-$DeleteLogsAfter)} | Remove-Item -Verbose
                              }
else {
      # Do not delete old log files
     }

# ******************************************************************************
# *                                  END CODE                                  *
# ******************************************************************************
