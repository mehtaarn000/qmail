#IMPORTANT: This is very bad code that I threw together in a single day. Also, this is my first time ever using shell so... ¯\_(ツ)_/¯

random_email () {
    mkdir_qmail
    #Generate a random email for the user
    USERNAME=$(cat /dev/urandom | LC_ALL=C tr -dc 'a-z1-9' | fold -w 8 | head -n 1)
    DOMAIN_CHOICE=$(cat /dev/urandom | LC_ALL=C tr -dc '1-2' | fold -w 1 | head -n 1)
    DOTX_CHOICE=$(cat /dev/urandom | LC_ALL=C tr -dc '1-3' | fold -w 1 | head -n 1)

    if [ $DOMAIN_CHOICE == 1 ]
    then
        DOMAIN="@1secmail"
        DOMAINWITHOUTAT="1secmail"
    else
        DOMAIN="@wwjmp"
        DOMAINWITHOUTAT="wwjmp"
    fi
    if [ $DOTX_CHOICE == 1 ]
    then
        DOTX=".com"
    elif [ $DOTX_CHOICE == 2 ]  
    then
        DOTX=".net"
    else
        DOTX=".org"
    fi
    ADDRESS="$USERNAME$DOMAIN$DOTX"
    cd .qmail
    :> domain.txt && :> dotx.txt && :> email_addr.txt
    echo "qmail: Your temporary email address is: $ADDRESS"
    echo "$USERNAME" >> email_addr.txt && echo "$DOMAIN" >> domain.txt && echo "$DOTX" >> dotx.txt
    cd ..
    INITINBOXURL="https://www.1secmail.com/api/v1/?action=getMessages&login=$USERNAME&domain=$DOMAINWITHOUTAT$DOTX"
    RESPONSE=$(curl -sL $INITINBOXURL)
}

mkdir_qmail () {
    if [[ ! -d .qmail ]]
    then
        mkdir .qmail
        cd .qmail
        touch email_addr.txt && touch domain.txt && touch dotx.txt
        cd ..
        random_email
    fi
}

