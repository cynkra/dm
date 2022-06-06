FROM gitpod/workspace-full:2022-06-05-16-11-02

RUN sudo apt-get update -qq && sudo apt-get install r-base

RUN curl https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash
