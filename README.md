#Rails Ready for Debian Squeeze
##Overview and invocation

A thinner variation of the railsready script adjusted to Debian Squeeze. The script aims to provide as much automation in VPS deployments for Ruby on Rails applications as possible.
You can pass two arguments to the script, which correspondingly denote the version and patch of the desired Ruby environment.
If you want to use the newest version available you can always check http://www.ruby-lang.org for information. At the time of writing the current version was 1.9.2-p194 and you can see below how to invoke the script for it:

**./railsready-debian-squeeze.sh RUBY_VERSION RUBY_PATCH**, for example:

**./railsready-debian-squeeze.sh 1.9.3 194**

Below is an expanded command which will get you going:

wget --no-check-certificate https://raw.github.com/tomasz-stempinski/railsready-debian-squeeze/master/railsready-debian-squeeze.sh && chmod a+x railsready-debian-squeeze.sh && ./railsready-debian-squeeze.sh **1.9.3 194**

##Phusion Passenger setup

**./phusion-passenger-setup.sh 1.9.3 194**

Below is an expanded command which will get you going:

wget --no-check-certificate https://raw.github.com/tomasz-stempinski/railsready-debian-squeeze/master/phusion-passenger-setup.sh && chmod a+x phusion-passenger-setup.sh && ./phusion-passenger-setup.sh **ruby-1.9.3-p194**

##Additional packages
The script has been updated to install memcache, MongoDB and Sphinx.

##Acknowledgement
Big thanks to Jakub Godawa (vysogot) for providing his version of the configuration script!

