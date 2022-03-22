#=============================================================================#
# File Name:      Makefile
# Author:         Edward J. Sabol
# Creation Date:  2020/04/23
# Project:        HEASARC :: SciServer
#=============================================================================#
# File Description:
#   Used for building Hera Docker image.
#=============================================================================#
# High Energy Astrophysics Science Archive Research Center (HEASARC),
# NASA's Goddard Space Flight Center, Greenbelt, MD 20771, USA.
#
# You are free to use this code as you wish, but unless you change
# it significantly, please leave the above name and address intact.
#=============================================================================#

IMAGE_NAME = sciserver_ciao
IMAGE_VERSION = 6.30.4.14
IMAGE_LABEL = v$(IMAGE_VERSION)

image:
	@echo "Building Docker image ${IMAGE_NAME}:${IMAGE_LABEL}..."
	docker build --network=host -t $(IMAGE_NAME):$(IMAGE_LABEL) .
	-(docker images -q -f dangling=true | xargs --no-run-if-empty docker rmi)

latest: image
	@echo "Tagging Docker image ${IMAGE_NAME}:${IMAGE_LABEL} with latest..."
	docker tag $(IMAGE_NAME):$(IMAGE_LABEL) $(IMAGE_NAME):latest
	-(docker images -q -f dangling=true | xargs --no-run-if-empty docker rmi)
