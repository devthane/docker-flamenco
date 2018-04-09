# Docker-Flamenco

## Introduction:

This Repository is designed to make running your own flamenco-server stack locally much easier.

I welcome pull requests and discussions on how to make this better.

## WARNING:

Use at your own risk!

This is not a very secure container right now. I haven't made any effort to secure it at this time, but will do my best when I have time.

However, if you are locked down locally with a firewall and your system itself is secure I expect you'll be fine.

## How To Use:

Prerequisite: You will need git, docker and docker-compose installed in order to use this repository.
* If you don't know anything about docker, I highly recommend you study up on that first.

1. Clone this repository:
    * `git clone https://github.com/devthane/docker-flamenco.git` 

        or `git clone git@github.com:devthane/docker-flamenco.git`
2. Within the created directory, copy the `docker-compose.yml.example` to `docker-compose.yml`

3. Edit the docker-compose.yml file you just created.
    ```
    version: "2"
    services:
      flamenco:
        image: devthane/flamenco:0.1.0 # don't change this.
        environment:
          PILLAR_ADMIN_EMAIL:           # put an email address here, but it can not be the same as the subsriber's. Make one up. It shouldn't matter.
          SUBSCRIBER_EMAIL:             # put your actual email address here.
          SUBSCRIBER_PASSWORD:          #
          SERVER_SCHEME: http           # only change this to https if you are handling the ssl termination. I have not tested https scheme yet. I will get around to it.
          SERVER_DOMAIN: flamenco.app   # set this to whatever domain you want to use to access the flamenco server. FYI THIS IS VERY PICKY.
          SERVER_PORT: 80               # Leave as port 80 for now (Sorry I'll fix this to allow any port shortly.)
          PROJECT_NAME: test-project-1  # Put the name of your project here.
          MANAGER_NAME: test-manager-1  # Give your manager a name here.
          MANAGER_DESCRIPTION: this is a test manager # give your manager a description here.
        links:
          - mongo:mongo
          - rabbit:rabbit
          - redis:redis
        ports:
          - 0.0.0.0:80:80
        volumes:
          - /tmp/flamenco-server:/tmp/output # the value before the ':' needs to be a writable directory on the computer running the server.
      mongo:
        image: mongo
        volumes:
          - /tmp/db:/data/db # must also be writable. Also, if you are wanting to start from scratch after having run this before, you will need to wipe this directory.
      rabbit:
        image: rabbitmq
      redis:
        image: redis
    ```

4. run `docker-compose up -d`

5. Edit your hosts file to use the domain name you provided in the yml file (if you don't have a dns entry set up.)

6. After a brief delay, You should be able to go to <SERVER_SCHEME>://<SERVER_DOMAIN> and see the pillar welcome page.
    * You can view progress of the image setting up by using `docker logs -f` on the flamenco container.

7. To go to your project, go to <SERVER_SCHEME>://<SERVER_DOMAIN>/p/

Now if you have any questions beyond this, create an issue and we'll figure it out together.