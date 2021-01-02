# linus

Uses the fantastic dataset from [linusrants](https://github.com/corollari/linusrants). 

## Building
`stack run`

## Usage
Default port is 3000. A `GET` request to /rants will return a random angry @torvalds message. There's an optional query parameters `count` that lets you receive more messages in a single request. Responses come in JSON format. 

## Why?
To flex on Ed and his competing Linusbot.
