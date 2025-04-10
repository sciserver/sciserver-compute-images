# About

This repo contains definitions for sciserver compute docker image builds. Each image consumed within SciServer has two components:

* Science layer: this is the layer that contains specific packages and software useful for the computation necessary to
  achieve a scientific analysis goal.

* Compatibility layer: this contains the entrypoint commands and data necessary use within sciserver and interface to
  the user (e.g. Jupyter)

In general, there should be fewer compatibility layers than science layers. For example, many images for use in
different science domains will have the same Jupyter interface.

This structure allows us to make rapid updates to the interfacing in SciServer to keep up with security updates and new
features, while continuing to provide a stable science environment to the user. For example, a security update of the
Jupyter environment can be made on top of the current latest science image without modifying it in any way.

# How it works

## Creating images

Each science image is defined in the typical way, and the Dockerfiles for them need not contain any special instructions
or any SciServer related items. While these images can be derivitive from eachother, there is no such requirement. Each
change to contents of a science build dirctory (those directories located under `science/`) will, in principal, result
in a build science image which is uniquely tagged. The top-level such science image of a particular image-version (see
more below) will further result in a compatibility (compat) build using the compatibility layer defined in its image definition
(`sciserver-image.json` file).

The compat build generates a Dockerfile originated from the appropriate science image, and concatenates all dependent
compat layers (those listed as "includes" in its `sciserver-image.json` file) to result in the final Dockerfile and
build context directory. Any files existing more than one compat layer will be overwritten by the top-most layer (as is
the case for a standard docker build - we don't use the docker build mechanism here as there is only one sensible image
that can result from a compat layer build).

All of the build products are uploaded (if specified) to a remote repository for consumption and will be tagged both
with the version (akin to latest) and version plus build info (never changes):

* science layer under `{repo}/sci/{target}` 
* compat layer under `{repo}/rel/{image}`

Future updates can reference one of the science layer products to make an updated without resulting in a new build (and
potentially new versions of downloaded packages). Any time a compat layer is changed, new images will be created from
the top-level science images for each image-version.

## Consuming in SciServer compute

Compute should always refer to a plain version-tagged compat image. Many such versions can exist for a single image, but
they should always point to the latest compat image for that image-version. For example, if a build resulting in a final
compat image for sciserver-essentials 2.4 in commit dk8912nds, there will be
`{repo}/rel/sciserver-essentials:2.4-32-dk8912nds` (or similar) and `{repo}/rel/sciserver-essentials:2.4`, which have
the same contents. In principal, compute should point to `{repo}/rel/sciserver-essentials:2.4` and always pull the
image, so that compat updates can be deployed even when there are no underlying science changes.

# Setting up images

Each science and compat directory should have a `sciserver-image.json` file describing details about the image and how
to create it. For **science** it looks like:

```json
{
  # image is name given to the final build image in a series. This need not be
  # unique, another science layer with the same image can either represent an
  # in-place update of an image or a version upgrade. This name will be used in
  # the final image as "{repo}/rel/{name}:{version}", and generally will be
  # referred to by a similar name in compute.
  "image": "sciserver-essentials",

  # each image also has a version, any other science layers that have the same
  # "image" and "version" must result in a single final image (e.g. that with no
  # consumers)
  "version": "2.4",

  # The target refers to the build artifact name given to this particular
  # science layer of image. Since multiple files can refer to the same image and
  # version, this uniquely identifies this layer among all. It defaults to the
  # current directory name. This name forms a tag
  # (`{repo}/sci/{target}:{version}`) that can be used in the FROM line in other
  # layers to build up layers
  "target": "essentails-2021-10-12",

  # each science layer must specify the compat layer it uses, which must exist
  # under compat/
  "compat": "jupyter"
}
```

And for **compat**

```json
{
  # include any other compat layers, in order. Docker file will be concatenated
  # in this order and any files of same name in successive layers will be
  # overwritten.
  "includes": ["otherlayer", "otherlayer2"]
}
```

## Versioning

One of the reasons for this method of building images is to tightly preserve the software in image versions. In some
cases simply triggering a rebuild will result in some updated packages and a changed environment. To ensure that does
not happen we can add software or features to a image by building on top of the previous one. There are three general
approaches:

* Add without changing version: Create a new science layer depending on the previous most recent version (using FROM
  `sci/{target}:{version}`) and give it the same "image" and "version", this will now become the new final image and
  only it will result in a compat image

* Add and change version: Create a new science layer depending on the previous most recent version and update the
  version at the same time (e.g. from "2.4" -> "2.5"). This will create a new compat image, but the previous version
  will still ("2.4") get compat updates

* Change in place: We can change an image in place, which will result in a new build of the given layer and a new
  compat. This makes most sense for the final image in a series with no version change. If we change in place and update
  the version, this will result in an orphaned image, which will no longer recieve compat updates (must ensure that
  version is deprecated and no longer used). Eventually there should be some protection against this.

## Dockerfiles and dependencies

For science layers that should depend on one-another, ensure the FROM line refers to the dependent science layer by its
`sci/{target}:{version}` tag (without the build number and commit tag) and not by a compat build. This will ensure
dependencies are properly detected by the build tool and can be built upon changes, and that layers then do not contain
unnecessary overwritten compat data that simply takes space without adding function.

## Tracking changes

During each build, the build tool will add a label to the layer being build, which form a breadcrumb trail which can be
used to identify the full makeup of the image and compared to changes in this repository. For example, for this image
which is based on sci target `nist-basic`, we can see two science layers and the compat layer and version:

```json
  "org.sciserver.compat.buildtime": "1639077082.170079",
  "org.sciserver.compat.version": "nist-basic:2.0-42-f90dbd6",
  "org.sciserver.science.nist-basic-2.buildtime": "1639077081.9336998",
  "org.sciserver.science.nist-basic-2.version": "2.0-42-f90dbd6",
  "org.sciserver.science.nist-basic.buildtime": "1639071168.7262735",
  "org.sciserver.science.nist-basic.version": "1.0-42-f90dbd6"
```

# Using the build tool

All images should be built using the build tool `image-builder`, and generally this should be done in an automated build
(e.g. in Jenkins) and not by a human. However, for each change, please do use the tool to check what the build plan is
and ensure it makes sense:

```
./image-builder -v --dryrun
```

Which might print something like:

```
WARNING:root:change results in final image nist-basic => nist-basic:1.0-42-f90dbd6, nist-basic:1.0
WARNING:root:change results in final image nist-basic => nist-basic:2.0-42-f90dbd6, nist-basic:2.0
WARNING:root:final plan includes 2 science builds and 2 compat builds
```

Showing the final image builds (compat layers, those in /rel). Add another `-v` to the above command to get details on
any intermediate builds.

To build images, you can remove the `--dryrun` flag. This will build locally but refrain from pushing. To push images
you must supply the `--push` flag, but please take care in doing so. To test this functionality without pushing to the
production repository, you can supply an alternate location in `--repo`, such as
`containers.repo.sciserver.org/{myname}/compute-images-test` or so (the default location is
`containers.repo.sciserver.org/compute-images`)

