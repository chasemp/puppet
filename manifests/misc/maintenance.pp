# misc/maintenance.pp

# mw maintenance/batch hosts

class misc::maintenance::foundationwiki {

	system_role { "misc::maintenance::foundationwiki": description => "Misc - Maintenance Server: foundationwiki" }

	cron { 'updatedays':
		user => apache,
		minute => '*/15',
		command => '/usr/local/bin/mwscript extensions/ContributionReporting/PopulateFundraisingStatistics.php foundationwiki --op updatedays > /tmp/PopulateFundraisingStatistics-updatedays.log',
		ensure => present,
	}

	cron { 'populatefundraisers':
		user => apache,
		minute => 5,
		command => '/usr/local/bin/mwscript extensions/ContributionReporting/PopulateFundraisingStatistics.php foundationwiki --op populatefundraisers > /tmp/PopulateFundraisingStatistics-populatefundraisers.log',
		ensure => present,
	}
}

class misc::maintenance::refreshlinks {

	require mediawiki_new

	# Include this to add cron jobs calling refreshLinks.php on all clusters. (RT-2355)

	file { '/home/mwdeploy/refreshLinks':
		ensure => directory,
		owner => mwdeploy,
		group => mwdeploy,
		mode => 0664,
	}

	define cronjob() {

		$cluster = regsubst($name, '@.*', '\1')
		$monthday = regsubst($name, '.*@', '\1')

		cron { "cron-refreshlinks-${name}":
			command => "/usr/local/bin/mwscriptwikiset refreshLinks.php ${cluster}.dblist --dfn-only > /home/mwdeploy/refreshLinks/${name}.log 2>&1",
			user => mwdeploy,
			hour => 0,
			minute => 0,
			monthday => $monthday,
			ensure => present,
		}
	}

	# add cron jobs - usage: <cluster>@<day of month> (these are just needed monthly) (note: s1 is temp. deactivated)
	cronjob { ['s2@2', 's3@3', 's4@4', 's5@5', 's6@6', 's7@7']: }
}

class misc::maintenance::pagetriage {

	system_role { "misc::maintenance::pagetriage": description => "Misc - Maintenance Server: pagetriage extension" }

	cron { 'pagetriage_cleanup_en':
		user => apache,
		minute => 55,
 		hour => 20,
		monthday => '*/2',
		command => '/usr/local/bin/mwscript extensions/PageTriage/cron/updatePageTriageQueue.php enwiki > /tmp/updatePageTriageQueue.en.log',
		ensure => present,
	}

	cron { 'pagetriage_cleanup_testwiki':
		user => apache,
		minute => 55,
		hour => 14,
		monthday => '*/2',
		command => '/usr/local/bin/mwscript extensions/PageTriage/cron/updatePageTriageQueue.php testwiki > /tmp/updatePageTriageQueue.test.log',
		ensure => present,
	}
}

class misc::maintenance::translationnotifications {
	require misc::deployment::scripts

	# Should there be crontab entry for each wiki,
	# or just one which runs the scripts which iterates over
	# selected set of wikis?
	cron {
		translationnotifications-metawiki:
			command => "/usr/local/bin/mwscript extensions/TranslationNotifications/scripts/DigestEmailer.php --wiki metawiki 2>&1 >> /var/log/translationnotifications/digests.log",
			user => l10nupdate,  # which user?
			weekday => 1, # Monday
			hour => 10,
			minute => 0,
			ensure => present;

		translationnotifications-mediawikiwiki:
			command => "/usr/local/bin/mwscript extensions/TranslationNotifications/scripts/DigestEmailer.php --wiki mediawikiwiki 2>&1 >> /var/log/translationnotifications/digests.log",
			user => l10nupdate, # which user?
			weekday => 1, # Monday
			hour => 10,
			minute => 5,
			ensure => present;
	}

	file {
		"/var/log/translationnotifications":
			owner => l10nupdate, # user ?
			group => wikidev,
			mode => 0664,
			ensure => directory;
		"/etc/logrotate.d/l10nupdate":
			source => "puppet:///files/logrotate/translationnotifications",
			mode => 0444;
	}
}

class misc::maintenance::wikidata {
	cron {
		wikibase-repo-prune:
			command => "/usr/local/bin/mwscript extensions/Wikibase/repo/maintenance/pruneChanges.php --wiki wikidatawiki 2>&1 >> /var/log/wikidata/prune.log",
			user => wikidev,
			minute => "0,15,30,45",
			ensure => present;
	}

	file {
		"/var/log/wikidata":
			owner => wikidev,
			group => wikidev,
			mode => 0664,
			ensure => directory;
		"/etc/logrotate.d/wikidata":
			source => "puppet:///files/logrotate/wikidata",
			mode => 0444;
	}
}
