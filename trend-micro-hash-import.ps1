 
function Main {
    Param ([String]$Commandline)
                               
          
    if ((Show-MainForm_psf) -eq 'OK') {
                               
    }
               
    $script:ExitCode = 0 #Set the exit code for the Packager
}
 
 
#endregion Source: Startup.pss
 
#region Source: Globals.ps1
#--------------------------------------------
# Declare Global Variables and Functions here
#--------------------------------------------
               
               
#Sample function that provides the location of the script
function Get-ScriptDirectory {
    <#
                                .SYNOPSIS
                                                Get-ScriptDirectory returns the proper location of the script.
               
                                .OUTPUTS
                                                System.String
                               
                                .NOTES
                                                Returns the correct path within a packaged executable.
                #>
    [OutputType([string])]
    param ()
    if ($null -ne $hostinvocation) {
        Split-Path $hostinvocation.MyCommand.path
    }
    else {
        Split-Path $script:MyInvocation.MyCommand.Path
    }
}
               
#Sample variable that provides the location of the script
[string]$ScriptDirectory = Get-ScriptDirectory
               
               
               
               
#endregion Source: Globals.ps1
 
#region Source: MainForm.psf
function Show-MainForm_psf {
    #----------------------------------------------
    #region Import the Assemblies
    #----------------------------------------------
    [void][reflection.assembly]::Load('System.Drawing, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a')
    [void][reflection.assembly]::Load('System.Windows.Forms, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')
    #endregion Import Assemblies
 
    #----------------------------------------------
    #region Generated Form Objects
    #----------------------------------------------
    [System.Windows.Forms.Application]::EnableVisualStyles()
    $formTrendMicroHashImport = New-Object 'System.Windows.Forms.Form'
    $linklabel1 = New-Object 'System.Windows.Forms.LinkLabel'
    $buttonExportCSVReport = New-Object 'System.Windows.Forms.Button'
    $labelHashImportStatus = New-Object 'System.Windows.Forms.Label'
    $listview1 = New-Object 'System.Windows.Forms.ListView'
    $groupbox1 = New-Object 'System.Windows.Forms.GroupBox'
    $buttonValidateHashes = New-Object 'System.Windows.Forms.Button'
    $buttonImportHashes = New-Object 'System.Windows.Forms.Button'
    $textbox2 = New-Object 'System.Windows.Forms.TextBox'
    $labelHashDescription = New-Object 'System.Windows.Forms.Label'
    $textbox1 = New-Object 'System.Windows.Forms.TextBox'
    $labelTrendMicroHashImport = New-Object 'System.Windows.Forms.Label'
    $picturebox1 = New-Object 'System.Windows.Forms.PictureBox'
    $columnheader1 = New-Object 'System.Windows.Forms.ColumnHeader'
    $columnheader2 = New-Object 'System.Windows.Forms.ColumnHeader'
    $columnheader3 = New-Object 'System.Windows.Forms.ColumnHeader'
    $columnheader4 = New-Object 'System.Windows.Forms.ColumnHeader'
    $columnheader5 = New-Object 'System.Windows.Forms.ColumnHeader'
    $InitialFormWindowState = New-Object 'System.Windows.Forms.FormWindowState'
    #endregion Generated Form Objects
 
    #----------------------------------------------
    # User Generated Script
    #----------------------------------------------
    # add a helper
    $showWindowAsync = Add-Type -memberDefinition @"
[DllImport("user32.dll")]
public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);
"@ -name "Win32ShowWindowAsync" -namespace Win32Functions -passThru
               
    function Show-PowerShell() {
        [void]$showWindowAsync::ShowWindowAsync((Get-Process -id $pid).MainWindowHandle, 10)
    }
               
    function Hide-PowerShell() {
        [void]$showWindowAsync::ShowWindowAsync((Get-Process -id $pid).MainWindowHandle, 2)
    }
               
               
               
    $formTrendMicroHashImport_Load = {
        #TODO: Initialize Form Controls here
        Write-Host $PSScriptRoot
        # Hide Powershell Windows
        Add-Type -Name Window -Namespace Console -MemberDefinition '
[DllImport("Kernel32.dll")]
public static extern IntPtr GetConsoleWindow();
 
[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
'
        $consolePtr = [Console.Window]::GetConsoleWindow()
        [Console.Window]::ShowWindow($consolePtr, 0) #0 hide
        # -----------------------
                               
    }
               
    #region Control Helper Functions
    function Update-ListViewColumnSort {
                              
        param
        (
            [Parameter(Mandatory = $true)]
            [ValidateNotNull()]
            [System.Windows.Forms.ListView]
            $ListView,
            [Parameter(Mandatory = $true)]
            [int]
            $ColumnIndex,
            [System.Windows.Forms.SortOrder]
            $SortOrder = 'None'
        )
                               
        if (($ListView.Items.Count -eq 0) -or ($ColumnIndex -lt 0) -or ($ColumnIndex -ge $ListView.Columns.Count)) {
            return;
        }
                               
        #region Define ListViewItemComparer
        try {
            [ListViewItemComparer] | Out-Null
        }
        catch {
            Add-Type -ReferencedAssemblies ('System.Windows.Forms') -TypeDefinition  @"
                using System;
                using System.Windows.Forms;
                using System.Collections;
                public class ListViewItemComparer : IComparer
                {
                    public int column;
                    public SortOrder sortOrder;
                    public ListViewItemComparer()
                    {
                        column = 0;
                                                sortOrder = SortOrder.Ascending;
                    }
                    public ListViewItemComparer(int column, SortOrder sort)
                    {
                        this.column = column;
                                                sortOrder = sort;
                    }
                    public int Compare(object x, object y)
                    {
                                                if(column >= ((ListViewItem)x).SubItems.Count)
                                                                return  sortOrder == SortOrder.Ascending ? -1 : 1;
                               
                                                if(column >= ((ListViewItem)y).SubItems.Count)
                                                                return sortOrder == SortOrder.Ascending ? 1 : -1;
                               
                                                if(sortOrder == SortOrder.Ascending)
                               return String.Compare(((ListViewItem)x).SubItems[column].Text, ((ListViewItem)y).SubItems[column].Text);
                                                else
                                                                return String.Compare(((ListViewItem)y).SubItems[column].Text, ((ListViewItem)x).SubItems[column].Text);
                    }
                }
"@ | Out-Null
        }
        #endregion
                               
        if ($ListView.Tag -is [ListViewItemComparer]) {
            #Toggle the Sort Order
            if ($SortOrder -eq [System.Windows.Forms.SortOrder]::None) {
                if ($ListView.Tag.column -eq $ColumnIndex -and $ListView.Tag.sortOrder -eq 'Ascending') {
                    $ListView.Tag.sortOrder = 'Descending'
                }
                else {
                    $ListView.Tag.sortOrder = 'Ascending'
                }
            }
            else {
                $ListView.Tag.sortOrder = $SortOrder
            }
                                               
            $ListView.Tag.column = $ColumnIndex
            $ListView.Sort() #Sort the items
        }
        else {
            if ($SortOrder -eq [System.Windows.Forms.SortOrder]::None) {
                $SortOrder = [System.Windows.Forms.SortOrder]::Ascending
            }
                                               
            #Set to Tag because for some reason in PowerShell ListViewItemSorter prop returns null
            $ListView.Tag = New-Object ListViewItemComparer ($ColumnIndex, $SortOrder)
            $ListView.ListViewItemSorter = $ListView.Tag #Automatically sorts
        }
    }
               
               
               
    function Add-ListViewItem {
                              
        Param(
            [ValidateNotNull()]
            [Parameter(Mandatory = $true)]
            [System.Windows.Forms.ListView]$ListView,
            [ValidateNotNull()]
            [Parameter(Mandatory = $true)]
            $Items,
            [int]$ImageIndex = -1,
            [string[]]$SubItems,
            $Group,
            [switch]$Clear)
                               
        if ($Clear) {
            $ListView.Items.Clear();
        }
                   
        $lvGroup = $null
        if ($Group -is [System.Windows.Forms.ListViewGroup]) {
            $lvGroup = $Group
        }
        elseif ($Group -is [string]) {
            #$lvGroup = $ListView.Group[$Group] # Case sensitive
            foreach ($groupItem in $ListView.Groups) {
                if ($groupItem.Name -eq $Group) {
                    $lvGroup = $groupItem
                    break
                }
            }
                       
            if ($null -eq $lvGroup) {
                $lvGroup = $ListView.Groups.Add($Group, $Group)
            }
        }
                   
        if ($Items -is [Array]) {
            $ListView.BeginUpdate()
            foreach ($item in $Items) {                             
                $listitem = $ListView.Items.Add($item.ToString(), $ImageIndex)
                #Store the object in the Tag
                $listitem.Tag = $item
                                                               
                if ($null -ne $SubItems) {
                    $listitem.SubItems.AddRange($SubItems)
                }
                                                               
                if ($null -ne $lvGroup) {
                    $listitem.Group = $lvGroup
                }
            }
            $ListView.EndUpdate()
        }
        else {
            #Add a new item to the ListView
            $listitem = $ListView.Items.Add($Items.ToString(), $ImageIndex)
            #Store the object in the Tag
            $listitem.Tag = $Items
                                               
            if ($null -ne $SubItems) {
                $listitem.SubItems.AddRange($SubItems)
            }
                                               
            if ($null -ne $lvGroup) {
                $listitem.Group = $lvGroup
            }
        }
    }
               
               
    #endregion
    function ValidateHash {
        param (
            $Hash
        )
                               
        [System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
                               
        $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $headers.Add("api-version", "v1")
        $headers.Add("api-secret-key", "")
        $headers.Add("Content-Type", "application/json")
        $body = @{
            "maxitems"       = 0
            "searchCriteria" = @{
                "fieldName"   = "sha256"
                "stringValue" = "$($hash)"
            }
        }
                               
        $body = $body | ConvertTo-Json
        $response = Invoke-RestMethod 'https://app.deepsecurity.trendmicro.com:443/api/applicationcontrolglobalrules/search' -Method 'POST' -Headers $headers -Body $body
        if ($response.applicationControlGlobalRules.count -ne 0) {
            return $true
        }
        else {
            return $false     
        }
               
    }
               
    $buttonImportHashes_Click = {
        $buttonImportHashes.Text = "Please Wait"
        $buttonImportHashes.Enabled = $false
        [System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
                               
        $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $headers.Add("api-version", "v1")
        $headers.Add("api-secret-key", "")
        $headers.Add("Content-Type", "application/json")
        $hashbody = @{
            applicationControlGlobalRules = @(
                                                               
            )
        }
                               
        $hashes = $textbox1.text -split "`r`n"
                               
        if ($textbox1.Text -ne $null) {
            foreach ($hash in $hashes) {
                if ($hash -ne "") {
                    Start-Sleep -seconds 1
                    $body = @{
                        "maxitems"       = 0
                        "searchCriteria" = @{
                            "fieldName"   = "sha256"
                            "stringValue" = "$($hash)"
                        }
                    }
                                                                               
                    $body = $body | ConvertTo-Json
                                                                               
                                                                               
                                                                               
                    $response = Invoke-RestMethod 'https://app.deepsecurity.trendmicro.com:443/api/applicationcontrolglobalrules/search' -Method 'POST' -Headers $headers -Body $body
                    if ($response.applicationControlGlobalRules.count -eq 0) {
                        $hashbody.applicationControlGlobalRules += @{ "sha256" = $hash; "description" = $textbox2.text; }
                        $item = New-Object System.Windows.Forms.ListViewItem($hash)
                        $item.SubItems.Add($textbox2.text)
                        $item.SubItems.Add("block")
                        $item.SubItems.Add("New Hash")
                        $item.SubItems.Add("")
                        [System.Void]$listView1.Items.AddRange(($item))
                    }
                    else {
                        $item = New-Object System.Windows.Forms.ListViewItem($response.applicationControlGlobalRules.sha256)
                        $item.SubItems.Add($response.applicationControlGlobalRules.description)
                        $item.SubItems.Add($response.applicationControlGlobalRules.action)
                        $item.SubItems.Add("Already Exists")
                        $item.SubItems.Add("")
                        [System.Void]$listView1.Items.AddRange(($item))
                    }
                }
            }
                                               
        }
                               
                               
                               
        if ($hashbody.applicationControlGlobalRules.count -ne 0) {
            try {
                $hashbody = $hashbody | ConvertTo-Json
                $response = Invoke-RestMethod 'https://app.deepsecurity.trendmicro.com:443/api/applicationcontrolglobalrules' -Method 'POST' -Headers $headers -Body $hashbody -ErrorAction SilentlyContinue -ErrorVariable erx -TimeoutSec 300
                [System.Windows.Forms.MessageBox]::Show("Hashes Imported into Trend Micro Successfully", 'TrendMicro Hash Import')
                                                               
            }
            catch {
                [System.Windows.Forms.MessageBox]::Show("Hash Import Failed!", 'TrendMicro Hash Import')
                $msg = $_.errordetails.Message
                Write-Host $msg
            }
                                               
            $response | ConvertTo-Json | out-file "output.txt"
        }
                               
                               
                               
        $buttonImportHashes.Text = "Import Hashes"
        $buttonImportHashes.Enabled = $true
    }
               
    $textbox1_TextChanged = {
        #TODO: Place custom script here
                               
    }
               
    $buttonExportCSVReport_Click = {
        $time = (Get-Date).ToString("MM-dd-yyyy-hh-mm")
                               
        "sep=;" | Out-File "$PSScriptRoot\ExportTMHash-$($time).csv"
        "Hash;Description;Action;Status;DateTime MM-dd-yyyy-hh-mm;Validated" | Out-File "$PSScriptRoot\ExportTMHash-$($time).csv" -Append
        foreach ($item in $listview1.items) {
            "$($item.subitems[0].text);$($item.subitems[1].text);$($item.subitems[2].text);$($item.subitems[3].text);$($time);$($item.subitems[4].text)" | Out-File "$PSScriptRoot\ExportTMHash-$($time).csv" -Append
        }
        $linklabel1.Text = "$PSScriptRoot\ExportTMHash-$($time).csv"
    }
               
    $linklabel1_LinkClicked = [System.Windows.Forms.LinkLabelLinkClickedEventHandler] {
        #Event Argument: $_ = [System.Windows.Forms.LinkLabelLinkClickedEventArgs]
        explorer.exe  "$PSScriptRoot\"
    }
               
    $buttonValidateHashes_Click = {
               
        foreach ($entry in $listview1.items) {
            if ($entry.subitems[3].Text -eq "New Hash") {
                if (ValidateHash($entry.Text)) {
                    $entry.SubItems[4].Text = "Validated"
                }
                else {
                    $entry.SubItems[4].Text = "Error"
                }
            }
        }
    }
               
    # --End User Generated Script--
    #----------------------------------------------
    #region Generated Events
    #----------------------------------------------
               
    $Form_StateCorrection_Load =
    {
        #Correct the initial state of the form to prevent the .Net maximized form issue
        $formTrendMicroHashImport.WindowState = $InitialFormWindowState
    }
               
    $Form_StoreValues_Closing =
    {
        #Store the control values
        $script:MainForm_listview1 = $listview1.SelectedItems
        $script:MainForm_textbox2 = $textbox2.Text
        $script:MainForm_textbox1 = $textbox1.Text
    }
 
               
    $Form_Cleanup_FormClosed =
    {
        #Remove all event handlers from the controls
        try {
            $linklabel1.remove_LinkClicked($linklabel1_LinkClicked)
            $buttonExportCSVReport.remove_Click($buttonExportCSVReport_Click)
            $buttonValidateHashes.remove_Click($buttonValidateHashes_Click)
            $buttonImportHashes.remove_Click($buttonImportHashes_Click)
            $textbox1.remove_TextChanged($textbox1_TextChanged)
            $formTrendMicroHashImport.remove_Load($formTrendMicroHashImport_Load)
            $formTrendMicroHashImport.remove_Load($Form_StateCorrection_Load)
            $formTrendMicroHashImport.remove_Closing($Form_StoreValues_Closing)
            $formTrendMicroHashImport.remove_FormClosed($Form_Cleanup_FormClosed)
        }
        catch { Out-Null <# Prevent PSScriptAnalyzer warning #> }
    }
    #endregion Generated Events
 
    #----------------------------------------------
    #region Generated Form Code
    #----------------------------------------------
    $formTrendMicroHashImport.SuspendLayout()
    $groupbox1.SuspendLayout()
    $picturebox1.BeginInit()
    #
    # formTrendMicroHashImport
    #
    $formTrendMicroHashImport.Controls.Add($linklabel1)
    $formTrendMicroHashImport.Controls.Add($buttonExportCSVReport)
    $formTrendMicroHashImport.Controls.Add($labelHashImportStatus)
    $formTrendMicroHashImport.Controls.Add($listview1)
    $formTrendMicroHashImport.Controls.Add($groupbox1)
    $formTrendMicroHashImport.Controls.Add($labelTrendMicroHashImport)
    $formTrendMicroHashImport.Controls.Add($picturebox1)
    $formTrendMicroHashImport.AutoScaleDimensions = New-Object System.Drawing.SizeF(6, 13)
    $formTrendMicroHashImport.AutoScaleMode = 'Font'
    $formTrendMicroHashImport.ClientSize = New-Object System.Drawing.Size(970, 689)
    #region Binary Data
    $Formatter_binaryFomatter = New-Object System.Runtime.Serialization.Formatters.Binary.BinaryFormatter
    $System_IO_MemoryStream = New-Object System.IO.MemoryStream (, [byte[]][System.Convert]::FromBase64String('
AAEAAAD/////AQAAAAAAAAAMAgAAAFFTeXN0ZW0uRHJhd2luZywgVmVyc2lvbj00LjAuMC4wLCBD
dWx0dXJlPW5ldXRyYWwsIFB1YmxpY0tleVRva2VuPWIwM2Y1ZjdmMTFkNTBhM2EFAQAAABNTeXN0
ZW0uRHJhd2luZy5JY29uAgAAAAhJY29uRGF0YQhJY29uU2l6ZQcEAhNTeXN0ZW0uRHJhd2luZy5T
aXplAgAAAAIAAAAJAwAAAAX8////E1N5c3RlbS5EcmF3aW5nLlNpemUCAAAABXdpZHRoBmhlaWdo
dAAACAgCAAAAEAAAABAAAAAPAwAAAH4FAAACAAABAAEAEBAAAAEACABoBQAAFgAAACgAAAAQAAAA
IAAAAAEACAAAAAAAQAEAAAAAAAAAAAAAAAEAAAAAAAA6IQAACG+QAH2xvwAjRDQAL4imABRbaADR
9v8AGlRXAAB7uAAwMg8ADWV+ACZBLAAxMAkAEYzBAABtpgBNo8AAIEpAACo6IABXVDUA////AACJ
xgAuNhcAEEA6AKG9vgBEm8IANSoBAAB8qwAEdJ0AAIO5AD9CIwAAmcwAH0xHAAIB/gAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAISEhISEhISEhISEhISEhISEhISEhCA4eDggh
ISEhISEhISEeDR4eHg4CISEhISEhISEhCA0NHg4OIQYOISEhISEhISEhHh4YEwYOCCEhISEhISEh
IQgeDxMTBhMhISEhISEhIQgeHh4TExMOISEhISEhISENHh4eIQ0ODg4hISEhISENHh4eISEhDQ4O
ISEhISEhCB4eHiEhISENDg4hISEhCB4eHh4hISEhIQ0OISEhCB4eHh4hISEhISENDiEhIQgeHh4e
ISEhISEhISEhISEeHh4eISEhISEhISEhISENHh4hISEhISEhISEhISEhIR4hISEhISEhISEhISEh
If//AAD4PwAA4D8AAOBPAAD4DwAA+A8AAPAPAADwhwAA4ccAAOHjAADB8wAAg/MAAIP/AACH/wAA
H/8AAL//AAAL'))
    #endregion
    $formTrendMicroHashImport.Icon = $Formatter_binaryFomatter.Deserialize($System_IO_MemoryStream)
    $Formatter_binaryFomatter = $null
    $System_IO_MemoryStream = $null
    $formTrendMicroHashImport.Name = 'formTrendMicroHashImport'
    $formTrendMicroHashImport.StartPosition = 'CenterScreen'
    $formTrendMicroHashImport.Text = 'TrendMicro Hash Import'
    $formTrendMicroHashImport.add_Load($formTrendMicroHashImport_Load)
    #
    # linklabel1
    #
    $linklabel1.Location = New-Object System.Drawing.Point(12, 652)
    $linklabel1.Name = 'linklabel1'
    $linklabel1.Size = New-Object System.Drawing.Size(721, 23)
    $linklabel1.TabIndex = 8
    $linklabel1.add_LinkClicked($linklabel1_LinkClicked)
    #
    # buttonExportCSVReport
    #
    $buttonExportCSVReport.Location = New-Object System.Drawing.Point(739, 639)
    $buttonExportCSVReport.Name = 'buttonExportCSVReport'
    $buttonExportCSVReport.Size = New-Object System.Drawing.Size(219, 38)
    $buttonExportCSVReport.TabIndex = 7
    $buttonExportCSVReport.Text = 'Export CSV Report'
    $buttonExportCSVReport.UseVisualStyleBackColor = $True
    $buttonExportCSVReport.add_Click($buttonExportCSVReport_Click)
    #
    # labelHashImportStatus
    #
    $labelHashImportStatus.AutoSize = $True
    $labelHashImportStatus.Location = New-Object System.Drawing.Point(12, 414)
    $labelHashImportStatus.Name = 'labelHashImportStatus'
    $labelHashImportStatus.Size = New-Object System.Drawing.Size(97, 13)
    $labelHashImportStatus.TabIndex = 6
    $labelHashImportStatus.Text = 'Hash Import Status'
    #
    # listview1
    #
    [void]$listview1.Columns.Add($columnheader1)
    [void]$listview1.Columns.Add($columnheader2)
    [void]$listview1.Columns.Add($columnheader3)
    [void]$listview1.Columns.Add($columnheader4)
    [void]$listview1.Columns.Add($columnheader5)
    $listview1.HideSelection = $False
    $listview1.Location = New-Object System.Drawing.Point(12, 437)
    $listview1.Name = 'listview1'
    $listview1.Size = New-Object System.Drawing.Size(946, 196)
    $listview1.TabIndex = 5
    $listview1.UseCompatibleStateImageBehavior = $False
    $listview1.View = 'Details'
    #
    # groupbox1
    #
    $groupbox1.Controls.Add($buttonValidateHashes)
    $groupbox1.Controls.Add($buttonImportHashes)
    $groupbox1.Controls.Add($textbox2)
    $groupbox1.Controls.Add($labelHashDescription)
    $groupbox1.Controls.Add($textbox1)
    $groupbox1.Location = New-Object System.Drawing.Point(12, 152)
    $groupbox1.Name = 'groupbox1'
    $groupbox1.Size = New-Object System.Drawing.Size(946, 259)
    $groupbox1.TabIndex = 4
    $groupbox1.TabStop = $False
    $groupbox1.Text = 'Importing Hashes'
    #
    # buttonValidateHashes
    #
    $buttonValidateHashes.Location = New-Object System.Drawing.Point(525, 206)
    $buttonValidateHashes.Name = 'buttonValidateHashes'
    $buttonValidateHashes.Size = New-Object System.Drawing.Size(196, 47)
    $buttonValidateHashes.TabIndex = 7
    $buttonValidateHashes.Text = 'Validate Hashes'
    $buttonValidateHashes.UseVisualStyleBackColor = $True
    $buttonValidateHashes.add_Click($buttonValidateHashes_Click)
    #
    # buttonImportHashes
    #
    $buttonImportHashes.Location = New-Object System.Drawing.Point(727, 206)
    $buttonImportHashes.Name = 'buttonImportHashes'
    $buttonImportHashes.Size = New-Object System.Drawing.Size(213, 47)
    $buttonImportHashes.TabIndex = 6
    $buttonImportHashes.Text = 'Import Hashes'
    $buttonImportHashes.UseVisualStyleBackColor = $True
    $buttonImportHashes.add_Click($buttonImportHashes_Click)
    #
    # textbox2
    #
    $textbox2.Location = New-Object System.Drawing.Point(6, 180)
    $textbox2.Name = 'textbox2'
    $textbox2.Size = New-Object System.Drawing.Size(934, 20)
    $textbox2.TabIndex = 5
    #
    # labelHashDescription
    #
    $labelHashDescription.AutoSize = $True
    $labelHashDescription.Location = New-Object System.Drawing.Point(9, 164)
    $labelHashDescription.Name = 'labelHashDescription'
    $labelHashDescription.Size = New-Object System.Drawing.Size(91, 13)
    $labelHashDescription.TabIndex = 4
    $labelHashDescription.Text = 'Hash Description:'
    #
    # textbox1
    #
    $textbox1.Location = New-Object System.Drawing.Point(6, 19)
    $textbox1.Multiline = $True
    $textbox1.Name = 'textbox1'
    $textbox1.Size = New-Object System.Drawing.Size(934, 133)
    $textbox1.TabIndex = 3
    $textbox1.add_TextChanged($textbox1_TextChanged)
    #
    # labelTrendMicroHashImport
    #
    $labelTrendMicroHashImport.AutoSize = $True
    $labelTrendMicroHashImport.BackColor = [System.Drawing.Color]::FromArgb(255, 10, 56, 43)
    $labelTrendMicroHashImport.Font = [System.Drawing.Font]::new('Microsoft Sans Serif', '14.25')
    $labelTrendMicroHashImport.ForeColor = [System.Drawing.Color]::White
    $labelTrendMicroHashImport.Location = New-Object System.Drawing.Point(679, 53)
    $labelTrendMicroHashImport.Name = 'labelTrendMicroHashImport'
    $labelTrendMicroHashImport.Size = New-Object System.Drawing.Size(214, 24)
    $labelTrendMicroHashImport.TabIndex = 2
    $labelTrendMicroHashImport.Text = 'TrendMicro Hash Import'
    #
    # picturebox1
    #
    $picturebox1.BackColor = [System.Drawing.Color]::FromArgb(255, 10, 56, 43)
    $picturebox1.Dock = 'Top'
    $picturebox1.Location = New-Object System.Drawing.Point(0, 0)
    $picturebox1.Name = 'picturebox1'
    $picturebox1.Size = New-Object System.Drawing.Size(970, 135)
    $picturebox1.TabIndex = 0
    $picturebox1.TabStop = $False
    #
    # columnheader1
    #
    $columnheader1.Text = 'Hash'
    $columnheader1.Width = 450
    #
    # columnheader2
    #
    $columnheader2.Text = 'Description'
    $columnheader2.Width = 200
    #
    # columnheader3
    #
    $columnheader3.Text = 'Action'
    $columnheader3.Width = 90
    #
    # columnheader4
    #
    $columnheader4.Text = 'Status'
    $columnheader4.Width = 125
    #
    # columnheader5
    #
    $columnheader5.Text = 'Validated'
    $picturebox1.EndInit()
    $groupbox1.ResumeLayout()
    $formTrendMicroHashImport.ResumeLayout()
    #endregion Generated Form Code
 
    #----------------------------------------------
 
    #Save the initial state of the form
    $InitialFormWindowState = $formTrendMicroHashImport.WindowState
    #Init the OnLoad event to correct the initial state of the form
    $formTrendMicroHashImport.add_Load($Form_StateCorrection_Load)
    #Clean up the control events
    $formTrendMicroHashImport.add_FormClosed($Form_Cleanup_FormClosed)
    #Store the control values when form is closing
    $formTrendMicroHashImport.add_Closing($Form_StoreValues_Closing)
    #Show the Form
    return $formTrendMicroHashImport.ShowDialog()
 
}
#endregion Source: MainForm.psf
 
#Start the application
Main ($CommandLine)
