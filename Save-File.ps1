Function Save-File
{
    [CmdletBinding()]
    Param
    (
        [String]
        $Path = "C:\"
    )
    Begin
    {
        Add-Type -AssemblyName System.Windows.Forms
    }

    Process
    {
        $OpenFileDialog = New-Object System.Windows.Forms.SaveFileDialog
        if (Test-Path $Path)
        {
            $OpenFileDialog.initialDirectory = $Path
        }
        Else
        {
            $OpenFileDialog.initialDirectory = "C:\"
        }
        $OpenFileDialog.Filter = "All files (*.*)| *.*"
        $OpenFileDialog.ShowDialog() | Out-Null

    }

    End
    {
        Return $OpenFileDialog.FileName
    }
}
