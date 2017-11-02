Modifying the PSJukeBox-master application found at https://www.reddit.com/r/DnD/comments/6vzyak/custom_soundboard_using_powershell_gui/. 
Original GitHub link for this project is at https://github.com/fowlfables/PSJukebox.
Credit to orginal author belongs to Jason Groce

For this app to work propertly another folder needs to be added into the Soundboard folder. Name the folder Music and this is where the
music and effect sounds will be stored. Also the Soundboard.ini file needs to be edited to match the sounds currently in the music folder.
Leave the top row of the ini and change the following line to match the songs/sounds you want to use. See below for example.

-----------------------------------------------------------------------------------------------------------------------------------------
File,Title,Type
"Music\Troubled Times.mp3","Troubled Times (Small Battle)",0

-----------------------------------------------------------------------------------------------------------------------------------------

The field type determines if the sound will be opened in the music player (0), effects player (1), or ambience player (2).

Attempting to expand on the original concept that Jason had with his jukebox/sound board to add more functionality.

1. Add ability to run both songs, effects, and ambience noises at the same time - accomplished
2. Add ability to control volume level of each player individually - accomplished
3. Add ability to loop individual song, effect, or ambient noise - working on / help needed (believe I need to move the media players to 
  individual jobs.)
4. more to come...
 
