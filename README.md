# milkyway_shinyproxy_internal_docker
Milkyway Shinyproxy Docker Internal Image

This is the docker image that should be called from ShinyProxy.  Our design is such that this will be run as a docker-in-docker format.
The 'outer' docker will be provide the ShinyProxy frontend with all associated configurations.
