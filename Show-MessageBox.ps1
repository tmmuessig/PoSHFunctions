Function Show-MessageBox
{
    [CmdletBinding()]
    Param
    (
        [Parameter()]
        [String]
        $Title,

        [Parameter()]
        [String]
        $Message,

        [Parameter()]
        # [Enum]::GetNames([System.Windows.Forms.MessageBoxButtons])
        [ValidateSet('OK', 'OKCancel', 'AbortRetryIgnore', 'YesNoCancel', 'YesNo', 'RetryCancel')]
        [String]
        $Button = 'OK',

        [Parameter()]
        # [Enum]::GetNames([System.Windows.Forms.MessageBoxIcon])
        [ValidateSet('None', 'Hand', 'Error', 'Stop', 'Question', 'Exclamation', 'Warning', 'Asterisk', 'Information')]
        [String]
        $Icon = 'Information'
    )

    Begin
    {
        #add the type so we can access Windows.Forms
        Add-Type -AssemblyName System.Windows.Forms
    }

    Process
    {
        # The items in the Show must be in this specific order
        [System.Windows.Forms.MessageBox]::Show($Message, $Title, $Button, $Icon)
    }

    End
    {

    }
}
