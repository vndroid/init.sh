#!/usr/bin/env bash

## Author: vndroid
## Github: https://github.com/vndroid/init.sh.git

command -v dpkg >/dev/null 2>&1 || { echo >&2 "Error: Not Support Current OS!"; exit 1; }
command -v dh_make >/dev/null 2>&1 || { echo >&2 "Error: Command 'dh_make' not found, Please install 'dh-make' package."; exit 1; }

Arch=$(dpkg --print-architecture)
case $Arch in
    mips64el)
        Arch="mips64el"
        ;;
    arm64)
        Arch="arm64"
        ;;
    amd64)
        Arch="amd64"
        ;;
    loongarch64)
        Arch="loongarch64"
        ;;
    *)
        echo "Error: Not Support This Arch."
        exit 3
esac

# Main
if [ ! -z $1 ];then
    Name="$1"
    Name=${Name,,}
    PName=$(echo $Name | awk -F '.' {'print $NF'})
    if [ ! -z $2 ];then
        Version=$(echo "$2" | sed 's/^[Vv]//')
    else
        echo "Error: Parameter 2 is missing."
        exit 1
    fi
else
    echo "Error: Parameter 1 is missing."
    exit 2
fi

if [ -d "./$Name-$Version" ];then
    cd $Name-$Version
else
    mkdir ./$Name-$Version
    cd $Name-$Version
fi

ProgramFiles=./opt/apps/$Name
mkdir -p $ProgramFiles/{entries,files}
mkdir -p $ProgramFiles/entries/{applications,icons,autostart}
mkdir -p $ProgramFiles/entries/icons/hicolor/scalable/apps/
mkdir -p $ProgramFiles/files/{bin,lib}
touch $ProgramFiles/entries/applications/$Name.desktop
touch $ProgramFiles/info

cat > $ProgramFiles/entries/applications/$Name.desktop <<'EOF'
[Desktop Entry]
Name=$PName
Name[zh_CN]=中文名
Comment=The English Comment
Comment[zh_CN]=中文说明
Exec=/opt/apps/$Name/files/bin/runApp.sh
Terminal=false
Icon=$Name
Categories=Development
Type=Application
EOF

cat > $ProgramFiles/info <<'EOF'
{
    "appid": "$AppID",
    "name": "$PName",
    "version": "$Version",
    "arch": ["$Arch"],
    "permissions": {
        "autostart": false,
        "notification": false,
        "trayicon": false,
        "clipboard": false,
        "account": false,
        "bluetooth": false,
        "camera": false,
        "audio_record": false,
        "installed_apps": false
    }
}
EOF

# Desktop-file injection
sed -i "s/\$PName/$PName/g" $ProgramFiles/entries/applications/$Name.desktop
sed -i "s/\$Name/$Name/g" $ProgramFiles/entries/applications/$Name.desktop

# Info-file injection
sed -i "s/\$AppID/$Name/g" $ProgramFiles/info
sed -i "s/\$Version/$Version/g" $ProgramFiles/info
sed -i "s/\$Arch/$Arch/g" $ProgramFiles/info
sed -i "s/\$PName/$PName/g" $ProgramFiles/info

# Add RedFlag distro support
grep -qi redflag /etc/os-release && {
    mkdir ./usr/share/ -p 
    mv $ProgramFiles/entries/applications ./usr/share/
    mv $ProgramFiles/entries/icons ./usr/share/
    rm  -fr $ProgramFiles/entries/ $ProgramFiles/info
}