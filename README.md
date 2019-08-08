Modifying the PSJukeBox-master application found at https://www.reddit.com/r/DnD/comments/6vzyak/custom_soundboard_using_powershell_gui/. 
Original GitHub link for this project is at https://github.com/fowlfables/PSJukebox.
Credit to orginal author belongs to Jason Groce

For this app to work propertly another folder needs to be added into the Soundboard folder. Name the folder Music and this is where the
music and effect sounds will be stored. Also the files soundboardMusic.csv and soundboardAmbiance.csv need to be edited to match the songs and sounds currently in the music folder.
Leave the top row of the ini and change the following line to match the songs/sounds you want to use. See below for example.

-----------------------------------------------------------------------------------------------------------------------------------------
<soundboardMusic.csv>

File,Title,Subtext,Page
Music\Troubled Times.mp3,Troubled Times,(Small Battle),0

-----------------------------------------------------------------------------------------------------------------------------------------

<soundboardAmbiance.csv>

File,Title,Subtext
Music\Marsh.wav,Marsh,(Wetlands)

-----------------------------------------------------------------------------------------------------------------------------------------


Attempting to expand on the original concept that Jason had with his jukebox/sound board to add more functionality.

1. Add ability to run both songs  and ambience noises at the same time - accomplished
2. Add ability to control volume level of each player individually - accomplished
3. Add ability to loop individual song or ambiance noise - accomplished
 
