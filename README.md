# This is a work in progress. Documentation to come soon.

I'll briefly say that all you have to do is clone this repo, edit the docker-compose.yml file as needed for whatever variables and then run docker-compose up -d

Doing so will start up the flamenco server, export port 80 on the host into the container.

FYI flamenco is very picky about the host domain you are accessing it by so make sure your hosts file matches, or you have DNS set up for that url or something.

docker-compose up will start a redis, mongodb, and rabbitmq container as well and link it to the flamenco container.

as far as the flamenco container itself goes it will:
- Set up the database as needed
- create a subscriber user per the variables in the docker-compose.yml
- create a project for that user giving it the name listed in the docker-compose.yml
- enable flamenco on the project
- create a manager for the user and output all manager details into the output volume listed in the docker-compose.yml
- so then you should be able to get the manager's info you need from that manager-info.txt and link your manager to the flamenco server manually.
  - the linking must be done manually right now. I haven't gotten the web interface to work yet for linking.
  - I'll provide more details on how to do this exactly, but it shouldn't be too difficult to figure out... it needs the manager id and access token I think in the manager's configuration. That's just off the top of my head.
