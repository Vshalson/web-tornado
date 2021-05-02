#!/bin/bash
domain=$1
echo "Lo domain ${domain}"

WHOOK=https://discord.com/api/webhooks/820965584816177164/fJiUdeQ8uaVRXn2ZyChZNrMuZ9Yx4DFq0lpB5FZLnyUYjRGSK4XiDk43XHYvu2HtxRZ8 

#dis_webhook print domain and process start message

info_path=$domain/info
ss_path=$domain/screenshots 

if [ ! -d "$domain" ];then 
	mkdir /loot/$domain
fi

if [ ! -d "$info_path" ];then 
	mkdir /loot/$info_path
fi

if [ ! -d "$ss_path" ];then 
	mkdir /loot/$ss_path
fi

/bin/bash /tornado/attacks/discord.sh --webhook-url="$WHOOK" --avatar "https://i.pinimg.com/564x/4b/96/f1/4b96f1851eeb35795566f2634e51ca9e.jpg" --description "Starting Full Workflow on ${domain}"

echo "really kon hai yeh?"

whois $domain > /loot/$info_path/whois.txt

curl  https://crt.sh/?q=%.$domain&output=json | jq '.[] | {name_value}' | sed 's/\"//g'| sed 's/\*\.//g' | sed 's/\\n/\n/g' | sort -u |grep "name_value"|cut -d ' ' -f4 >> /loot/$info_path/subd.txt

curl http://web.archive.org/cdx/search/cdx?url=*.$domain/*&output=text&fl=original&collapse=urlkey |sort| sed -e 's_https*://__' -e "s/\/.*//" -e 's/:.*//' -e 's/^www\.//' | uniq >> /loot/$info_path/subd.txt 

curl  https://api.certspotter.com/v1/issuances?domain=$domain&expand=dns_names&expand=issuer | jq '.[].dns_names[]' | sed 's/\"//g' | sed 's/\*\.//g' | sort -u  >> /loot/$info_path/subd.txt

curl https://otx.alienvault.com/api/v1/indicators/domain/$domain/passive_dns |jq '.passive_dns[].hostname' 2>/dev/null |grep -o "\w.*$domain"|sort -u  >> /loot/$info_path/subd.txt 

curl  https://dns.bufferover.run/dns?q=.$domain | jq -r .FDNS_A[]|cut -d',' -f2 >> /loot/$info_path/subd.txt

subfinder -silent -d $domain -o /loot/$info_path/subf_result.txt &>/dev/null

amass enum -passive -norecursive -d $domain -o /loot/$info_path/amass.txt &>/dev/null


## Port Scan (warning: use when found in scope criteria)
# cat /loot/$info_path/subdomains.txt | xargs -n1 host | grep "has address" | cut -d" " -f4 | sort -u > /loot/$info_path/ip_list.txt

# masscan -iL /loot/$info_path/ip_list.txt -p0-65535 --rate=10000 -oL /loot/$info_path/scan.txt

cat /loot/$info_path/amass.txt /loot/$info_path/subf_result.txt /loot/$info_path/subd.txt | sort -u > /loot/$info_path/subdomains.txt 
rm /loot/$info_path/amass.txt /loot/$info_path/subf_result.txt /loot/$info_path/subd.txt

#dis_webhook prints counts of subdomain lines and head -10
/bin/bash /tornado/attacks/discord.sh --webhook-url="$WHOOK" --avatar "https://i.pinimg.com/564x/4b/96/f1/4b96f1851eeb35795566f2634e51ca9e.jpg" --description "Total found subdomain count and top subomain results $(wc -l /loot/$info_path/subdomains.txt && echo -e "\n" && head -10 /loot/$info_path/subdomains.txt)"

cat /loot/$info_path/subdomains.txt | httprobe | grep https | sed 's/https\?:\/\///' | sort -u >> /loot/$info_path/probe_subdomain.txt 


# Discover url endpoints

cat /loot/$info_path/subdomains.txt | while read line
do
	echo $line | hakrawler -scope strict -usewayback -plain >> /loot/$info_path/urls_in_$line.txt
done

#dis_webhook print counts of total url endpoints
/bin/bash /tornado/attacks/discord.sh --webhook-url="$WHOOK" --avatar "https://i.pinimg.com/564x/4b/96/f1/4b96f1851eeb35795566f2634e51ca9e.jpg" --description "Total url endpoints count $(ls urls* | wc -l)"


# remove url with extension (jpg|JPG|gif|GIF|doc|DOC|pdf|PDF|js) and cat all urls in one file
cat /loot/$info_path/urls* > /loot/$info_path/final_urls.txt 
perl -i -ne '/^((?!\?).)*\.(css|css\/|jpg|jpg\/|png|png\/|gif\/|gif|doc\/|doc|pdf|pdf\/|mp3|mp4|svg|svg\/|ico)(\?.*|$)/ || print' /loot/$info_path/final_urls.txt
		
for word in $(cat /loot/$info_path/final_urls.txt); do /builder2/node_modules/broken-link-checker/bin/blc -rof --filter-level 3 $word ; done > /loot/$info_path/blc.txt


#Corsy
cat /loot/$info_path/final_urls.txt | python3 /tornado/attacks/Corsy/corsy.py >> /loot/$info_path/corsy_result.txt

#secretsfinder
python3 /tornado/attacks/SecretFinder.py -i https://$domain/ -e -o cli > /loot/$info_path/Secrets.txt
/bin/bash /tornado/attacks/discord.sh --webhook-url="$WHOOK" --avatar "https://i.pinimg.com/564x/4b/96/f1/4b96f1851eeb35795566f2634e51ca9e.jpg" --description "Results of Secretsfinder $(ls /loot/$info_path/Secrets.txt | wc -l ) and Results of Corsy $(cat /loot/$info_path/corsy_result.txt | wc -l)"

# S3 bucket misconfiguration
cat /loot/$info_path/Secrets.txt | grep -E 's3\.amazonaws.com[/]+|[a-zA-Z0-9_-]*\.s3\.amazonaws.com' > /loot/$info_path/s3_bucket_found.txt
# for found in $(cat /loot/$info_path/s3_bucket_found.txt); do aws s3 ls $found ; done > /loot/$info_path/list_s3_bucket.txt

# CHeck Most Common 1000 TCP Ports, to check sensitive files, data gathering, Outdated JS libraries(Retirejs) and detect CMS Technologies.
python3 /tornado/attacks/Striker/striker.py $domain | tail -n +20 >> /loot/$info_path/Sensitive_Check.txt
#https://medium.com/techiepedia/s3-bucket-misconfiguration-50883f347869


# cat /loot/$info_path/subdomains.txt | aquatone -out folder name
# https://i.pinimg.com/564x/4b/96/f1/4b96f1851eeb35795566f2634e51ca9e.jpg