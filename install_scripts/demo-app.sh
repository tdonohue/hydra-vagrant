#!/bin/bash

# Get passed in args (these specify the apps to install below)
ARGS="$@"

DEMO_TASK="
task :demo do
  with_server :development do
    IO.popen('rails server -b 0.0.0.0') do |io|
      begin
        io.each do |line|
          puts line
        end
      rescue Interrupt
        puts 'Stopping server'
      end
    end
  end
end"

# Install CurationConcerns if CC in list of apps (or ALL specified)
if [[ $ARGS == *"CC"* ]] || [[ $ARGS == *"CurationConcerns"* ]] || [[ $ARGS == "ALL" ]]; then
  echo "Creating CurationConcerns demo in ${HOME}/curation-concerns-demo"
  cd
  rails new curation-concerns-demo --skip-spring
  cd curation-concerns-demo
  echo "gem 'curation_concerns', '1.5.0'" >> Gemfile
  bundle install --quiet
  rails generate curation_concerns:install -f -q
  rails generate curation_concerns:work Book -q
  rake db:migrate
  echo "$DEMO_TASK" >> Rakefile
fi

# Install Sufia if specified in list of apps (or ALL specified)
if [[ $ARGS == *"Sufia"* ]] || [[ $ARGS == "ALL" ]]; then
  echo "Creating Sufia demo in ${HOME}/sufia-demo"
  cd
  rails new sufia-demo --skip-spring
  cd sufia-demo
  echo "gem 'sufia', github: 'projecthydra/sufia', branch: :master" >> Gemfile
  echo "gem 'flipflop', github: 'jcoyne/flipflop', branch: :hydra" >> Gemfile
  bundle install --quiet
  rails generate sufia:install -f -q
  rails generate sufia:work Work -q
  rake db:migrate
  echo "$DEMO_TASK" >> Rakefile
fi

# Install Hyrax if specified in list of apps (or ALL specified)
if [[ $ARGS == *"Hyrax"* ]] || [[ $ARGS == "ALL" ]]; then
  echo "Creating Hyrax in ${HOME}/hyrax"
  cd
  git clone https://github.com/projecthydra-labs/hyrax.git hyrax
  cd hyrax
  bundle install --quiet
  # Generate internal test app (.internal_test_app subdirectory)
  rake engine_cart:generate
  # Needed to make Admin Users: https://github.com/projecthydra/sufia/wiki/Making-Admin-Users-in-Sufia
  cd .internal_test_app
  echo "gem 'hydra-role-management'" >> Gemfile
  bundle install --quiet
  rails generate roles
  rake db:migrate
  RAILS_ENV=test rake db:migrate
fi

# Install Hyku if specified in list of apps (or ALL specified)
if [[ $ARGS == *"Hyku"* ]] || [[ $ARGS == *"Hybox"* ]] || [[ $ARGS == "ALL" ]]; then
  echo "Creating Hyku (Hydra-in-a-box) demo in ${HOME}/hyku"
  cd
  git clone https://github.com/projecthydra-labs/hyku.git hyku
  cd hyku
  bundle install --quiet
  rake db:create
  rake db:migrate
fi
