#!/usr/bin/env bash
command -v dpkg >/dev/null 2>&1 || { echo >&2 "Error: Not Support Current OS!"; exit 1; }

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
        Version="$2"
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
mkdir ./opt/apps/$Name/{entries,files} -p
mkdir ./opt/apps/$Name/entries/{applications,icons,autostart} -p
mkdir ./opt/apps/$Name/entries/icons/hicolor/scalable/apps/ -p
mkdir ./opt/apps/$Name/files/{bin,lib} -p
touch ./opt/apps/$Name/entries/applications/$Name.desktop
touch ./opt/apps/$Name/info

cat > ./opt/apps/$Name/entries/applications/$Name.desktop <<'EOF'
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

cat > ./opt/apps/$Name/info <<'EOF'
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
sed -i "s/\$PName/$PName/g" ./opt/apps/$Name/entries/applications/$Name.desktop
sed -i "s/\$Name/$Name/g" ./opt/apps/$Name/entries/applications/$Name.desktop

# Info-file injection
sed -i "s/\$AppID/$Name/g" ./opt/apps/$Name/info
sed -i "s/\$Version/$Version/g" ./opt/apps/$Name/info
sed -i "s/\$Arch/$Arch/g" ./opt/apps/$Name/info
sed -i "s/\$PName/$PName/g" ./opt/apps/$Name/info
