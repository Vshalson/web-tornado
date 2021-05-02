#!/bin/bash

domain=$1
echo "lo domain  ${domain}"
WHOOK=https://discord.com/api/webhooks/820965584816177164/fJiUdeQ8uaVRXn2ZyChZNrMuZ9Yx4DFq0lpB5FZLnyUYjRGSK4XiDk43XHYvu2HtxRZ8 

info_path=$domain/info
screenshot_path=$domain/screenshots 

if [ ! -d "$domain" ];then 
	mkdir /loot/$domain
fi

if [ ! -d "$info_path" ];then 
	mkdir /loot/$info_path
fi

/bin/bash /tornado/attacks/discord.sh --webhook-url="$WHOOK" --avatar "https://i.pinimg.com/564x/4b/96/f1/4b96f1851eeb35795566f2634e51ca9e.jpg" --description "Starting Basic Workflow on ${domain}"


echo "really kon hai yeh?"

whois $domain > /loot/$info_path/whois.txt

echo "directory fuzzing"

ffuf -c -w /tornado/players/dirsearch.txt -u https://$domain/FUZZ >> /loot/$info_path/Dfuzz.txt

/bin/bash /tornado/attacks/discord.sh --webhook-url="$WHOOK" --avatar "https://i.pinimg.com/564x/4b/96/f1/4b96f1851eeb35795566f2634e51ca9e.jpg" --description "Result of Ffuf DirFuzzing $(cat /loot/$info_path/Dfuzz.txt | wc -l)"

echo "search in gau*way"

waybackurls $domain >> /loot/$info_path/waygau.txt

gau $domain >> /loot/$info_path/waygau.txt

cat /loot/$info_path/waygau.txt |sort -u | httprobe | grep https | sed 's/https\?:\/\///' >> /loot/$info_path/og_waygau.txt

/bin/bash /tornado/attacks/discord.sh --webhook-url="$WHOOK" --avatar "https://i.pinimg.com/564x/4b/96/f1/4b96f1851eeb35795566f2634e51ca9e.jpg" --description "Result of Way*Gau $(cat /loot/$info_path/og_waygau.txt | wc -l)"

#js files in wayback and gau search

cat /loot/$info_path/waygau.txt | sort -u | grep "\.js" | uniq  >> /loot/$info_path/way_jsfiles.txt

# https://edoverflow.com/2017/broken-link-hijacking/

echo $domain | hakrawler -scope strict -usewayback -plain >> /loot/$info_path/urls_in_$domain.txt

cat /loot/$info_path/urls_in_$domain.txt | sort -u  > /loot/$info_path/final_urls.txt 

perl -i -ne '/^((?!\?).)*\.(css|css\/|jpg|jpg\/|png|png\/|gif\/|gif|doc\/|doc|pdf|pdf\/|mp3|mp4|svg|svg\/|ico)(\?.*|$)/ || print' /loot/$info_path/final_urls.txt
echo "broking linkss"
for word in $(cat /loot/$info_path/final_urls.txt); do /builder2/node_modules/broken-link-checker/bin/blc -rof --filter-level 3 $word ; done > /loot/$info_path/blc.txt

python3 /tornado/attacks/SecretFinder.py -i https://$domain/ -e -o cli > /loot/$info_path/Secrets.txt

/bin/bash /tornado/attacks/discord.sh --webhook-url="$WHOOK" --avatar "https://i.pinimg.com/564x/4b/96/f1/4b96f1851eeb35795566f2634e51ca9e.jpg" --description "Result of hakrawler $(cat /loot/$info_path/final_urls.txt | wc -l) and Broken link Checking $(cat /loot/$info_path/blc.txt | wc -l)"

# CHeck Most Common 1000 TCP Ports, to check sensitive files, data gathering, Outdated JS libraries(Retirejs) and detect CMS Technologies.
python3 /tornado/attacks/Striker/striker.py $domain | tail -n +20 >> /loot/$info_path/Sensitive_Check.txt

/bin/bash /tornado/attacks/discord.sh --webhook-url="$WHOOK" --avatar "https://i.pinimg.com/564x/4b/96/f1/4b96f1851eeb35795566f2634e51ca9e.jpg" --description "Result of THuNder Striker $(cat /loot/$info_path/Sensitive_Check.txt| wc -l; echo -e "\n") Done Workflow"
