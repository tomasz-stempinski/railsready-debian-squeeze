#!/bin/bash
system_version="Debian Squeeze 6.0x"
#Invocation example: ./railsready-debian-squeeze.sh 1.9.3 194

ruby_version=$1		
ruby_version_patch=$1-p$2	
ruby_dir=ruby-$ruby_version_patch

script_runner=$(whoami)
log_file=$(cd && pwd)/rails_install.log

echo \#The user running this script: $script_runner
echo \#Logging all operations to: $log_file
echo \#Ruby version: $ruby_version_patch

control_c()
{
  echo -en "\n\nExiting the script."
  exit 1
}

# Trap keyboard interrupt (control-c)
trap control_c SIGINT

# First things first
if [ -f $log_file ]
  then
    echo -e "The log file exists, do you want to delete it?[y/n]"
    read remove_log_file
    if [ $remove_log_file = "y" ]
      then
        rm $log_file && cd && touch $log_file
    fi
  else
    cd && touch $log_file
    echo -e "Log file created: $log_file"
fi

echo "This script will update your system! Run on a fresh $system_version install only."
echo "Run tail -f $log_file in a new terminal to watch the installation."

# Help with sudo privileges
echo -e "If this is just installed then add a user "$script_runner" to the sudoers.\n"
echo "Do this by yourself:"
echo "su"
echo "apt-get install sudo"
echo -e "echo '$script_runner ALL=(ALL) ALL' >> /etc/sudoers\n"
echo "Is it ready and you want to continue? (y/n): "
read ready

# Ask user if he/she is ready for installation
if [ $ready = "y" ]
then
  # Check if the user has sudo privileges.
  sudo -v >/dev/null 2>&1 || { echo $script_runner has no sudo privileges ; exit 1; }
else
  echo "Error: Insufficient privileges."
  control_c
fi

echo "########################################"
echo "## Rails Ready -- "$system_version" ##"
echo "########################################"
echo "What this script gets you:"
echo " * An updated system"
echo " * Ruby $ruby_version_patch on RVM"
echo " * libs needed to run Rails (postgres, etc.)"
echo " * Bundler, Passenger, pg, and Rails gems"
echo " * Git"
echo " * Memcache"
echo " * MongoDB"
echo " * Sphinx"
echo " * QT development libraries "
echo "Make sure you got it from https://github.com/tomasz-stempinski/railsready-debian-squeeze"

# Update the system before going any further
echo -e "\n=> Updating system (this may take a while)..."
sudo apt-get update >> $log_file 2>&1
sudo apt-get -y -V upgrade >> $log_file 2>&1
echo "==> done..."

# Install build tools
echo -e "\n=> Installing build tools and dependencies..."
sudo apt-get -y -V install curl build-essential \
  libxml2-dev libxslt1-dev libncurses5-dev libreadline6-dev \
  libapr1-dev libaprutil1-dev libcurl4-openssl-dev \
  libssl-dev zlib1g-dev libyaml-dev libc6-dev \
  libsqlite3-0 libsqlite3-dev \
  libpgtcl-dev libpqxx3-dev \
  autoconf >> $log_file 2>&1
echo "==> done..."

#Install Apache Web Server
echo -e "\n=> Installing Apache..."
sudo apt-get -y -V install  apache2-mpm-prefork apache2-prefork-dev >> $log_file 2>&1
echo "==> done..."

#PostgreSQL - default packages
echo -e "\n=> Installing PostgreSQL and SQLite..."
sudo apt-get -y -V install postgresql-common postgresql postgresql-client-common \
postgresql-client postgresql-server-dev-all >> $log_file 2>&1
echo "==> done..."

# Install git-core
echo -e "\n=> Installing git-core..."
sudo apt-get -y install git-core >> $log_file 2>&1
echo "==> done..."

# Install memcache
echo -e "\n=> Installing memcache..."
sudo apt-get -y install memcache >> $log_file 2>&1
echo "==> done..."

# Install MongoDB
echo -e "\n=> Installing MongoDB..."
sudo apt-get -y install mongodb >> $log_file 2>&1
echo "==> done..."

# Install Sphinx
echo -e "\n=> Installing Sphinx..."
sudo apt-get -y install sphinx >> $log_file 2>&1
echo "==> done..."

# Install QT
echo -e "\n=> Installing QT..."
sudo apt-get install libqt4-dev
echo "==> done..."

# Install RVM
echo -e "\n=> Installing RVM the Ruby enVironment Manager http://rvm.beginrescueend.com/rvm/install/ \n"
bash < <( curl -s https://raw.github.com/wayneeseguin/rvm/master/binscripts/rvm-installer )
echo -e "\n=> Setting up RVM to load with new shells..."
echo  '[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"  # Load RVM into a shell session *as a function*' >> "$HOME/.bashrc"
echo "==>done..."

# Load RVM to the shell
echo -e "\n=> Loading RVM..."
source ~/.rvm/scripts/rvm
source ~/.bashrc
echo "==> done..."

# Install specific Ruby version and setting it as default
echo -e "\n=> Installing $ruby_version_patch..."
echo -e "=> More information about installing Rubies can be found at http://rvm.beginrescueend.com/rubies/installing/ \n"
rvm install $ruby_version_patch && rvm use $ruby_version_patch --default
echo -e "\n==> done..."

# Make directory for rails apps
echo -e "\n=> Making directory for Rails apps"
cd && mkdir ~/rails_apps
echo "==> done..."

# Reload bash
echo -e "\n=> Reloading bashrc so Ruby and Rubygems are available..."
source ~/.rvm/scripts/rvm
source ~/.bashrc
echo "==> done..."

# Install bundler and rails
echo -e "\n=> Installing Bundler, Passenger, pg and Rails..."
gem install mail bundler rails passenger pg >> $log_file 2>&1
echo "==> done..."

# Prepare sudo installation and show the env
echo -e "\n=> Preparing apache-passenger installation..."
rvmsudo bash -c export
rvmsudo "rvm_path=/home/$script_runner/.rvm;passenger-install-apache2-module"
echo "==> done..."

# Install apache-passenger
gem_dir=/home/$script_runner/.rvm/gems
ruby_dir_full=`find $gem_dir/$ruby_dir* -maxdepth 0 -type d | head -1`
passenger_dir=`find $ruby_dir_full/gems/passenger* -maxdepth 0 -type d | head -1`
echo "Gem dir: $gem_dir"
echo "Ruby full dir: $ruby_dir_full"
echo "Passenger dir: $passenger_dir"

rvmsudo $ruby_dir_full/bin/passenger-install-apache2-module
sudo touch /etc/apache2/mods-available/passenger.load
sudo su -c "echo 'LoadModule passenger_module $passenger_dir/ext/apache2/mod_passenger.so' >> /etc/apache2/mods-available/passenger.load"
sudo touch /etc/apache2/mods-available/passenger.conf
sudo su -c "echo 'PassengerRoot $passenger_dir' >> /etc/apache2/mods-available/passenger.conf"

echo -e "##############################"
echo -e "### Installation complete! ###"
echo -e "##############################"
