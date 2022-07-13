# Configuration

> **Note**:
> By _default_ this is done in `.env` file (with shell-like syntax).
> But any environment variable settings via shell or `make` call take
> _precedence_ of `.env` configuration.
> So for example, you can `source .env` and then customize the
> default values interactively.
> Alternatively, you can import a customized file, e.g. `source .env.local`.)
>
> **Note**:
> When using the Makefile, some of the static settings in `.env` will always
> be overridden dynamically: To optimally match ownership and permissions of
> existing files with new data to be written, the UID and GID of the `ocrd` user
> on the Controller and Manager are taken from the host system.
>
> **Note**:
> If you do not want to [`make build`](#building) the images yourself, but
> use the _prebuilt_ images from Dockerhub, then mind the image _tag_ variables.
> Instead of the default `latest` development version, you may want to use
> a stable release: Just checkout the respective Git release, and `.env`
> should already point to stable tags.