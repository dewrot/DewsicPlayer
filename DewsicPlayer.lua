configHost = "https://github.com/dewrot/DewsicPlayer/raw/main/music/"
configFile = "Default"
configExtension = ".dfpwm"
configDewTube = "https://yt-cc.herokuapp.com/"

dfpwm = require("cc.audio.dfpwm")
Download = configHost..configFile..configExtension
drive = peripheral.find("drive")
speaker = peripheral.find("speaker")
errors = 0
multierror = "error"

term.setBackgroundColor(colors.black)
term.clear()
term.setCursorPos(1,1)
term.setTextColor(colors.white)

print("Dewsic Player Version 1.1")
print("Modified version of LimewireCC v2.1 by AstoriaCC")
print("This code is Zlib licensed.")
print("")

if drive == nil then
    print("Please attach a floppy drive and insert blank floppy to continue...")
    errors = (errors+2)
elseif drive.isDiskPresent() == false then
    print("Please insert a blank floppy to continue...")
    errors = (errors+1)
end

if speaker == nil then
    print("Please attach a speaker to continue...")
    errors = (errors+1)
end

if (errors >= 2) then
    multierror = "errors"
else
    multierror = "error"
end


function playMusic()
    local decoder = dfpwm.make_decoder()

    for chunk in io.lines("/disk/music.dfpwm",16*1024) do
        local buffer = decoder(chunk)
        while not speaker.playAudio(buffer,1) do
            os.pullEvent("speaker_audio_empty")
        end
    end
end


if not (errors == 0) then
    print("")
    print("")
    error("You have "..errors.." "..multierror.."! Please resolve "..multierror.." to continue.",0)
else
    print("Which Operation would you like to use?")
    print("1:Stream a file(Case Sensitive)")
    print("2:List files available for streaming")
    print("3:Play a YouTube link(ex. https://www.youtube.com/watch?v=dQw4w9WgXcQ )")
    print("Enter:Exit Dewsic Player")
    local op = read()

    if op == "1" then

        print("Please enter filename you would like to stream")
        write("File: ")
        configFile = read()
        FName = configFile..configExtension
        url = configHost..FName
        local response = http.get(url, nil, true) -- THIS IS IMPORTANT
        print("Clearing cache")
        shell.run("delete /disk/music.dfpwm")
        print("Downloading")
        shell.run("wget", ""..url.." /disk/music.dfpwm")
        response.close()
        drive.setDiskLabel("Streaming Floppy")
        print("Streaming ["..configFile.."] now")
        playMusic()
        sleep(3)
        shell.run("DewsicPlayer")

    end

    if op == "2" then

        local handle = assert(http.get("https://api.github.com/repos/dewrot/DewsicPlayer/contents/music?ref=main"))
        local files = textutils.unserializeJSON(handle.readAll())
        handle.close()
        local t ={}

        for _, v in ipairs(files) do
            listName = string.gsub(v.name, ".dfpwm", "")
            table.insert(t, listName)
            s = table.concat(t, " | ")
        end

        print(s)
        sleep(3)
        shell.run("DewsicPlayer")
    end

    if op == "3" then

        print("Please enter the YouTube URL you would like to play")
        write("URL: ")
        url = read()
        local response = http.post(configDewTube, url, nil, true) -- THIS IS IMPORTANT
        newURL = response.readAll()
        print("Clearing cache")
        shell.run("delete /disk/music.dfpwm")
        print("Downloading")
        shell.run("wget", ""..newURL.." /disk/music.dfpwm")
        response.close()
        drive.setDiskLabel("Streaming Floppy")
        print("Streaming ["..url.."] now")
        playMusic()
        sleep(3)
        shell.run("DewsicPlayer")

    end

    term.setBackgroundColor(colors.black)
    term.setCursorPos(1,1)
    term.clear()

end
