function Write-VenafiDebug {

    <#
    .SYNOPSIS
    Write info to the adaptable debug log

    .DESCRIPTION
    Assuming the option has been selected, write info to the adaptable debug log.
    Hashtables are supported and secret info will not be logged, eg. $General.

    .PARAMETER Message
    The info to be logged

    .PARAMETER ThrowException
    After logging the message, throw an exception to terminate the script

    .EXAMPLE
    Write-VenafiDebug -Message 'connected to server'

    Write info to the log

    .EXAMPLE
    $General | Write-VenafiDebug

    Write input parameter values to the log

    .EXAMPLE
    Write-VenafiDebug -Message 'this was not good' -ThrowException

    Write to the log and throw an exception
    #>

    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [psobject] $Message,

        [Parameter()]
        [switch] $ThrowException
    )

    if ( $global:DEBUG_FILE ) {

        $newMessage = $Message
        
        if ( $newMessage.GetType().Name -eq 'Hashtable' ) {
            $newMessage = $Message.Clone()
            'UserPass', 'AuxPass', 'PfxPass', 'Certificate', 'PfxData' | ForEach-Object {
                if ( $newMessage[$_] ) {
                    $newMessage[$_] = '***hidden***'
                }
            }
            $newMessage = $newMessage | ConvertTo-Json -Depth 5
        }

        try {
            # use a mutex to ensure multiple executions of this script don't cause 'file in use' errors
            $mutex = New-Object System.Threading.Mutex($false, [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.ScriptName))
            if ( -not $mutex.WaitOne(0) ) {
                $mutex.WaitOne()
            }
            ('{0} : {1}' -f (Get-Date), ($newMessage | Out-String)) | Out-File -FilePath $global:DEBUG_FILE -Encoding 'UTF8' -Append
        } catch {
            throw $_
        } finally {
            $null = $mutex.ReleaseMutex()
        }
    }

    if ( $ThrowException ) {
        throw $Message
    }
}
