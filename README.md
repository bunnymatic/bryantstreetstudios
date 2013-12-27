# Bryant Street Studios on Sinatra

## Setup

You'll need to install git, rvm at an absolute minimum.  

### Mac

Assuming a Mac, you should first install [homebrew](http://mxcl.github.com/homebrew/).  Then you can 

    % brew install git
    
Then you'll need rvm (Ruby Version Manager) which will take care of installing ruby for you.  Installation instructions are [here](https://rvm.io/rvm/install/).  

You'll probably need a bunch of other crap that I can't think of right now.  Most everything that you should need is available via brew.  Looking at my current install, here are several packages you might install for good measure:

    qt libxml2 openssl libxslt sqlite coreutils markdown libffi postgresql

You can install each one by running
    
    % brew install <packagename>

or stick them all together
    
   % brew install qt libxml2 openssl libxslt sqlite coreutils markdown libffi postgresql
    
Once you have rvm installed and you've followed the installation instructions (modifying your profile, perhaps), figure out where you want the code to live, and go *git* it.  Let's assume a directory like /projects/1890sinatra.  You would do the following

    % mkdir /projects/
    % cd /projects
    % git clone git@ci.2rye.com:/space/git/1890sinatra.git

NOTE: for this to work, you'll need to make sure you've been authorized on the git server.

This will fetch all the latest code.  You should now have a pile of stuff under /projects/1890sinatra.

To run the app, simply jump into that directory.  You may get an RVM message.  If so, follow instructions.  Once you're back to a prompt, (another one time) you'll install bundler, and then the gems, and then start the app with rackup.  Like so:

    % cd /projects/1890sinatra
    % gem install bundler
    % bundle install
    % bundle exec rackup

This should start a server and show you a webpage if you open http://localhost:9292 in your browser.

### PostgreSQL

Setting up your database.  You could read about setting up sqlite3 which is pretty easy, but having a development environment that is as close to production is a good thing, because you're more likely to see issues sooner.  We use the database to store the event list.  Later it may get used to store more stuff.  Since we can't use sqlite on Heroku, we'll go with PostgreSQL which is their default.

First, install postgres (see brew instructions above).

Once you've got the database running, we need to add a database for our app.  If you look in the app code you'll find that we have a db connection string defined in our config file (/config/config.yml) which is written in YAML ([read more about YAML here](http://en.wikipedia.org/wiki/YAML).  We need a database called 'bryant_dev' and one called 'bryant_test''.

    % createdb bryant_dev
    % createdb bryant_test
    % psql bryant_dev

And you should get back something like this:

    psql (9.1.3)
    Type "help" for help.
    bryant_dev=# 

And now you have 2 new PostgreSQL databases in place and you've connected to them.

## Deployment

We deploy on heroku.  Once you've got your codebase setup and all the gems installed, you'll need to add the heroku remote to your git repo.  This only needs to be done once, as follows:

    % git remote add heroku git@heroku.com:bryantstreetstudios.git

To make sure it's done, you can check your list of remotes with

    % git remote -v

Once the remote is there (and you've added your SSH keys to the heroku - [Follow these instructions to add your credentials to heroku](https://devcenter.heroku.com/articles/keys)

    % git push heroku

We will most likely set this up on a Continuous Integration machine (CI) which means that you may not have to think about this step because we'll periodically check the code stream and if there have been updates, we'll automagically pull those, build the new code, run the tests and push to heroku if all the tests pass.  More on that when it's in place.

### Amazon S3

We're using Amazon S3 for storage of local assets (pictures).  This needs to be setup with some config variables.  The file s3.config.sh should be run before you run the app.  This will make the shell ready for amazon, but don't check that file into the repository because we'd like to keep those keys private.  To set things up, before you run the app, run (in the shell)

    % s3.config.sh

## Testing info

### Running tests

To run the spec tests, 

    % bundle exec rake spec

To run the javascript tests (NOTE: these are not yet setup as of 8/4/2012 so you can skip this step)
   
    % bundle exec jasmine-headless-webkit

### Writing tests

Tests live under the /spec directory.  This stands for "specification".  We're using RSpec for the test framework in combo with WebRat::Matchers(for html selector testing).  You can look for these on google or check the cheats:

* [cheat rspec](http://cheat.errtheblog.com/s/rspec/)
* [cheat webrat](http://cheat.errtheblog.com/s/webrat/)


 
