
Add-Type -AssemblyName presentationCore
$musicPlayer = New-Object system.windows.media.mediaplayer
$ambiencePlayer = New-Object system.windows.media.mediaplayer
$effectsPlayer = New-Object system.windows.media.mediaplayer


	
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
$form.windowstate = "maximized"
$Form.StartPosition = "CenterScreen"
#$Form.BackColor = "MidnightBlue"
$statusBar1 = New-Object System.Windows.Forms.StatusBar
$musicBox = New-Object Windows.Forms.Panel
$ambienceBox = New-Object Windows.Forms.Panel
$effectsBox = New-Object Windows.Forms.Panel

#music control items
$musicVolSlider = New-Object Windows.Forms.Trackbar
$musicHeaderLabel = New-Object Windows.Forms.Label
$musicLabel = New-Object Windows.Forms.Label
$musMuteButton = New-Object System.Windows.Forms.Button

#ambience control items
$ambienceVolSlider = New-Object Windows.Forms.Trackbar
$ambienceHeaderLabel = New-Object Windows.Forms.Label
$ambienceLabel = New-Object Windows.Forms.Label


#effects control items
$effectsVolSlider = New-Object Windows.Forms.Trackbar
$effectsHeaderLabel = New-Object Windows.Forms.Label
$effectsLabel = New-Object Windows.Forms.Label

#Test Items (Comment out when finished)
$testLabel = New-Object Windows.Forms.Label

$resizeHandler = { DrawButtons }

$Form.Add_Resize( $resizeHandler )

#stop everything that is playing if the form is closed early
$Form.add_FormClosing( {  
  $musicPlayer.Stop()
  $ambiencePlayer.Stop()
  $effectsPlayer.Stop()})

