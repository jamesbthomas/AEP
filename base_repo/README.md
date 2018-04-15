# GitWeb Script Execution Server
The GitWeb server takes input scripts using standard git processes, executes them, and services the results in a webpage on port 443.
## Usage
In order to have the server execute your scripts, you need to write your script, push it to the server, and open a webpage to wherever the GitWeb server is hosted on port 443.

You can send scripts to the GitWeb server manually, or through the gitweb.sh script provided in the initial repo.

A sample workflow to cat /etc/passwd is included below: 

Manual - 
```
echo "cat /etc/passwd" > script.sh
git add script.sh
git commit -m <commit message>
git push
```

Scripted - 
```
echo "cat /etc/passwd" > cat.sh
./gitweb.sh
```

To get the results of your script, simply navigate to the gitweb server on port 443 and request the name of your script follow by .html. For example, if your script is named script.sh, requesting https://gitwebserver/script.html will return an HTML page containing the results of your script.
Or, if you used gitweb.sh, the results of your script were saved to locally to the repo directory based on the name of the script that produced the output. For example, the script cat.sh would have output cat.html.
## Note
Be sure to issue a `git pull` before creating your script to avoid conflicts on the server side.
