# qmail
A terminal utility to allow users to have a temporary email inbox right from their command line.

## Installation
`curl -sL https://raw.githubusercontent.com/mehtaarn000/qmail/main/qmail.sh >> qmail.sh && chmod +x qmail.sh && mv qmail.sh /usr/local/bin/qmail`

## Dependencies
[`jq`](https://github.com/stedolan/jq)

[`w3m`](http://w3m.sourceforge.net/)


## Usage
qmail options:

    -h or --help                      show help page of qmail
    -v or --version                   show version of qmail
    -a or --address                   show the current email address
    -g or --generate                  generate and store new random address
    -c or --custom [Email Address]    store a custom email address
    -i or --inbox                     check inbox
    -r or --read [id] [html option]   view and read message

## Examples
First, let's store a new random email address with `qmail -g`.

Output:
`qmail: Your temporary email address is: s133chze@1secmail.net`

Next, using an actual email service (such as Gmail or Outlook), send an email to this address.

Wait a few seconds, and then check your inbox with `qmail -i`

![View Inbox](https://github.com/mehtaarn000/qmail/blob/main/images/viewinbox.png)

Finally, read the email with `qmail -r 91775417` (the number at the end is the message ID that you see in the inbox)

![View Email](https://github.com/mehtaarn000/qmail/blob/main/images/viewemail.png)

## Extra
This project is heavily inspired by [@sdushantha's tmpmail.](https://github.com/sdushantha/tmpmail)