check_inbox () {
    mkdir_qmail
    #Get email address
    cd .qmail
    EXISTINGEMAILADDR=`cat email_addr.txt`
    EXISTINGDOMAIN=`cat domain.txt`
    EXISTINGDOTX=`cat dotx.txt`
    WITHOUTAT=${EXISTINGDOMAIN//@}
    BASE_URL="https://www.1secmail.com/api/v1/?action=getMessages&login=$EXISTINGEMAILADDR&domain=$WITHOUTAT$EXISTINGDOTX"

    #Get emails
    LENGTH=$(curl -sL $BASE_URL | jq length)
    if [[ $LENGTH -eq 0 ]]

    #If there are no emails
    then
        EXISTINGADDR="$EXISTINGEMAILADDR$EXISTINGDOMAIN$EXISTINGDOTX" 
        echo "Inbox of $EXISTINGADDR empty." && exit

    #If there are emails
    else
        EXISTINGADDR="$EXISTINGEMAILADDR$EXISTINGDOMAIN$EXISTINGDOTX"
        echo "-------------------Inbox of $EXISTINGADDR-------------------"
    fi
    for (( i=0; i < $LENGTH; ++i ))
    do
        ID=$(curl -sL $BASE_URL | jq -r ".[$i] | .id")
        FROM=$(curl -sL $BASE_URL | jq -r ".[$i] | .from")
        SUBJECT=$(curl -sL $BASE_URL | jq -r ".[$i] | .subject")
        DATE=$(curl -sL $BASE_URL | jq -r ".[$i] | .date")
        printf "$ID        $FROM       $SUBJECT       $DATE\n"
    done
    echo "--------------------------------------------------------------------"
    cd ..
}

generate_and_store_addr () {
    mkdir_qmail
    cd .qmail
    CHECKADDR=`cat email_addr.txt`
    CHECKDOMAIN=`cat domain.txt`
    CHECKDOTX=`cat dotx.txt`
    cd ..
    random_email
    check_inbox
}

view_email () {
    IFS=
    mkdir_qmail
    cd .qmail
    EXISTINGEMAILADDR=`cat email_addr.txt`
    EXISTINGDOMAIN=`cat domain.txt`
    EXISTINGDOTX=`cat dotx.txt`
    WITHOUTAT=${EXISTINGDOMAIN//@}
    VIEWURL="https://www.1secmail.com/api/v1/?action=readMessage&login=$EXISTINGEMAILADDR&domain=$WITHOUTAT$EXISTINGDOTX&id=$1"
    REQUEST=$(curl -sL $VIEWURL)
    if [[ $REQUEST == "Message not found" ]]
    then
        echo "qmail: Invalid Message ID" && exit 
    fi
    FROM=$(printf %s $REQUEST | jq -r ".from")
    SUBJECT=$(printf %s $REQUEST | jq -r ".subject")
    ATTACHMENTS=$(printf %s $REQUEST | jq -r ".attachments")
    TEXTBODY=$(printf %s $REQUEST | jq -r ".textBody")
    HTMLBODY=$(printf %s $REQUEST | jq -r ".htmlBody")
    :> email.html
    HTMLEMAIL="$(cat <<EOL
    <b>FROM: </b> $FROM 
    <br>
    <b>SUBJECT: </b> $SUBJECT
    <p>
        $HTMLBODY
    </p>
EOL
)"
    TEXTEMAIL=$(cat <<EOL
    <b>FROM: </b> $FROM 
    <br>
    <b>SUBJECT: </b> $SUBJECT
    <p>
        <pre>$TEXTBODY</pre>
    </p>
EOL
)

    if [[ $2 == '--html' ]] 
    then
        echo $HTMLEMAIL >> email.html
        w3m email.html
    else
        echo $TEXTEMAIL >> email.html
        w3m email.html
    fi

    cd ..
}

echo_addr () {
    mkdir_qmail
    cd qmail
    EXISTINGEMAILADDR=`cat email_addr.txt`
    EXISTINGDOMAIN=`cat domain.txt`
    EXISTINGDOTX=`cat dotx.txt`
    echo $EXISTINGEMAILADDR$EXISTINGDOMAIN$EXISTINGDOTX
    cd ..
}

#HELP Page
if [[ $1 == '-h' ]] || [[ $1 == '--help' ]] || [[ $1 == '' ]] 
then
cat << EOM
qmail options:
    -h or --help                      show help page of qmail
    -v or --version                   show version of qmail
    -a or --address                   show the current email address
    -g or --generate                  generate and store new random and email address
    -c or --custom [Email Address]    store a custom email address
    -i or --inbox                     check inbox
    -r or --read [id]                 view and read message
EOM

#Version
elif [[ $1 == '-v' ]] || [[ $1 == '--version' ]]
then
    echo "qmail v1.0"

#Check Inbox
elif [[ $1 == '-i' ]] || [[ $1 == '--inbox' ]]
then 
    check_inbox

#Generate address
elif [[ $1 == '-g' ]] || [[ $1 == '--generate' ]]
then
    random_email

elif [[ $1 == '-c' ]] || [[ $1 == '--custom' ]]
then
    CUSTOMADDR=(${2//@/ })
    SPLITTHIS=${2#*@}
    CUSTOMDOTX=${SPLITTHIS#*.}
    CUSTOMDOMAIN=${SPLITTHIS%.*}

    #Validate custom email address
    if  [[ "$CUSTOMDOMAIN" =~ "@" ]]
    then
        echo "qmail: Your custom email address must have an '@'." && exit
    elif [[ $CUSTOMDOMAIN != "wwjmp" ]] && [[ $CUSTOMDOMAIN != "1secmail" ]]
    then
        echo "qmail: Your custom email address's domain must be either: 'wwjmp' or '1secmail'" && exit
    elif [[ $CUSTOMDOTX != "com" ]] && [[ $CUSTOMDOTX != "net" ]] && [[ $CUSTOMDOTX != "org" ]]
    then
        echo "qmail: Your custom email address's domain .___ must be: '.net' or '.org' or '.com'" && exit
    fi
    cd .qmail
    :> domain.txt && :> dotx.txt && :> email_addr.txt
    echo $CUSTOMADDR >> email_addr.txt && echo "@$CUSTOMDOMAIN" >> domain.txt && echo ".$CUSTOMDOTX" >> dotx.txt
#View Emails
elif [[ $1 == '-r' ]] || [[ $1 == '--read' ]]
then
    if [[ $3 == "--html" ]]
    then 
        view_email $2 $3
    else
        view_email $2
    fi

#Display current email address
elif [[ $1 == '-a' ]] || [[ $1 == '--address' ]]
then
    echo_addr
else
    echo "'$1' is not a valid option. Please run 'qmail -h' to see all valid options." 
fi