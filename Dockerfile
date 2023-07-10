FROM rust:1.70-bookworm AS base

RUN apt-get update && apt-get -y install --no-install-recommends protobuf-compiler && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*


FROM base AS development

ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Create the user
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    #
    # [Optional] Add sudo support. Omit if you don't need to install software after connecting.
    && apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# ********************************************************
# * Anything else you want to do like clean up goes here *
# ********************************************************

# [Optional] Set the default user. Omit if you want to keep the default as root.
USER $USERNAME

ENTRYPOINT ["bash"]


FROM base AS production

COPY . /workspace

WORKDIR /workspace

RUN cargo build --release

ENTRYPOINT ["cargo", "run", "--bin", "server"]
