Add-Type -AssemblyName presentationCore
	
#Reserved XX# csv file
$musicList = Import-Csv ".\soundboardMusic.csv" | Where-Object {$_.File -like "*Music*"}
$ambianceList =  Import-Csv ".\soundboardAmbiance.csv" | Where-Object {$_.File -like "*Music*"}
$battleSongs = @()
$mysterySongs = @()
$citySongs = @()

for($i=0; $i -le $musicList.Count; $i++ )
{
    if($musicList[$i].Page -eq 0){$citySongs = $citySongs + $musicList[$i]}
    if($musicList[$i].Page -eq 1){$battleSongs = $battleSongs + $musicList[$i]}
    if($musicList[$i].Page -eq 2){$mysterySongs = $mysterySongs + $musicList[$i]}
}


[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")

Add-Type -AssemblyName System.Windows.Forms
 $res = [System.Windows.Forms.Screen]::AllScreens | Where-Object {$_.Primary -eq 'True'} | Select-Object WorkingArea
 if (($res -split ',')[3].Substring(10,1) -match '}') {$heightend = 3}
 else {$heightend = 4}
 $w = ($res -split ',')[2].Substring(6)
 $h = ($res -split ',')[3].Substring(7,$heightend)
 'Screen Resolution: ' + $w + 'x' + $h

#Form Initialization and "global" variables
$Form = New-Object System.Windows.Forms.Form
$Form.Text = "D&D SoundBoard"
$Form.IsMdiContainer = $true
$w = 1000
$h = 1000
$split = 8
$Currentlocation = Get-Location
$Form.Size = New-Object System.Drawing.Size($w,$h)
#$form.windowstate = "maximized"
$Form.StartPosition = "CenterScreen"
$formBuffer = 18

$controlBox = New-Object Windows.Forms.Panel
$script:musicButtonsBox = New-Object Windows.Forms.Panel
$script:ambianceButtonsBox = New-Object Windows.Forms.Panel
$script:musicTitleBox = New-Object Windows.Forms.Panel
$script:ambianceTitleBox = New-Object Windows.Forms.Panel
$script:pages = "Scene Music", "Battle Music", "Misc. Music"
$script:page = 1
$script:pageTitle = New-Object Windows.Forms.Label
$script:loopEntry = $true
$script:cancelMusic = $false
$script:cancelAmbiance = $false
$script:activeList = @()
$script:musicButtons = @()
$script:ambianceButons = @()

#musicBox Initialization
$musicColor = "Aliceblue"
$script:musicPlayer = New-Object system.windows.media.mediaplayer
$script:musicStopButton = New-Object System.Windows.Forms.Button
$script:musicMuteButtonText = "Mute"
$script:musicStopButton.Enabled = $False
$musicSlider = New-Object Windows.Forms.Trackbar
$musicHeader = New-Object Windows.Forms.Label
$musicLevel = New-Object Windows.Forms.Label
$musicPlaying = New-Object Windows.Forms.Label
$musicRepeat = New-Object Windows.Forms.Label
$script:musicLocation = New-Object Windows.Forms.Label
$script:song = ""
$script:musicMode = "OFF"
$script:musicPath = ""

#ambianceBox Initialization
$ambianceColor = "PaleGreen"
$script:ambiancePlayer = New-Object system.windows.media.mediaplayer
$script:ambianceStopButton = New-Object System.Windows.Forms.Button
$script:ambianceMuteButtonText = "Mute"
$script:ambianceStopButton.Enabled = $False
$ambianceSlider = New-Object Windows.Forms.Trackbar
$ambianceHeader = New-Object Windows.Forms.Label
$ambianceLevel = New-Object Windows.Forms.Label
$ambiancePlaying = New-Object Windows.Forms.Label
$ambianceRepeat = New-Object Windows.Forms.Label
$script:ambianceLocation = New-Object Windows.Forms.Label
$script:ambiance = ""
$script:ambianceMode = "OFF"
$script:ambiancePath = ""
 
$resizeHandler = { 
draw-musicTitle
draw-ambianceTitle
draw-MusicButtons
draw-ambianceButtons
draw-VolumeControls
update-Status
}

$Form.Add_Resize( $resizeHandler )

#stop everything that is playing if the form is closed early
$Form.add_FormClosing({  
	stopMusic_Click
	stopambiance_click
})
  
#play music button click function
function play_MusicClick(){
	$type = 0
	$script:title = $($script:activeList[$this.Name].Title)
    $script:musicStopButton.Enabled = $True
	if($script:musicPlayer.HasAudio -eq $true)
	{
		$script:musicPlayer.Stop()
		$script:musicPlayer.Close()
		Start-Sleep -Milliseconds 200
	}
    $script:musicPath = "$Currentlocation" + "\" + "$($script:activeList[$this.Name].File)"
	$CurrentSongDuration= New-TimeSpan -Seconds (Get-SongDuration $script:musicPath)
	play-Selection $script:musicPath $script:title $currentSongDuration $type
 	update-Status
}

#play ambiance button click function
function play_AmbianceClick(){
    $type = 2
	$script:title = $($ambianceList[$this.Name].Title)
    $script:ambianceStopButton.Enabled = $True
		if($script:ambiancePlayer.HasAudio -eq $true)
		{
			$script:ambiancePlayer.Stop()
			$script:ambiancePlayer.Close()
			Start-Sleep -Milliseconds 200
		}
    $script:ambiancePath = "$Currentlocation" + "\" + "$($ambianceList[$this.Name].File)"
	$CurrentSongDuration= New-TimeSpan -Seconds (Get-SongDuration $script:ambiancePath)
	play-Selection $script:ambiancePath $script:title $currentSongDuration $type
    update-Status
}
	
#music stop button function
function stopMusic_click(){
    $script:musicStopButton.Enabled = $False
	$script:musicPlayer.Stop()
	$script:musicPlayer.Close()
	Start-Sleep -milliseconds 100
	$script:song = ""
    $script:musicLocation.Text = "Duration: 00:00 / 00:00"	
	$script:cancelMusic = $true
    update-Status
}

#ambiance stop button function
function stopambiance_click(){
    $script:ambianceStopButton.Enabled = $False
	$script:ambiancePlayer.Stop()
	$script:ambiancePlayer.Close()
	Start-Sleep -milliseconds 100
	$script:ambiance = ""
    $script:ambianceLocation.Text = "Duration: 00:00 / 00:00"
	$script:cancelAmbiance = $true
	update-Status
}

#music repeat button function
function repeatMusic_click(){
	if($script:musicMode -eq "OFF"){
		$script:musicMode = "ON"
		update-Status
		}
	elseif($script:musicMode -eq "ON"){
		$script:musicMode = "OFF"
		update-Status
		}
}

#ambiance repeat button function
function repeatambiance_click(){
	if($script:ambianceMode -eq "OFF"){
		$script:ambianceMode = "ON"
		update-Status
		}
	elseif($script:ambianceMode -eq "ON"){
		$script:ambianceMode = "OFF"
		update-Status
		} 
}

#pageLeft button fuction
function pageLeft_click(){
    $script:pageRight.Enabled = $True
    if($script:page -gt 0)
    {
        $script:page--
    }
    if($script:page -eq 0){$script:pageLeft.Enabled = $False}
        Start-Sleep -Milliseconds 200
        $script:pageTitle.Text = $script:pages[$script:page]
        Start-Sleep -Milliseconds 100
        update-Buttons
}

#pageRight button fuction
function pageRight_click(){
    $script:pageLeft.Enabled = $True
    if($script:page -lt 2)
    {
        $script:page++
    }
    if($script:page -eq 2){$script:pageRight.Enabled = $False}
        Start-Sleep -Milliseconds 200
        $script:pageTitle.Text = $script:pages[$script:page]
        Start-Sleep -Milliseconds 100
        update-Buttons
}

function muteMusic_click(){
    if($script:musicPlayer.IsMuted -eq $false)
    {
    $script:musicPlayer.IsMuted = $true
    $script:musicMuteButtonText = "Unmute"
    $musicLevel.Text = "Vol: $script:musicVolValue (Muted)"

    }
    else
    {
    $script:musicPlayer.IsMuted =$false
    $script:musicMuteButtonText = "Mute"
    $musicLevel.Text = "Vol: $script:musicVolValue"
    }
    update-Status
}

function muteAmbiance_click(){
    if($script:ambiancePlayer.IsMuted -eq $false)
    {
    $script:ambiancePlayer.IsMuted = $true
    $script:ambianceMuteButtonText = "Unmute"
    $ambianceLevel.Text = "Vol: $script:ambianceVolValue (Muted)"

    }
    else
    {
    $script:ambiancePlayer.IsMuted =$false
    $script:ambianceMuteButtonText = "Mute"
    $ambianceLevel.Text = "Vol: $script:ambianceVolValue"
    }
    update-Status
}

#musicplayer TrackBar Event Handler
$musicSlider.add_ValueChanged({
	$script:musicVolValue = $musicSlider.Value
	$script:musicPlayer.volume = $script:musicVolValue/100
    if($script:musicPlayer.IsMuted -eq $false)
    {
	    $musicLevel.Text = "Vol: $script:musicVolValue"
    }
    else
    {
        $musicLevel.Text = "Vol: $script:musicVolValue (Muted)"
    }
})

#ambianceVolSlider Event Handler
$ambianceSlider.add_ValueChanged({
	$script:ambianceVolValue = $ambianceSlider.Value
	$script:ambiancePlayer.volume = $script:ambianceVolValue/100
    if($script:ambiancePlayer.IsMuted -eq $false)
    {
	    $ambianceLevel.Text = "Vol: $script:ambianceVolValue"
    }
    else
    {
        $ambianceLevel.Text = "Vol: $script:ambianceVolValue (Muted)"
    }
})
 
#draw-musicButtons Function
function draw-MusicButtons{
	$script:musicButtonsBox.Controls.Clear()
	$form.Controls.Add($script:musicButtonsBox)

	#buttonsBox initialization	
	$buttonBoxWidth = (($Form.Size.Width - 18)*4/7)				
	$buttonBoxHeight = (($Form.Size.Height*9/10 - 35))		
	$script:musicButtonsBox.Size = New-Object System.Drawing.Size($buttonBoxWidth, $buttonBoxHeight)
	$script:musicButtonsBox.Location = New-Object System.Drawing.Size(1,($script:musicTitleBox.Bottom - 1))
    $script:musicButtonsBox.BorderStyle = "FixedSingle"
		
	$buttonWidth = (($buttonBoxWidth - 2)/5)			
	$buttonHeight = (($buttonBoxHeight -2)/9)					
	
    $script:musicButtons = @()
	
	#Write-Host "$buttonBoxHeight" -fore green

    for( $i=0; $i -lt 50; $i++ ){
        $button = New-Object System.Windows.Forms.Button
        $script:musicButtons = $script:musicButtons + $button
        $script:musicButtons[$i].Name = $i;
		
        if($i -lt 5)
		{
            $script:musicButtons[$i].Location = New-Object System.Drawing.Size((($buttonWidth) * ($i - 0)),(($buttonHeight) * 0))
		} 
		elseif($i -lt 10) 
		{
            $script:musicButtons[$i].Location = New-Object System.Drawing.Size((($buttonWidth) * ($i - 5)),(($buttonHeight) * 1))
        } 
		elseif($i -lt 15) 
		{
            $script:musicButtons[$i].Location = New-Object System.Drawing.Size((($buttonWidth) * ($i - 10)),(($buttonHeight) * 2))
        } 
		elseif($i -lt 20) 
		{
            $script:musicButtons[$i].Location = New-Object System.Drawing.Size((($buttonWidth) * ($i - 15)),(($buttonHeight) * 3))
        } 
		elseif($i -lt 25) 
		{
            $script:musicButtons[$i].Location = New-Object System.Drawing.Size((($buttonWidth) * ($i - 20)),(($buttonHeight) * 4))
        } 
		elseif($i -lt 30) 
		{
            $script:musicButtons[$i].Location = New-Object System.Drawing.Size((($buttonWidth) * ($i - 25)),(($buttonHeight) * 5))
        } 
		elseif($i -lt 35) 
		{
            $script:musicButtons[$i].Location = New-Object System.Drawing.Size((($buttonWidth) * ($i - 30)),(($buttonHeight) * 6))
        } 
		elseif($i -lt 40) 
		{
            $script:musicButtons[$i].Location = New-Object System.Drawing.Size((($buttonWidth) * ($i - 35)),(($buttonHeight) * 6))
        } 
		elseif($i -lt 45) 
		{
            $script:musicButtons[$i].Location = New-Object System.Drawing.Size((($buttonWidth) * ($i - 40)),(($buttonHeight) * 7))
        } 
		elseif($i -lt 50) 
		{
            $script:musicButtons[$i].Location = New-Object System.Drawing.Size((($buttonWidth) * ($i - 45)),(($buttonHeight) * 8))
        } 

        $script:musicButtons[$i].Size = New-Object System.Drawing.Size($buttonWidth, $buttonHeight)
        if($script:page -eq 0)
        {
            $script:musicButtons[$i].Text = "$($citySongs[$i].Title) `n$($citySongs[$i].Subtext)"
            $script:activeList = $citySongs
        }
        if($script:page -eq 1)
        {
            $script:musicButtons[$i].Text = "$($battleSongs[$i].Title) `n$($battleSongs[$i].Subtext)"
            $script:activeList = $battleSongs
        }
        if($script:page -eq 2)
        {
            $script:musicButtons[$i].Text = "$($mysterySongs[$i].Title) `n$($mysterySongs[$i].Subtext)"
            $script:activeList = $mysterySongs
        }
        #$script:musicButtons[$i].UseVisualStyleBackColor = $false 
        #$script:musicButtons[$i].ResetBackColor()
        $script:musicButtons[$i].BackColor=$musicColor
		$script:musicButtons[$i].Font = "Comic Sans MS, 10"
        $script:musicButtons[$i].Add_Click({play_MusicClick})
        $script:musicButtonsBox.Controls.Add($script:musicButtons[$i])
    }
}

#draw-ambiancButtons Function
function draw-ambianceButtons{
	$script:ambianceButtonsBox.Controls.Clear()
	$form.Controls.Add($script:ambianceButtonsBox)

	#buttonsBox initialization	
	$ambianceButtonBoxWidth = (($Form.Size.Width - 18)*3/7)							
	$ambianceButtonBoxHeight = (($Form.Size.Height*4/10) - 14)						
	$script:ambianceButtonsBox.Size = New-Object System.Drawing.Size($ambianceButtonBoxWidth, $ambianceButtonBoxHeight)
	$script:ambianceButtonsBox.Location = New-Object System.Drawing.Size($script:musicButtonsBox.Width,($script:ambianceTitleBox.Bottom - 1))
    $script:ambianceButtonsBox.BorderStyle = "FixedSingle"
		
	$buttonWidth = (($ambianceButtonBoxWidth - 2)/4)				
	$buttonHeight = (($ambianceButtonBoxHeight -2)/4)				
	
    $script:ambianceButtons = @()
	
    for( $i=0; $i -lt 16; $i++ ){
        $button = New-Object System.Windows.Forms.Button
        $script:ambianceButtons = $script:ambianceButtons + $button
        $script:ambianceButtons[$i].Name = $i;
		
        if($i -lt 4)
		{
            $script:ambianceButtons[$i].Location = New-Object System.Drawing.Size((($buttonWidth) * ($i - 0)),(($buttonHeight) * 0))
		} 
		elseif($i -lt 8) 
		{
            $script:ambianceButtons[$i].Location = New-Object System.Drawing.Size((($buttonWidth) * ($i - 4)),(($buttonHeight) * 1))
        } 
		elseif($i -lt 12) 
		{
            $script:ambianceButtons[$i].Location = New-Object System.Drawing.Size((($buttonWidth) * ($i - 8)),(($buttonHeight) * 2))
        } 
		elseif($i -lt 16) 
		{
            $script:ambianceButtons[$i].Location = New-Object System.Drawing.Size((($buttonWidth) * ($i - 12)),(($buttonHeight) * 3))
        } 

        $script:ambianceButtons[$i].Size = New-Object System.Drawing.Size($buttonWidth, $buttonHeight)
        $script:ambianceButtons[$i].Text = "$($ambianceList[$i].Title) `n$($ambianceList[$i].Subtext)" 
        $script:ambianceButtons[$i].BackColor = $ambianceColor
		$script:ambianceButtons[$i].Font = "Comic Sans MS, 10"
        $script:ambianceButtons[$i].Add_Click({play_AmbianceClick})
        $script:ambianceButtonsBox.Controls.Add($script:ambianceButtons[$i])
    }
}

#update-Buttons Function
function update-Buttons{
for( $i=0; $i -lt 40; $i++ ){
        if($script:page -eq 0)
        {
            $script:musicButtons[$i].Text = "$($citySongs[$i].Title) `n$($citySongs[$i].Subtext)"
            $script:activeList = $citySongs
        }
        if($script:page -eq 1)
        {
            $script:musicButtons[$i].Text = "$($battleSongs[$i].Title) `n$($battleSongs[$i].Subtext)"
            $script:activeList = $battleSongs
        }
        if($script:page -eq 2)
        {
            $script:musicButtons[$i].Text = "$($mysterySongs[$i].Title) `n$($mysterySongs[$i].Subtext)"
            $script:activeList = $mysterySongs
        }        
        $script:musicButtons[$i].BackColor=$musicColor
    }
}

#music title Function
function draw-musicTitle{
	$script:musicTitleBoxWidth = (($Form.Size.Width - $formBuffer)*4/7)
	$script:musicTitleBoxHeight = (($Form.Size.Height - 40)/12)	
		
	$script:musicTitleBox.Controls.Clear()
	$script:musicTitleBox.Size = New-Object System.Drawing.Size($script:musicTitleBoxWidth, $script:musicTitleBoxHeight)
	$script:musicTitleBox.Location = New-Object System.Drawing.Size(1,0)
	$script:musicTitleBox.BackColor = "lightGray"
	$script:musicTitleBox.BorderStyle = "FixedSingle"
	$form.Controls.Add($script:musicTitleBox)
		
    $buttonWidth = ($script:musicTitleBoxWidth/12)
    $buttonHeight =	($script:musicTitleBoxHeight/2)
	

	$script:pageLeft = New-Object System.Windows.Forms.Button
    $script:pageLeft.Size = New-Object System.Drawing.Size($buttonWidth, $buttonHeight)
    $script:pageLeft.Location = New-Object System.Drawing.Size(($script:musicTitleBoxWidth/4), ($script:musicTitleBoxHeight/2 - $pageLeft.Height/2))
    $script:pageLeft.BackColor = "LightGray"
    $script:pageLeft.Text = "<-"
	$script:pageLeft.Add_Click({pageLeft_click})
    $script:musicTitleBox.Controls.Add($script:pageLeft)
    
	$script:pageRight = New-Object System.Windows.Forms.Button
    $script:pageRight.Size = New-Object System.Drawing.Size($buttonWidth, $buttonHeight)
    $script:pageRight.Location = New-Object System.Drawing.Size(($script:musicTitleBoxWidth*3/4 - $pageRight.Width), ($script:musicTitleBoxHeight/2 - $pageRight.Height/2))
    $script:pageRight.BackColor = "LightGray"
    $script:pageRight.Text = "->"
	$script:pageRight.Add_Click({pageRight_click})
    $script:musicTitleBox.Controls.Add($script:pageRight)

	$script:pageTitle.Size = New-Object System.Drawing.Size($script:musicTitleBoxWidth, $script:musicTitleBoxHeight)
	$script:pageTitle.Location = New-Object System.Drawing.Point(0,0)
    $script:pageTitle.Text = $script:pages[$script:page]
    $script:pageTitle.Font = "Comic Sans MS, 22"
    $script:pageTitle.TextAlign = "MiddleCenter"
    $script:pageTitle.ForeColor = "Blue"
    $script:musicTitleBox.Controls.Add($script:pageTitle)
        
}

#ambiance title Function
function draw-ambianceTitle{
	$script:ambianceTitleBoxWidth = (($Form.Size.Width - $formBuffer)*3/7)
	$script:ambianceTitleBoxHeight = (($Form.Size.Height - 40)/12)	
		
	$script:ambianceTitleBox.Controls.Clear()
	$script:ambianceTitleBox.Size = New-Object System.Drawing.Size($script:ambianceTitleBoxWidth, $script:ambianceTitleBoxHeight)
	$script:ambianceTitleBox.Location = New-Object System.Drawing.Size($script:musicTitleBox.Width, 0)
	$script:ambianceTitleBox.BackColor = "LightGray"
	$script:ambianceTitleBox.BorderStyle = "FixedSingle"
	$form.Controls.Add($script:ambianceTitleBox)

    $ambianceTitle = New-Object System.Windows.Forms.Label
    $ambianceTitle.Text = "Ambiance"
    $ambianceTitle.Font = "Comic Sans MS, 22"
    $ambianceTitle.TextAlign = "MiddleCenter"
    $ambianceTitle.ForeColor = "Green"
    $ambianceTitle.Size = New-Object System.Drawing.Size($script:ambianceTitleBoxWidth,$script:ambianceTitleBoxHeight)
    $script:ambianceTitleBox.Controls.Add($ambianceTitle)
}

#draw-VolumeControls Function
function draw-VolumeControls{
	
	$controlBox.Controls.Clear()
    Start-Sleep -Milliseconds 100
	$form.Controls.Add($controlBox)
	
	$musVol = (100 * $script:musicPlayer.volume)
	$ambVol = (100 * $script:ambiancePlayer.volume)
		
	$controlBoxWidth = (($Form.Size.Width - $formBuffer)*3/7)
	$controlBoxHeight = (($Form.Size.Height - 40)/2)
	$sliderWidth = ($controlWidth - 20)
	$buttonHeight = ($controlBoxHeight/7)
	$buttonWidth = ($controlBoxWidth/4)
	$labelHeight = ($controlBoxHeight/16)
    $buttonBuffer = ($buttonWidth/4)
	
	$controlBox.Size = New-Object System.Drawing.Size($controlBoxWidth, $controlBoxHeight)
	$controlBox.Location = New-Object System.Drawing.Size(($script:musicTitleBox.Width),($script:ambianceButtonsBox.Bottom - 1))
	$controlBox.BorderStyle = "FixedSingle"
	$controlBox.BackColor = "lightgray"
	
	#music player display and controls
	$musicHeader.Size = New-Object System.Drawing.Size($controlBoxWidth, ($controlBoxHeight/10))
	$musicHeader.Location = New-Object System.Drawing.Point(0,0)
	$musicHeader.Font = "Comic Sans MS, 18"
	$musicHeader.Text = "Music"
	$musicHeader.TextAlign = "MiddleCenter"
	$controlBox.Controls.Add($musicHeader)
	
    $script:musicLocation.Size = New-Object System.Drawing.Size(($controlBoxWidth/2), $labelHeight)
	$script:musicLocation.Location = New-Object System.Drawing.Size(($controlBoxWidth/2), $musicHeader.bottom)
	$script:musicLocation.Font = "Comic Sans MS, 10"
	$script:musicLocation.Text = "Duration: 00:00 / 00:00"
	$ControlBox.Controls.Add($script:musicLocation)

	$musicPlaying.Size = New-Object System.Drawing.Size(($controlBoxWidth/2), $labelHeight)
	$musicPlaying.Location = New-Object System.Drawing.Size(5, $musicHeader.bottom)
	$musicPlaying.Font = "Comic Sans MS, 10"
	$musicPlaying.Text = "Playing: $script:song"
	$ControlBox.Controls.Add($musicPlaying)

	$musicRepeat.Size = New-Object System.Drawing.Size(($controlBoxWidth/2), $labelHeight)
	$musicRepeat.Location = New-Object System.Drawing.Point(($controlBoxWidth/2), $script:musicLocation.bottom)
	$musicRepeat.Font = "Comic Sans MS, 10"
	$musicRepeat.Text = "Repeat: $musicMode"
	$controlBox.Controls.Add($musicRepeat)
	
	$musicLevel.Size = New-Object System.Drawing.Size(($controlBoxWidth/2), $labelHeight)
	$musicLevel.Location = New-Object System.Drawing.Point(5, $musicPlaying.bottom)
	$musicLevel.Font = "Comic Sans MS, 10"
	$musicLevel.Text = "Vol: $musVol"
	$controlBox.Controls.Add($musicLevel)
	
	$musicSlider.Orientation = "Horizontal"
	$musicSlider.Width = ($controlBoxWidth - $buttonBuffer*2)
	$musicSlider.TickFrequency = 10
	$musicSlider.Tickstyle = "Bottom"
	$musicSlider.setRange(0, 100)
	$musicSlider.Value = $musVol
	$musicSlider.Location = New-Object System.Drawing.Point($buttonBuffer,$musicLevel.bottom)
	$controlBox.Controls.Add($musicSlider)

	#music stop button
    $script:musicStopButton.Size = New-Object System.Drawing.Size($buttonWidth, $buttonHeight)
	$script:musicStopButton.Location = New-Object System.Drawing.Size($buttonBuffer, $musicSlider.bottom)
    $script:musicStopButton.BackColor = $musicColor
    $script:musicStopButton.Text = "Stop"
    $script:musicStopButton.Add_Click({stopMusic_click})
    $controlBox.Controls.Add($musicStopButton)
	
	#music repeat button

    $script:musicMuteButton = New-Object System.Windows.Forms.Button
    $script:musicMuteButton.Size = New-Object System.Drawing.Size($buttonWidth, $buttonHeight)
    $script:musicMuteButton.Location = New-Object System.Drawing.Size(($buttonWidth*3/2), $musicSlider.bottom)
    $script:musicMuteButton.BackColor = $musicColor
    $script:musicMuteButton.Text = $script:musicMuteButtonText
    $script:musicMuteButton.Add_Click({MuteMusic_click})
    $controlBox.Controls.Add($script:musicMuteButton)

	#music repeat button
	$musicRepeatButton = New-Object System.Windows.Forms.Button
    $musicRepeatButton.Size = New-Object System.Drawing.Size($buttonWidth, $buttonHeight)
    $musicRepeatButton.Location = New-Object System.Drawing.Size(($buttonWidth*2 + $buttonBuffer*3), $musicSlider.bottom)
    $musicRepeatButton.BackColor = $musicColor
    $musicRepeatButton.Text = "Repeat"
	$musicRepeatButton.Add_Click({repeatMusic_click})
    $controlBox.Controls.Add($musicRepeatButton)
    		
	#ambiance player display and controls
	$ambianceHeader.Size = New-Object System.Drawing.Size($controlBoxWidth, ($controlBoxHeight/10))
	$ambianceHeader.Location = New-Object System.Drawing.Point(0,($controlBoxHeight/2))
	$ambianceHeader.Font = "Comic Sans MS, 18"
	$ambianceHeader.Text = "Ambiance"
	$ambianceHeader.TextAlign = "MiddleCenter"
	$controlBox.Controls.Add($ambianceHeader)
	
    $script:ambianceLocation.Size = New-Object System.Drawing.Size(($controlBoxWidth/2), $labelHeight)
	$script:ambianceLocation.Location = New-Object System.Drawing.Size(($controlBoxWidth/2), $ambianceHeader.bottom)
	$script:ambianceLocation.Font = "Comic Sans MS, 10"
	$script:ambianceLocation.Text = "Duration: 00:00 / 00:00"
	$ControlBox.Controls.Add($script:ambianceLocation)
	
	$ambiancePlaying.Size = New-Object System.Drawing.Size(($controlBoxWidth/2), $labelHeight)
	$ambiancePlaying.Location = New-Object System.Drawing.Size(5, $ambianceHeader.bottom)
	$ambiancePlaying.Font = "Comic Sans MS, 10"
	$ambiancePlaying.Text = "Playing: $script:song"
	$ControlBox.Controls.Add($ambiancePlaying)
	
	$ambianceRepeat.Size = New-Object System.Drawing.Size(($controlBoxWidth/2), $labelHeight)
	$ambianceRepeat.Location = New-Object System.Drawing.Point(($controlBoxWidth/2), $script:ambianceLocation.bottom)
	$ambianceRepeat.Font = "Comic Sans MS, 10"
	$ambianceRepeat.Text = "Repeat: $ambianceMode"
	$controlBox.Controls.Add($ambianceRepeat)
	
	$ambianceLevel.Size = New-Object System.Drawing.Size(($controlBoxWidth/2), $labelHeight)
	$ambianceLevel.Location = New-Object System.Drawing.Point(5, $ambiancePlaying.bottom)
	$ambianceLevel.Font = "Comic Sans MS, 10"
	$ambianceLevel.Text = "Vol: $ambVol"
	$controlBox.Controls.Add($ambianceLevel)
	
	$ambianceSlider.Orientation = "Horizontal"
	$ambianceSlider.Width = ($controlBoxWidth - $buttonBuffer*2)
	$ambianceSlider.TickFrequency = 10
	$ambianceSlider.Tickstyle = "Bottom"
	$ambianceSlider.setRange(0, 100)
	$ambianceSlider.Value = $ambVol
	$ambianceSlider.Location = New-Object System.Drawing.Point($buttonBuffer,$ambianceLevel.bottom)
	$controlBox.Controls.Add($ambianceSlider)

	#ambiance stop button
    $ambianceStopButton.Size = New-Object System.Drawing.Size($buttonWidth, $buttonHeight)
	$ambianceStopButton.Location = New-Object System.Drawing.Size($buttonBuffer, $ambianceSlider.Bottom)
    $ambianceStopButton.BackColor = $ambianceColor
    $ambianceStopButton.Text = "Stop"
    $ambianceStopButton.Add_Click({stopambiance_click})
    $controlBox.Controls.Add($ambianceStopButton)
	
	#ambiance Mute button
    $script:ambianceMuteButton =  New-Object System.Windows.Forms.Button
    $script:ambianceMuteButton.Size = New-Object System.Drawing.Size($buttonWidth, $buttonHeight)
    $script:ambianceMuteButton.Location = New-Object System.Drawing.Size(($buttonWidth*3/2), $ambianceSlider.Bottom)
    $script:ambianceMuteButton.BackColor = $ambianceColor
    $script:ambianceMuteButton.Text = $script:musicMuteButtonText
	$script:ambianceMuteButton.Add_Click({Muteambiance_click})
    $controlBox.Controls.Add($script:ambianceMuteButton)
	
	#ambiance repeat button
	$ambianceRepeatButton = New-Object System.Windows.Forms.Button
    $ambianceRepeatButton.Size = New-Object System.Drawing.Size($buttonWidth, $buttonHeight)
    $ambianceRepeatButton.Location = New-Object System.Drawing.Size(($buttonWidth*2 + $buttonBuffer*3), $ambianceSlider.Bottom)
    $ambianceRepeatButton.BackColor = $ambianceColor
    $ambianceRepeatButton.Text = "Repeat"
	$ambianceRepeatButton.Add_Click({repeatambiance_click})
    $controlBox.Controls.Add($ambianceRepeatButton)
	
	
}

#update-Status Function
 Function update-Status{

	$musicPlaying.Text = "Playing: $script:song"	
	$musicRepeat.Text = "Repeat: $musicMode"
	$ambiancePlaying.Text = "Playing: $script:ambiance"
	$ambianceRepeat.Text = "Repeat: $ambianceMode"
    if($script:musicPlayer.IsMuted -eq $true)
    {
        $script:musicMuteButton.Text = $script:musicMuteButtonText
	    $musicLevel.Text = "Vol: $script:musicVolValue (Muted)"
	}
    elseif($script:musicPlayer.IsMuted -eq $false)
    {
        $script:musicMuteButton.Text = $script:musicMuteButtonText
	    $musicLevel.Text = "Vol: $script:musicVolValue"
    }
    if($script:ambiancePlayer.IsMuted -eq $true)
    {
        $script:ambianceMuteButton.Text = $script:ambianceMuteButtonText
	    $ambianceLevel.Text = "Vol: $script:ambianceVolValue (Muted)"
	}
    elseif($script:ambiancePlayer.IsMuted -eq $false)
    {
        $script:ambianceMuteButton.Text = $script:ambianceMuteButtonText
	    $ambianceLevel.Text = "Vol: $script:ambianceVolValue"
    }
}

#Get-SongDuration Function
Function Get-SongDuration($FullName) { 
	$Shell = New-Object -COMObject Shell.Application 
	$Folder = $shell.Namespace($(Split-Path $FullName)) 
	$File = $Folder.ParseName($(Split-Path $FullName -Leaf)) 
	
	[int]$h, [int]$m, [int]$s = ($Folder.GetDetailsOf($File, 27)).split(":") 

	$h*60*60 + $m*60 +$s 
} 

function play-Selection{
    param($songpath, $buttonTitle, $songDuration, $type)
    if($type -eq 0)
    {
	    $script:song = $buttonTitle
        $script:musicPlayer.open([uri]($songpath))
	    $script:musicPlayer.Volume = $script:musicVolValue/100 
	    $script:musicPlayer.Play()
        $script:cancelMusic = $false
	    Start-Sleep -milliseconds 300
	    update-Status
    }
    elseif($type -eq 2)
    {
	    $script:ambiance = $buttonTitle
    	$script:ambiancePlayer.open([uri]($ambiancePath))
	    $script:ambiancePlayer.Volume = $script:ambianceVolValue/100 
	    $script:ambiancePlayer.Play()
        $script:cancelAmbiance = $fasle
	    Start-Sleep -milliseconds 300
    }
    
	if($script:loopEntry -eq $true)
	{
		play-Loop
	}
}
	
function play-Loop{	
    $script:loopEntry = $false
    $internalLoopControl = $false
    $ambiantLoopControl = $false
    $musicLoopControl = $false
    While($true)
    {
    	[System.Windows.Forms.Application]::DoEvents()
    
	if(($script:cancelMusic -eq $true) -and ($script:cancelAmbiance -eq $true))
		{
			#Write-Host "Cancelling the Loop" -fore Red 
			$script:cancelMusic = $false
            $script:cancelAmbiance = $false
            $script:loopEntry = $true
			return;
		}
	
		#Start-Sleep -milliseconds 300
        
         

    if(($script:musicStopButton.Enabled -eq $true) -and ($script:musicPlayer.Position -ne 0))
        {
            $script:musicLocation.Text = "Duration: " + $script:musicPlayer.Position.ToString("mm\:ss") + " / " + $script:musicPlayer.NaturalDuration.TimeSpan.ToString("mm\:ss")
        }
	if(($script:ambianceStopButton.Enabled -eq $true) -and ($script:ambiancePlayer.Position -ne 0))
        {
            $script:ambianceLocation.Text = "Duration: " + $script:ambiancePlayer.Position.ToString("mm\:ss") + " / " + $script:ambiancePlayer.NaturalDuration.TimeSpan.ToString("mm\:ss")
        }

	if($script:musicPlayer.Position.TotalSeconds -eq $script:musicPlayer.NaturalDuration.TimeSpan.TotalSeconds)
        {
            $musicLoopControl = $false
            if($script:musicMode -eq "ON")
            {
                #Write-Host "Repeat Loop: Repeating Music" -fore Yellow
			    $script:musicPlayer.Stop()
			    $script:musicPlayer.Close()
                Start-Sleep -Milliseconds 200
                $script:musicPlayer.open([uri]($script:musicPath))
                $script:musicPlayer.Volume = $script:musicVolValue/100 
                $script:musicPlayer.Play()
		    }

		    elseif($script:musicMode -eq "OFF")
		    {		
                #Write-Host "Repeat Loop: Music Ending!" -fore Yellow	
			    $script:musicPlayer.Stop()
			    $script:musicPlayer.Close()
                Start-Sleep -Milliseconds 100
                $script:musicLocation.text = "Duration: 00:00 / 00:00"
                $script:musicStopButton.Enabled = $false
                $musicLoopControl = $true
                #$script:loopEntry = $true
			    $script:song = ""
			    #return;
		    }
        }

        if($script:ambiancePlayer.Position.TotalSeconds -eq $script:ambiancePlayer.NaturalDuration.TimeSpan.TotalSeconds)
        {
            $ambiantLoopControl = $false
            if($script:ambianceMode -eq "ON")
            {
                #Write-Host "Repeat Loop: Repeating ambiance" -fore Yellow
			    $script:ambiancePlayer.Stop()
			    $script:ambiancePlayer.Close()
                Start-Sleep -Milliseconds 200
                $script:ambiancePlayer.open([uri]($script:ambiancePath))
                $script:ambiancePlayer.Volume = $script:ambianceVolValue/100 
                $script:ambiancePlayer.Play()
		    }

		    elseif($script:ambianceMode -eq "OFF")
		    {		
                #Write-Host "Repeat Loop: ambiance Ending!" -fore Yellow	
			    $script:ambiancePlayer.Stop()
			    $script:ambiancePlayer.Close()
                Start-Sleep -Milliseconds 100
                $script:ambianceLocation.text = "Duration: 00:00 / 00:00"
                $script:ambianceStopButton.Enabled = $false
                $ambiantLoopControl = $true
                #$script:loopEntry = $true
			    $script:ambiance = ""
			    #return;
		    }
        }

        if($musicLoopControl -and $ambiantLoopControl -eq $true)
        {
            Write-Host "Both music and ambaince stopped playing" -fore Yellow
            $script:loopEntry = $true
            return;
        }

        Start-Sleep -Milliseconds 200
        update-Status
	    
    }
    return;
}

draw-musicTitle
draw-ambianceTitle
draw-MusicButtons
draw-ambianceButtons
draw-VolumeControls

#Show form
$Form.Topmost = $False
$Form.Add_Shown({$Form.Activate()})
[void] $Form.ShowDialog()



