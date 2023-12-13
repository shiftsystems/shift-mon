FROM quay.io/fedora/fedora:39
ADD requirements.yml requirements.yml
ADD ansible.cfg .ansible.cfg
RUN ["dnf","-y","install","openssh-clients","python3","python3-pip","figlet"]
RUN ["python3","-m","pip","install","ansible"]
RUN ["ansible-galaxy","install","-vvv","--ignore-certs","--force","--role-file","requirements.yml"]