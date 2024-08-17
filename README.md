# Roblox shortcut deleter

## Description 

### A simple script created using ChatGPT to delete the stupid Roblox shortcuts created on every update, because Roblox refuses to remove this "feature"

Because Roblox won't.

If I was a normal person, I would just delete the Studio shortcuts from my desktop and start menu folders, but no, I am like this. (:




## Installation

 - Have Window$. I have Window$ 10, didn't test on anything else, may or may not work, no warranty or support of any kind will be provided here, ask chatgpt if needed.
 - Download the script.ps1 file, you can read through it if you want, but I don't ship bullshit. (:
 - Open the Run window, or an explorer window and put "shell:startup" (without the quotation marks, obviously) into the "Open" text box, or the location bar.
   - An explorer window should open at a path like: C:\Users\<username>\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup
   - Shortcuts may or may not be in here already, don't do anything to them, you might mess something up, or disable some programs from automatically starting (might be something you want though, idk)
 - put the script into this folder, the script will run on startup and watch for file changes in your Desktop folder
   - If you have a weird desktop folder, open the script up in an editor and change the path.