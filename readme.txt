im basically making a vulnerability scanning tool with flask and python. 
when I enter a ip in the html field (index.html) and its sent to backend (mainapp.py). then the backend works its 
magic grabbing what data it needs then POST (sent out to the results.html). 


all the info displays and shows pings, dns resolution and all that but the section with open ports 
just says none detected same with os, when it was working on previous ips recently.

(scan.py used for storing the methods while mainapp.py used for routing, calling and catching data)
(when executing use "python3 mainapp.py") in terminal will spit out ip/port paste into search engine


(this uses imports which u will have to download and a installtion of nmap)


**Just fixed ports only os to go 17/04/25 15:26- code updated in drive