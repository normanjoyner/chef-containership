name             'containership'
maintainer       'ContainerShip Developers'
maintainer_email 'developers@containership.io'
license          'All rights reserved'
description      'Chef cookbook to set up and configure ContainerShip'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version			'0.1.0'

depends 'apt', '~> 2.0'
depends 'docker', '~> 2.0'
depends 'nodejs', '~> 2.0'
