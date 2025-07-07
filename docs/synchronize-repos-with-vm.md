# Synchronize Git Repositories with a VM

This workflow describes how you can synchronize this repository and the contained submodules to a remote virtual machine.

This allows making changes remotely and getting them back to the working repository on the desktop computer.

## On your desktop computer: Copy the working repository to a remote server

Configure the exported environment variables in the script [/scripts/create-remote-repositories.sh](../scripts/create-remote-repositories.sh)

Copy the workspace to the remote:

```shell
./scripts/create-remote-repositories.sh
```

## On the remote computer: Make changes to the repository

Depending on which persona is driving the development, I set my git user name and email as follows:

```shell
export SELF="Stefan Boos" \
export MODEL="Claude 4-20250514 Sonnet" \
export EMAIL=kontakt@boos.systems

git config --global user.email "$EMAIL"

# If I am driving the development, e.g. using the model's code completion
# or having a conversation with the model to craft code
git config --global user.name "$SELF + $MODEL"

# If the Model is following an implementation plan
git config --global user.name "$MODEL (+ $SELF)"

# Reset: Usually I am coding alone
git config --global user.name "$SELF"
```

```shell
# Show configuration
git config --get user.name
git config --get user.email
```

The script used in the previous section has already cloned all repositories to the working directory. Open the cloned working directory in Visual Studio Code and make some changes.
