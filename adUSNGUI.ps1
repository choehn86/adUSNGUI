Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Security

[Windows.Forms.Application]::EnableVisualStyles()
[System.Reflection.Assembly]::LoadWithPartialName("System.DirectoryServices.Protocols") | Out-Null
[System.Reflection.Assembly]::LoadWithPartialName("System.Net") | Out-Null


function getValidDCs
{
    $domain = [System.Directoryservices.Activedirectory.Domain]::GetCurrentDomain()
    $i = 1
    $domain | ForEach-Object {$_.DomainControllers} | 
        ForEach-Object {
            $hostEntry= [System.Net.Dns]::GetHostByName($_.Name)
            $tbLog.Text = "Getting information on all DCs..." + ([math]::Round((($i / $domain.DomainControllers.Count)*100))) + "% complete..."
            $i++
            New-Object -TypeName PSObject -Property @{
                Name = $_.Name
                DisplayName = $_.Name.Substring(0, $_.Name.IndexOf("."))
                IPAddress = $hostEntry.AddressList[0].IPAddressToString
                USN = $_.highestCommittedUsn
                                                     }
                       } | Select Name, DisplayName, IPAddress, USN
}

#
#form
#
$form = New-Object System.Windows.Forms.Form
$form.MaximizeBox = $false
$form.Text = "AD - USN Check"
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle
$form.ClientSize = New-Object System.Drawing.Size(384, 161)
#
#cbDCs
#
$cbDCs = New-Object System.Windows.Forms.ComboBox
$cbDCs.DisplayMember = "DisplayName"
$cbDCs.ValueMember = "Name"
$cbDCs.Size = New-Object System.Drawing.Size(175, 21)
$cbDCs.Location = New-Object System.Drawing.Point(70, 15)
$cbDCs.Enabled = $false
$form.Controls.Add($cbDCs)
#
#lblDCs
#
$lblDCs = New-Object System.Windows.Forms.Label
$lblDCs.Text = "Select a DC:"
$lblDCs.Size = New-Object System.Drawing.Size(70, 23)
$lblDCs.Location = New-Object System.Drawing.Point(5, 20)
$form.Controls.Add($lblDCs)
#
#btnGetDCs
#
$btnGetDCs = New-Object System.Windows.Forms.Button
$btnGetDCs.Text = "Get List of DCs"
$btnGetDCs.Size = New-Object System.Drawing.Size(95, 25)
$btnGetDCs.Location = New-Object System.Drawing.Point(265, 13)
$form.Controls.Add($btnGetDCs)
#
#lblName
#
$lblName = New-Object System.Windows.Forms.Label
$lblName.Text = "Name"
$lblName.Size = New-Object System.Drawing.Size(35, 23)
$lblName.Location = New-Object System.Drawing.Point(105, 48)
$form.Controls.Add($lblName)
#
#lblIP
#
$lblIP = New-Object System.Windows.Forms.Label
$lblIP.Text = "IP Address"
$lblIP.Size = New-Object System.Drawing.Size(60, 23)
$lblIP.Location = New-Object System.Drawing.Point(82, 73)
$form.Controls.Add($lblIP)
#
#lblUSN
#
$lblUSN = New-Object System.Windows.Forms.Label
$lblUSN.Text = "Highest Committed USN"
$lblUSN.Size = New-Object System.Drawing.Size(128, 23)
$lblUSN.Location = New-Object System.Drawing.Point(16, 98)
$form.Controls.Add($lblUSN)
#
#tbName
#
$tbName = New-Object System.Windows.Forms.TextBox
$tbName.ReadOnly = $true
$tbName.Size = New-Object System.Drawing.Size(200, 20)
$tbName.Location = New-Object System.Drawing.Point(145, 45)
$form.Controls.Add($tbName)
#
#tbIP
#
$tbIP = New-Object System.Windows.Forms.TextBox
$tbIP.ReadOnly = $true
$tbIP.Size = New-Object System.Drawing.Size(200, 20)
$tbIP.Location = New-Object System.Drawing.Point(145, 70)
$form.Controls.Add($tbIP)
#
#tbUSN
#
$tbUSN = New-Object System.Windows.Forms.TextBox
$tbUSN.ReadOnly = $true
$tbUSN.Size = New-Object System.Drawing.Size(200, 20)
$tbUSN.Location = New-Object System.Drawing.Point(145, 95)
$form.Controls.Add($tbUSN)
#
#tbLog
#
$tbLog = New-Object System.Windows.Forms.TextBox
$tbLog.ReadOnly = $true
$tbLog.Size = New-Object System.Drawing.Size(300, 20)
$tbLog.Location = New-Object System.Drawing.Point(40, 130)
$tbLog.BackColor = "DarkBlue"
$tbLog.Font = New-Object System.Drawing.Font("Consolas", 8, [System.Drawing.FontStyle]::Regular)
$tbLog.ForeColor = "White"
$form.Controls.Add($tbLog)

function populateFields
{
    $tbUSN.Text = $cbDCs.SelectedItem.USN
    $tbIP.Text = $cbDCs.SelectedItem.IPAddress
    $tbName.Text = $cbDCs.SelectedItem.Name
}



# Event handlers for clickable objects

$btnGetDCs.Add_Click(
                        {
                            $cbDCs.Items.Clear()
                            $tbLog.Text = "Getting information on all DCs...please wait!"
                            $DCs = getValidDCs
                            ForEach($dc in $DCs)
                            {$cbDCs.Items.Add($dc)}
                            $cbDCs.Sorted = $true
                            $cbDCs.SelectedIndex = 0
                            $tbLog.Text = "Data received!"
                            $cbDCs.Enabled = $true
                        }
                    )
$cbDCs.Add_SelectedIndexChanged(
                        {  populateFields }
                                   )
$btnGetDCs.Focus()
$form.ShowDialog()

#[system.windows.forms.application]::run($form)
###################