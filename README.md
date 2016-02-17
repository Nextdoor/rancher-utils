# Rancher utilities

## Util to upgrade a Rancher service

Ruby script to do in-service upgrade of a Rancher service

    upgrade_rancher_service.rb

### Usage

#### Test on command line

	export CATTLE_ACCESS_KEY=ABCDEF
	export CATTLE_SECRET_KEY=ABCDEF
	export CATTLE_ENV_ENDPOINT=https://rancher.corp.nextdoor.com/v1/projects/abc
	export CATTLE_SERVICE_ID=abc123

	gem install rancher-api
	ruby upgrade_rancher_service.rb

Here's a [video screencast](http://cl.ly/3P3Y20241l16) of this script in action.

#### `circle.yml` example

	deployment:
	  hub:
	    branch: master
	    commands:
	      - gem install rancher-api
	      - curl 'https://raw.githubusercontent.com/Nextdoor/rancher-utils/master/upgrade_rancher_service.rb' | ruby

