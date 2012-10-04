ruby_version=$1
script_runner=$(whoami)

# Reload bash
echo -e "\n=> Reloading bashrc so Ruby and Rubygems are available..."
source ~/.rvm/scripts/rvm
source ~/.bashrc
echo "==> done..."

# Install bundler and rails
echo -e "\n=> Installing Passenger..."
gem install passenger
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
