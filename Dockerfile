FROM node:lts-alpine
RUN apk add --no-cache git
RUN npm install -g yo generator-hubot
RUN adduser -D hubot
USER hubot
WORKDIR /home/hubot
RUN yo hubot --owner="Merrygold <merrymcx@gmail.com>" --name="hubot" --description="Hubot for slack" --adapter="slack" --defaults
RUN npm install --save hubot-slack
RUN npm install --save hubot-google-images
RUN npm install --save hubot-google-translate
RUN npm install --save hubot-grafana
RUN npm install --save hubot-pager-me

CMD ["bin/hubot", "--adapter", "slack"]