$play_click = {

	
     if($Songs[$this.Name].Type -eq 0){
	 
        $statusBar1.Text = "Playing $($Songs[$this.Name].File)"
		$MusicPlayer.open([uri]("$Currentlocation" + "\" + "$($Songs[$this.Name].File)"))
		#$CurrentSongDuration= New-TimeSpan -Seconds (Get-SongDuration "$Currentlocation" + "\" + "$($Songs[$this.Name].File)")
		#$duration = $musicPlayer.NaturalDuration.TimeSpan.TotalMilliSeconds
        #$duration = 45
		$musicPlayer.Play()
		#Start-Sleep -seconds $duration
		

    } elseif($Songs[$this.Name].Type -eq 2){
        $ambiencePlayer.open([uri]("$Currentlocation" + "\" + "$($Songs[$this.Name].File)"))
		$ambiencePlayer.Play()
		
	} else {
		
        $effectsPlayer.open([uri]("$Currentlocation"+ "\" + "$($Songs[$this.Name].File)"))
        $effectsPlayer.Play()
		
    } 
}



$buttonGetService_Click={
	$this.Enabled = $False
	#TODO: Place custom script here
	Get-Service | Out-GridView
	#Process the pending messages before enabling the button
	[System.Windows.Forms.Application]::DoEvents()
	$this.Enabled = $True
}

$stop_click =
{
  $this.Enabled = $False
  $statusBar1.Text = "Stopped"
  $musicPlayer.Stop()
  $effectsPlayer.Stop()
}

$stop_clickAmbient =
{
  $ambiencePlayer.Stop()
}

$musPause_click = 
{
 	if($pause -eq 0){
	$musicPlayer.Pause()
	$pause = 2	
    $musNowPlaying.Text = "Paused"	
	}
	else{
	$musicPlayer.Play()
	$pause =  0
	} 
}

$stop_clickAll=
{
  $statusBar1.Text = "Stopped"
  $musicPlayer.Stop()
  $ambiencePlayer.Stop()
  $effectsPlayer.Stop()  
}

$musMute_click={Start-Job -name musMute -ScriptBlock{fadeMusicBackground 0 $musicPlayer $musicLabel $musicVolSlider}}


$ambMute_click={Fade-Ambience(0)}

#mediaPlayerVol TrackBar Event Handler
$musicVolSlider.add_ValueChanged({
$musicVolValue = $musicVolSlider.Value
$musicLabel.Text = "$musicVolValue"
$musicPlayer.volume = $musicVolValue/100
})

#ambienceVolSlider Event Handler
$ambienceVolSlider.add_ValueChanged({
$ambienceVolValue = $ambienceVolSlider.Value
$ambienceLabel.Text = "$ambienceVolValue"
$ambiencePlayer.volume = $ambienceVolValue/100
})

#effectseVolSlider Event Handler
$effectsVolSlider.add_ValueChanged({
$effectsVolValue = $effectsVolSlider.Value
$effectsLabel.Text = "$effectsVolValue"
$effectsPlayer.volume = $effectsVolValue/100
})
 
function DrawButtons{
    $Form.Controls.Clear()
	$musicBox.Controls.Clear()
	$ambienceBox.Controls.Clear()
	$effectsBox.Controls.Clear()
    $w = ($Form.Size.Width-17)
    $h = ($Form.Size.Height-62)
	$musVol = (100 * $musicPlayer.volume)
	$ambVol = (100 * $ambiencePlayer.volume)
	$effVol = (100 * $effectsPlayer.volume)
    $statusBar1.Name = "statusBar1"
    $form.Controls.Add($statusBar1)
    $form.Controls.Add($musicBox)
    $form.Controls.Add($ambienceBox)
    $form.Controls.Add($effectsBox)
	
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
	
	#Ambience Box 
	$ambienceBox.Size = New-Object System.Drawing.Size(((($w/$split)*2)/3), $h)
	$ambienceBox.Location = New-Object System.Drawing.Size((($w/$split) * 6 + ((($w/$split)*2)/3)),0)
	$ambienceBox.BackColor = "lightblue"
	$ambienceBoxWidth = $ambienceBox.width
	
	#effects Box 
	$effectsBox.Size = New-Object System.Drawing.Size(((($w/$split)*2)/3), $h)
	$effectsBox.Location = New-Object System.Drawing.Size((($w/$split) * 6 + (2*(($w/$split)*2)/3)),0)
	$effectsBox.BackColor = "lightgreen"
	$effectsBoxWidth = $effectsBox.width
	
	#universal variables
	$sliderBuffer = 20
	$sliderHeight = ($h - (300))
	
	#STOP-ALL
    $StopButtonAll = New-Object System.Windows.Forms.Button
    $StopButtonAll.Location = New-Object System.Drawing.Size((($w/$split)*1),(($h/$split)*7))
    $StopButtonAll.Size = New-Object System.Drawing.Size(($w/$split),(($h/$split)-0))
    $StopButtonAll.BackColor = "red"
    $StopButtonAll.Text = "Stop All"
	$StopButtonAll.font = "bold"
    $StopButtonAll.Add_Click($stop_clickAll)
    $Form.Controls.Add($StopButtonAll)
	
	#mute music
    $musMuteButton.Location = New-Object System.Drawing.Size((($w/$split)*2),(($h/$split)*7))
    $musMuteButton.Size = New-Object System.Drawing.Size(($w/$split),(($h/$split)-0))
    $musMuteButton.BackColor = "beige"
    $musMuteButton.Text = "Mute Music"
	$musMuteButton.font = "bold"
    $musMuteButton.Add_Click($musMute_click)
    $Form.Controls.Add($musMuteButton)
		
	#mute music
    $ambMuteButton = New-Object System.Windows.Forms.Button
    $ambMuteButton.Location = New-Object System.Drawing.Size((($w/$split)*3),(($h/$split)*7))
    $ambMuteButton.Size = New-Object System.Drawing.Size(($w/$split),(($h/$split)-0))
    $ambMuteButton.BackColor = "beige"
    $ambMuteButton.Text = "Mute Ambience"
	$ambMuteButton.font = "bold"
    $ambMuteButton.Add_Click($ambMute_click)
    $Form.Controls.Add($ambMuteButton)

	#music stop button
    $StopButton = New-Object System.Windows.Forms.Button
    $StopButton.Size = New-Object System.Drawing.Size(($musicBoxWidth - 20),50)
    $StopButton.Location = New-Object System.Drawing.Size((($musicBoxWidth/2) - ($StopButton.Width/2)), ($h - 180))
    $StopButton.BackColor = "Beige"
    $StopButton.Text = "Stop"
    $StopButton.Add_Click($stop_click)
    $musicBox.Controls.Add($StopButton)
	
	#music pause button
    $musPauseButton = New-Object System.Windows.Forms.Button
    $musPauseButton.Size = New-Object System.Drawing.Size(($musicBoxWidth - 20),50)
    $musPauseButton.Location = New-Object System.Drawing.Size((($musicBoxWidth/2) - ($musPauseButton.Width/2)) ,(($h - 120)))
    $musPauseButton.BackColor = "Beige"
    $musPauseButton.Text = "Pause"
	$musPauseButton.Add_Click($musPause_click)
    $musicBox.Controls.Add($musPauseButton)
		
	#music repeat button
    $musRepeatButton = New-Object System.Windows.Forms.Button
    $musRepeatButton.Size = New-Object System.Drawing.Size(($musicBoxWidth - 20),50)
    $musRepeatButton.Location = New-Object System.Drawing.Size((($musicBoxWidth/2) - ($musRepeatButton.Width/2)),($h - 60))
    $musRepeatButton.BackColor = "Beige"
    $musRepeatButton.Text = "Repeat"
	$musRepeatButton.Add_Click($musRepeat_click)
    $musicBox.Controls.Add($musRepeatButton)	
	
	#Music Volume Header Label
	$musicHeaderLabel.Location = New-Object System.Drawing.Point((($musicBoxWidth/2) - ($musicHeaderLabel.Width/2)),15)
	$musicHeaderLabel.Text = "Music"
	$musicHeaderLabel.Font = "Comic Sans MS, 14"
	$musicHeaderLabel.Autosize = "True"
	$musicBox.Controls.Add($musicHeaderLabel)

	#Music Volume Slider
	$musicVolSlider.Location = New-Object System.Drawing.Point(((($musPauseButton.Width/2) + $musPauseButton.Location.X) - (45/2)), ($musicHeaderLabel.bottom + 10))
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
	
	#ambience stop buttom
    $StopButtonAmbient = New-Object System.Windows.Forms.Button
    $StopButtonAmbient.Size = New-Object System.Drawing.Size(($ambienceBoxWidth - 20),50)
    $StopButtonAmbient.Location = New-Object System.Drawing.Size((($ambienceBoxWidth - $StopButtonAmbient.Width)/2), ($h - 180))
    $StopButtonAmbient.BackColor = "lightblue"
    $StopButtonAmbient.Text = "Stop"
    $StopButtonAmbient.Add_Click($stop_clickAmbient)
    $ambienceBox.Controls.Add($StopButtonAmbient)	
	
	#ambience pause button
    $ambiencePauseButton = New-Object System.Windows.Forms.Button
    $ambiencePauseButton.Size = New-Object System.Drawing.Size(($ambienceBoxWidth - 20),50)
    $ambiencePauseButton.Location = New-Object System.Drawing.Size((($ambienceBoxWidth/2) - ($ambiencePauseButton.Width/2)) ,(($h - 120)))
    $ambiencePauseButton.BackColor = "lightblue"
    $ambiencePauseButton.Text = "Pause"
	$ambiencePauseButton.Add_Click($ambiencePause_click)
    $ambienceBox.Controls.Add($ambiencePauseButton)
		
	#ambience repeat button
    $ambienceRepeatButton = New-Object System.Windows.Forms.Button
    $ambienceRepeatButton.Size = New-Object System.Drawing.Size(($ambienceBoxWidth - 20),50)
    $ambienceRepeatButton.Location = New-Object System.Drawing.Size((($ambienceBoxWidth/2) - ($ambienceRepeatButton.Width/2)),($h - 60))
    $ambienceRepeatButton.BackColor = "lightblue"
    $ambienceRepeatButton.Text = "Repeat"
	$ambienceRepeatButton.Add_Click($ambienceRepeat_click)
    $ambienceBox.Controls.Add($ambienceRepeatButton)	
		
	#ambience Volume Header Label
	$ambienceHeaderLabel.Location = New-Object System.Drawing.Point((($ambienceBoxWidth - $ambienceHeaderLabel.Width)/2),15)
	$ambienceHeaderLabel.Text = "Ambience"
	$ambienceHeaderLabel.Font = "Comic Sans MS, 14"
	$ambienceHeaderLabel.Autosize = "True"
	#Write-Host "Ambience Header Width: " $ambienceHeaderLabel.Width
	#Write-Host "Ambience Location: " $ambienceHeaderLabel.Location
	$ambienceBox.Controls.Add($ambienceHeaderLabel)
	
	#ambience Volume Slider
	$ambienceVolSlider.Location = New-Object System.Drawing.Point(((($StopButtonAmbient.Width/2) + $StopButtonAmbient.Location.X) - (45/2)), ($musicHeaderLabel.bottom + 10))
	$ambienceVolSlider.Orientation = "Vertical"
	$ambienceVolSlider.Height = $sliderHeight
	$ambienceVolSlider.TickFrequency = 10
	$ambienceVolSlider.Tickstyle = "TopLeft"
	$ambienceVolSlider.setRange(0, 100)
	$ambienceVolSlider.Value = $ambVol
	$ambienceVolSliderValue = $ambVol
	$ambienceVolSlider.BackColor = "lightblue"
	$ambienceBox.Controls.Add($ambienceVolSlider)
	
	#ambience Volume Label
	$ambienceLabel.Location = New-Object System.Drawing.Point((($ambienceBoxWidth - $ambienceLabel.Width)/2), ($h - 220))
	$ambienceLabel.Text = "$ambienceVolSliderValue"
	$ambienceLabel.Font = "Comic Sans MS, 12"
	$ambienceLabel.Autosize = "true"
	$ambienceBox.Controls.Add($ambienceLabel)
	
		#effects pause button
    $effectsPauseButton = New-Object System.Windows.Forms.Button
    $effectsPauseButton.Size = New-Object System.Drawing.Size(($effectsBoxWidth - 20),50)
    $effectsPauseButton.Location = New-Object System.Drawing.Size((($effectsBoxWidth/2) - ($effectsPauseButton.Width/2)) ,(($h - 120)))
    $effectsPauseButton.BackColor = "lightgreen"
    $effectsPauseButton.Text = "Pause"
	$effectsPauseButton.Add_Click($effectsPause_click)
    $effectsBox.Controls.Add($effectsPauseButton)
		
	#effects repeat button
    $effectsRepeatButton = New-Object System.Windows.Forms.Button
    $effectsRepeatButton.Size = New-Object System.Drawing.Size(($effectsBoxWidth - 20),50)
    $effectsRepeatButton.Location = New-Object System.Drawing.Size((($effectsBoxWidth/2) - ($effectsRepeatButton.Width/2)),($h - 60))
    $effectsRepeatButton.BackColor = "lightgreen"
    $effectsRepeatButton.Text = "Repeat"
	$effectsRepeatButton.Add_Click($effectsRepeat_click)
    $effectsBox.Controls.Add($effectsRepeatButton)	
	
	#effects Volume Header Label
	$effectsHeaderLabel.Location = New-Object System.Drawing.Point((($effectsBoxWidth - $effectsHeaderLabel.Width)/2),15)
	$effectsHeaderLabel.Text = "Effects"
	$effectsHeaderLabel.Font = "Comic Sans MS, 14"
	$effectsHeaderLabel.Autosize = "True"
	$effectsBox.Controls.Add($effectsHeaderLabel)
	
	#effects Volume Slider
	$effectsVolSlider.Location = New-Object System.Drawing.Point(((($effectsPauseButton.Width/2) + $effectsPauseButton.Location.X) - (45/2)), ($musicHeaderLabel.bottom + 10))
	$effectsVolSlider.Orientation = "Vertical"
	$effectsVolSlider.Height = $sliderHeight
	$effectsVolSlider.TickFrequency = 10
	$effectsVolSlider.Tickstyle = "TopLeft"
	$effectsVolSlider.setRange(0, 100)
	$effectsVolSlider.Value = $effVol
	$effectsVolSliderValue = $effVol
	$effectsVolSlider.BackColor = "lightgreen"
	$effectsBox.Controls.Add($effectsVolSlider)
	
	#effects Volume Label
	$effectsLabel.Location = New-Object System.Drawing.Point((($effectsBoxWidth - $effectsLabel.Width)/2), ($h - 220))
	$effectsLabel.Text = "$effectsVolSliderValue"
	$effectsLabel.Font = "Comic Sans MS, 12"
	$effectsLabel.Autosize = "true"
	$effectsBox.Controls.Add($effectsLabel)

}

function FadeMusic
{
	#param($level)
	$level = 0
	$tempMusVol = [math]::Round(100 * $musicPlayer.volume)
	$steps = [math]::Abs($level - $tempMusVol)
	$interval = [math]::Round(1000 * (2/$Steps))
		
  	if($level -gt $tempMusVol){
		for($i = $tempMusVol;$i -le $level; $i++)
	{
		$musicLabel.Text = "$tempMusVol"
		$musicVolSlider.Value = $i
		Start-Sleep –milliseconds $interval
	}
	}
	
	elseif($level -lt $tempMusVol){
		for($i = $tempMusVol;$i -ge $level; $i = $i - 1)
	{
		$musicLabel.Text = "$tempMusVol"
		$musicVolSlider.Value = $i
		Start-Sleep –milliseconds $interval
	}
	} 

}

function fadeMusicBackground
{
	param($level, $localMusicPlayer, $localMusicLabel, $localMusicVolSlider)
	Write-Host $level -fore blue
	$tempMusVol = [math]::Round(100 * $localMusicPlayer.volume)
	$steps = [math]::Abs($level - $tempMusVol)
	$interval = [math]::Round(1000 * (2/$Steps))
		
  	if($level -gt $tempMusVol){
		for($i = $tempMusVol;$i -le $level; $i++)
	{
		$localMusicLabel.Text = "$tempMusVol"
		$localMusicVolSlider.Value = $i
		Start-Sleep –milliseconds $interval
	}
	}
	
	elseif($level -lt $tempMusVol){
		for($i = $tempMusVol;$i -ge $level; $i = $i - 1)
	{
		$localMusicLabel.Text = "$tempMusVol"
		$localMusicVolSlider.Value = $i
		Start-Sleep –milliseconds $interval
	}
	} 
	get-Job
	Stop-Job
}


function Fade-Ambience
{
	param($level)
	$tempAmbVol = [math]::Round(100 * $ambiencePlayer.volume)
	$steps = [math]::Abs($level - $tempAmbVol)
	$interval = [math]::Round(1000 * (2/$Steps))
	
	 if($level -gt $tempAmbVol){
		for($i = $tempAmbVol;$i -le $level; $i++)
	{
		$ambienceLabel.Text = "$tempAmbVol"
		$ambienceVolSlider.Value = $i
		Start-Sleep –milliseconds $interval
	}
	}
	elseif($level -lt $tempAmbVol){
		for($i = $tempAmbVol;$i -ge $level; $i = $i - 1)
	{
		$ambienceLabel.Text = "$tempAmbVol"
		$ambienceVolSlider.Value = $i
		Start-Sleep –milliseconds $interval
	}
	}  
}

<# function levelOneSet
{
	$finalAmbLevel = 75
	$finalMusLevel = 25
	$tempAmbVol = [math]::Round(100 * $ambiencePlayer.volume)
	$tempMusVol = [math]::Round(100 * $musicPlayer.volume)
	$musDiff = [Math]::Abs($finalMusLevel - $tempMusVol)
	$ambDiff = [Math]::Abs($finalAmbLevel - $tempAmbVol)
	$steps = [Math]::Max($musDiff,$ambDiff)
	$interval = [Math]::Round(1000 * (2/$steps))
	
	Write-Host "Music Diff: " $musDiff -fore green
	Write-Host "Ambience Diff: " $ambDiff -fore blue
	Write-Host "Steps: " $steps -fore red
	Write-Host "Interval: " $interval -fore red
	
	if($finalMusLevel -gt $tempMusVol){
		if($finalAmbLevel -gt $tempAmbVol){
			
		}
		elseif($finalAmbLevel -lt $tempAmbVol){
		
		}
	}
	
	elseif($finalMusLevel -lt $tempMusVol){
	
	}
	
} #>

#$Form.Add_KeyDown({if ($_.KeyCode -eq "F1"){&amp; $add_reservation_click}})
$Form.Add_KeyDown({if ($_.KeyCode -eq "Escape")
{$Form.Close()}})

#Show form
$Form.Topmost = $False
$Form.Add_Shown({$Form.Activate()})
[void] $Form.ShowDialog()


