
Add-Type -AssemblyName presentationCore
$musicPlayer = New-Object system.windows.media.mediaplayer
	
#Reserved XX# csv file
$Songs = Import-Csv ".\SoundBoard.ini"

[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")


Add-Type -AssemblyName System.Windows.Forms
 $res = [System.Windows.Forms.Screen]::AllScreens | Where-Object {$_.Primary -eq 'True'} | Select-Object WorkingArea
 if (($res -split ',')[3].Substring(10,1) -match '}') {$heightend = 3}
 else {$heightend = 4}
 $w = ($res -split ',')[2].Substring(6)
 $h = ($res -split ',')[3].Substring(7,$heightend)
 'Screen Resolution: ' + $w + 'x' + $h

#dell venue, 1280 x 800
$w = 1024
$h = 768

$split = 8
$Currentlocation = Get-Location

#begin to draw forms
$Form = New-Object System.Windows.Forms.Form
$Form.Text = "D&D SoundBoard"
$Form.Size = New-Object System.Drawing.Size($w,$h)
#$form.windowstate = "maximized"
$Form.StartPosition = "CenterScreen"
$statusBar1 = New-Object System.Windows.Forms.StatusBar
$musicBox = New-Object Windows.Forms.Panel

#music control items
$musicVolSlider = New-Object Windows.Forms.Trackbar
$musicHeaderLabel = New-Object Windows.Forms.Label
$musicLabel = New-Object Windows.Forms.Label
$musMuteButton = New-Object System.Windows.Forms.Button

$resizeHandler = { DrawButtons }

$Form.Add_Resize( $resizeHandler )

#stop everything that is playing if the form is closed early
$Form.add_FormClosing({
If($(Get-Job Musicplayer -ErrorAction SilentlyContinue)) 
        { 
			Get-Job MusicPlayer -ErrorAction SilentlyContinue |Stop-Job 
            Get-Job MusicPlayer -ErrorAction SilentlyContinue |Remove-Job -Force 
        } 
})

<# 
$play_click = {
	    $statusBar1.Text = "Playing $($Songs[$this.Name].File)"
		$MusicPlayer.open([uri]("$Currentlocation" + "\" + "$($Songs[$this.Name].File)"))
		#$CurrentSongDuration= New-TimeSpan -Seconds (Get-SongDuration "$Currentlocation" + "\" + "$($Songs[$this.Name].File)")
		#$duration = $musicPlayer.NaturalDuration.TimeSpan.TotalMilliSeconds
        #$duration = 45
		$musicPlayer.Play()
		#Start-Sleep -seconds $duration
}
#>

$play_click = {
	$path = "$Currentlocation" + "\" + "$($Songs[$this.Name].File)"
	Write-Host $path -fore cyan
	$loop = $true
	If($(Get-Job Musicplayer -ErrorAction SilentlyContinue)) 
        { 
            Get-Job MusicPlayer -ErrorAction SilentlyContinue |Remove-Job -Force 
        } 
	Start-Job -Name MusicPlayer -InitializationScript $init -ScriptBlock {playmusic $args[0] $args[1] $args[2] } -ArgumentList $path, $Shuffle, $Loop | Out-Null 
	Start-Sleep -Seconds 3       # Sleep to allow media player some breathing time to load files 
	Receive-Job -Name MusicPlayer | ft @{n='TotalSongs';e={$_.TotalSongs};alignment='left'},@{n='TotalPlayDuration';e={$_.PlayDuration};alignment='left'},@{n='Mode';e={$_.Mode};alignment='left'} -AutoSize 
}

 

$stop_click =
{
If($(Get-Job Musicplayer -ErrorAction SilentlyContinue)) 
        { 
			Get-Job MusicPlayer -ErrorAction SilentlyContinue |Stop-Job 
            Get-Job MusicPlayer -ErrorAction SilentlyContinue |Remove-Job -Force 
        } 
}


#mediaPlayerVol TrackBar Event Handler
$musicVolSlider.add_ValueChanged({
$musicVolValue = $musicVolSlider.Value
$musicLabel.Text = "$musicVolValue"
$musicPlayer.volume = $musicVolValue/100
})

 
function DrawButtons{
    $Form.Controls.Clear()
	$musicBox.Controls.Clear()
    $w = ($Form.Size.Width-17)
    $h = ($Form.Size.Height-62)
	$musVol = (100 * $musicPlayer.volume)
	$ambVol = (100 * $ambiencePlayer.volume)
	$effVol = (100 * $effectsPlayer.volume)
    $statusBar1.Name = "statusBar1"
    $form.Controls.Add($statusBar1)
    $form.Controls.Add($musicBox)
	
    $Buttons = @()

    for( $i=0; $i -lt 36; $i++ ){
        $button = New-Object System.Windows.Forms.Button
        $Buttons = $Buttons + $button
        $Buttons[$i].Name = $i;
        if($i -lt 6){
            $Buttons[$i].Location = New-Object System.Drawing.Size((($w/$split) * $i),0)
        } elseif($i -lt 12) {
            $Buttons[$i].Location = New-Object System.Drawing.Size((($w/$split) * ($i-6)),($h/$split))
        } elseif($i -lt 18) {
            $Buttons[$i].Location = New-Object System.Drawing.Size((($w/$split) * ($i-12)),(($h/$split) * 2))
        } elseif($i -lt 24) {
            $Buttons[$i].Location = New-Object System.Drawing.Size((($w/$split) * ($i-18)),(($h/$split) * 3))
        } elseif($i -lt 30) {
            $Buttons[$i].Location = New-Object System.Drawing.Size((($w/$split) * ($i-24)),(($h/$split) * 4))
        } elseif($i -lt 36) {
            $Buttons[$i].Location = New-Object System.Drawing.Size((($w/$split) * ($i-30)),(($h/$split) * 5))
        } elseif($i -lt 42) {
            $Buttons[$i].Location = New-Object System.Drawing.Size((($w/$split) * ($i-36)),(($h/$split) * 6))
        } else {
            $Buttons[$i].Location = New-Object System.Drawing.Size((($w/$split) * ($i-42)),(($h/$split) * 7))
        }
        $Buttons[$i].Size = New-Object System.Drawing.Size(($w/$split),($h/$split))
        $Buttons[$i].Text = "$($Songs[$i].Title)"
        $Buttons[$i].Add_Click($play_click)
        if($Songs[$i].Type -eq 0){$Buttons[$i].BackColor="beige"}
        if($Songs[$i].Type -eq 1){$Buttons[$i].BackColor="lightgreen"}
        if($Songs[$i].Type -eq 2){$Buttons[$i].BackColor="lightblue"}
        $Form.Controls.Add($Buttons[$i])
    }
	
	#Music Box 
	$musicBox.Size = New-Object System.Drawing.Size(((($w/$split)*2)/3), $h)
	$musicBox.Location = New-Object System.Drawing.Size((($w/$split) * 6),0)
	$musicBox.BackColor = "beige"
	$musicBoxWidth = $musicBox.width

	#universal variables
	$sliderBuffer = 20
	$sliderHeight = ($h - (300))
	
	#music stop button
    $StopButton = New-Object System.Windows.Forms.Button
    $StopButton.Size = New-Object System.Drawing.Size(($musicBoxWidth - 20),50)
    $StopButton.Location = New-Object System.Drawing.Size((($musicBoxWidth/2) - ($StopButton.Width/2)), ($h - 180))
    $StopButton.BackColor = "Beige"
    $StopButton.Text = "Stop"
    $StopButton.Add_Click($stop_click)
    $musicBox.Controls.Add($StopButton)
	
	#Music Volume Header Label
	$musicHeaderLabel.Location = New-Object System.Drawing.Point((($musicBoxWidth/2) - ($musicHeaderLabel.Width/2)),15)
	$musicHeaderLabel.Text = "Music"
	$musicHeaderLabel.Font = "Comic Sans MS, 14"
	$musicHeaderLabel.Autosize = "True"
	$musicBox.Controls.Add($musicHeaderLabel)

	#Music Volume Slider
	$musicVolSlider.Location = New-Object System.Drawing.Point(((($StopButton.Width/2) + $StopButton.Location.X) - (45/2)), ($musicHeaderLabel.bottom + 10))
	$musicVolSlider.Orientation = "Vertical"
	$musicVolSlider.Height = $sliderHeight
	$musicVolSlider.TickFrequency = 10
	$musicVolSlider.Tickstyle = "TopLeft"
	$musicVolSlider.setRange(0, 100)
	$musicVolSlider.Value = $musVol
	$bottom = $musicVolSlider.Bottom
	$musicVolSliderValue = $musVol
	$musicBox.Controls.Add($musicVolSlider)
		
	#Music Volume Label
	$musicLabel.Location = New-Object System.Drawing.Point((($musicBoxWidth/2) - ($musicLabel.Width/2)), ($h - 220))
	$musicLabel.Text = "$musicVolSliderValue"
	$musicLabel.Font = "Comic Sans MS, 12"
	$musicLabel.Autosize = "true"
	$musicBox.Controls.Add($musicLabel)
}

#initialization Script for back ground job 
$init = { 
	# Function to calculate duration of song in Seconds 
	Function Get-SongDuration($FullName) 
	{ 
		$Shell = New-Object -COMObject Shell.Application 
		$Folder = $shell.Namespace($(Split-Path $FullName)) 
		$File = $Folder.ParseName($(Split-Path $FullName -Leaf)) 
		 
		[int]$h, [int]$m, [int]$s = ($Folder.GetDetailsOf($File, 27)).split(":") 
		 
		$h*60*60 + $m*60 +$s 
	} 


	Function PlayMusic($path, $Shuffle, $Loop) 
	{ 
			
		# Calling required assembly 
		Add-Type -AssemblyName PresentationCore 

		# Instantiate Media Player Class for music
		$MediaPlayer = New-Object System.Windows.Media.Mediaplayer 
		
		do{
		$CurrentSongDuration= New-TimeSpan -Seconds (Get-SongDuration $path) 
		$duration = $CurrentSongDuration.Seconds + $CurrentSongDuration.Minutes*60
		$MediaPlayer.Open($path)                    # 1. Open Music file with media player 
		$Message = "Song : "+$(Split-Path $path -Leaf)+"`nPlay Duration : $($CurrentSongDuration.Minutes) Mins $($CurrentSongDuration.Seconds) Sec`nMode : $Mode"             
		#Write-Host $_.fullname -fore yellow
		Write-Host $message -fore yellow
		$MediaPlayer.Play()                               # 2. Play the Music File 
		Write-Host $duration -fore green
		Start-Sleep -Seconds $duration         # 4. Pause the script execution until song completes 
		$MediaPlayer.Stop()                               # 5. Stop the Song 
		}While($loop)
	} 
} 
		
DrawButtons

#$Form.Add_KeyDown({if ($_.KeyCode -eq "F1"){&amp; $add_reservation_click}})
$Form.Add_KeyDown({if ($_.KeyCode -eq "Escape")
{$Form.Close()}})

#Show form
$Form.Topmost = $False
$Form.Add_Shown({$Form.Activate()})
[void] $Form.ShowDialog()




