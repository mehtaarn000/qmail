a=$(curl "https://www.1secmail.com/api/v1/?action=getMessages&login=newaddr&domain=1secmail.com" | jq -r ".[0] | .from")
echo $a
