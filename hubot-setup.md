# Deploy Hubot for slack to GKE

## Prerequisites

1.  [Create a Google Cloud Platform project](https://console.cloud.google.com/project).
    You can also select an existing project.
1.  [Enable billing](https://support.google.com/cloud/answer/6293499#enable-billing)
    for your project.
1.  [Enable the Container Engine API](https://console.cloud.google.com/flows/enableapi?apiid=container.googleapis.com).
1.  [Install and initialize the Cloud SDK](https://cloud.google.com/sdk/docs/quickstarts).
1.  [Install kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/).

## Create a cluster

1.  Create a cluster with 3 nodes:

        gcloud container clusters create hubot --num-nodes 3

1.  Get the credentials for the cluster:
    
            gcloud container clusters get-credentials hubot

## Create a service account

1.  Create a service account:

        gcloud iam service-accounts create hubot

1.  Create a key for the service account:
    
            gcloud iam service-accounts keys create hubot-sa.json --iam-account hubot@${PROJECT_ID}.iam.gserviceaccount.com

1.  Grant the service account the following roles:
    
            gcloud projects add-iam-policy-binding ${PROJECT_ID} --member serviceAccount:hubot@${PROJECT_ID}.iam.gserviceaccount.com --role roles/container.admin
            gcloud projects add-iam-policy-binding ${PROJECT_ID} --member serviceAccount:hubot@${PROJECT_ID}.iam.gserviceaccount.com --role roles/storage.admin

## Create a storage bucket

1.  Create a storage bucket:

        gsutil mb gs://${PROJECT_ID}

## Create a secret

1.  Create a secret:

        kubectl create secret generic hubot-sa --from-file=hubot-sa.json

## Create a config map

1.  Create a config map:

        kubectl create configmap hubot-config --from-file=hubot-scripts.json

## Deploy Hubot

1.  Create a [Hubot Slack app](https://slack.com/apps/A0F7XDU93-hubot) and
    copy the API token.

    # Create Hubot app and dockerize it
    $ yo hubot --adapter slack
    ## Create Dockerfile
    $ touch Dockerfile
    ```
    FROM node:8.9.4-alpine
    RUN apk add --no-cache git
    RUN npm install -g yo generator-hubot
    RUN adduser -D hubot
    USER hubot
    WORKDIR /home/hubot
    RUN yo hubot --owner="Merrygold <merrymcx@gmail.com>" --name="hubot" --description="Hubot for slack" --adapter="slack" --defaults
    RUN npm install --save hubot-slack
    RUN npm install --save hubot-google-images
    RUN npm install --save hubot-google-translate
    
    CMD ["bin/hubot", "--adapter", "slack"]
    ```
    $ docker build -t hubot .
    $ docker tag hubot gcr.io/${PROJECT_ID}/hubot
    $ gcloud docker -- push gcr.io/${PROJECT_ID}/hubot

1.  Deploy Hubot:

        kubectl create -f hubot.yaml
        ```yaml
        apiVersion: extensions/v1beta1
        kind: Deployment
        metadata:
          name: hubot
        spec:
            replicas: 1
            template:
                metadata:
                labels:
                    app: hubot
                spec:
                containers:
                - name: hubot
                    image: gcr.io/${PROJECT_ID}/hubot
                    env:
                    - name: HUBOT_SLACK_TOKEN
                    valueFrom:
                        secretKeyRef:
                        name: hubot-sa
                        key: slack-token
                    - name: HUBOT_GOOGLE_CLOUD_PROJECT
                    value: ${PROJECT_ID}
                    volumeMounts:
                    - name: hubot-scripts
                    mountPath: /home/hubot/scripts
                volumes:
                - name: hubot-scripts
                    configMap:
                    name: hubot-config
        ---
        apiVersion: v1
        kind: Service
        metadata:
            name: hubot
        spec:
            type: LoadBalancer
            ports:
            - port: 80
            selector:
            app: hubot
        ```
1.  Get the external IP address of the service:
    
            kubectl get service hubot

1.  Add the external IP address to the Slack app.

1.  Test Hubot:

        hubot help

## Cleanup

1.  Delete the cluster:

        gcloud container clusters delete hubot

1.  Delete the service account:

1.  Create a [Hubot HipChat app](https://www.hipchat.com/addons/admin/create) and
    copy the API token.
1.  Create a [Hubot Flowdock app](https://www.flowdock.com/account/applications/new)
    and copy the API token.
1.  Create a [Hubot Gitter app](https://developer.gitter.im/apps) and copy the
    API token.
1.  Create a [Hubot Discord app](https://discordapp.com/developers/applications/me)
    and copy the API token.
1.  Create a [Hubot Telegram app](https://core.telegram.org/bots#3-how-do-i-create-a-bot)
    and copy the API token.
1.  Create a [Hubot Rocket.Chat app](https://rocket.chat/docs/developer-guides/creating-a-bot-user/)
    and copy the API token.
1.  Create a [Hubot Mattermost app](https://docs.mattermost.com/developer/bot-accounts.html)
    and copy the API token.
1.  Create a [Hubot Microsoft Teams app](https://docs.microsoft.com/en-us/microsoftteams/platform/concepts/bots/bots-create)
    and copy the API token.
1.  Create a [Hubot Hangouts Chat app](https://developers.google.com/hangouts/chat/how-tos/bots-develop)
    and copy the API token.
1.  Create a [Hubot Cisco Spark app](https://developer.ciscospark.com/add-app.html)
    and copy the API token.

1.  Create a deployment:

        kubectl create -f hubot.yaml
        apiVersion: extensions/v1beta1
        kind: Deployment
        metadata:
          name: hubot
        spec:
            replicas: 1
            template:
                metadata:
                labels:
                    app: hubot
                spec:
                containers:
                - name: hubot
                    image: gcr.io/${PROJECT_ID}/hubot:latest
                    env:
                    - name: HUBOT_SLACK_TOKEN
                    value: ${SLACK_API_TOKEN}
                    




1.  Create a service:
    
            kubectl create -f hubot-service.yaml
            apiVersion: v1
            kind: Service
            metadata:
              name: hubot
            spec:
                type: LoadBalancer
                ports:
                - port: 80
                selector:
                    app: hubot

1.  Create an ingress:
        
                kubectl create -f hubot-ingress.yaml
                apiVersion: extensions/v1beta1
                kind: Ingress
                metadata:
                  name: hubot
                spec:
                    rules:
                    - http:
                        paths:
                        - path: /*
                        backend:
                            serviceName: hubot
                            servicePort: 80

1.  Get the external IP address:
        
                kubectl get ingress hubot

1.  Go to the external IP address and verify that Hubot is running.

## Cleanup

1.  Delete the cluster:
    
            gcloud container clusters delete hubot



