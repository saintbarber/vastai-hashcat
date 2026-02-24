# vastai-hashcat

Dockerfile hosting hashcat, compatible with vast.ai instances

Hashcat and cuda setup has been copied from https://github.com/dizcza/docker-hashcat/blob/cuda/Dockerfile

This repository mainly creates a wordlist and rules folder within the vast.ai instance to be able to use with hashcat.

# Updating/Cloning Repo w/ submodule

Clone repo
```
git clone --recurse-submodules <your-repo>
```

Update submodule
```
git submodule update --remote
```

# Setup SSH keys

Edit the Hashcat Template within vast.ai and add your public key to the Environment variables section.

The value name is **PUBLIC_KEY** (see entrypoint.sh)

# Add custom Wordlist


To add your own wordlists to the container you need to create your own dockerhub repo and create your own vast.ai template to pull said repo.

First clone the above repo and mv/cp your wordlist(s) to the wordlists folder.

Make sure the wordlists have been zipped with 7z.

```
7z a wordlist.7z wordlist.txt
```

Next build the image:

```
docker build --tag <dockerhub-username>/<repo-name>:<tag> .
```

Next push the image to docker hub:
```
docker push <dockerhub-username>/<repo-name>:<tag>
```


Now create a custom Template on vast.ai to use your docker hub repo, navigate to Templates and click "+ New Template"

Add the following:
    Template Name
    Container image - The one you created with the previous command
    Expose TCP Ports - 22



# Wordlists Tests

https://docs.google.com/spreadsheets/u/0/d/1qQNwggWIWtL-m0EYrRg_vdwHOrZCY-SnWcYTwQN0fMk/htmlview?pli=1#
