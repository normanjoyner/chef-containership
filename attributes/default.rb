default['containership'] = {
  'agent' => {
    'cidr' => [],
    'cluster-id' => '',
    'legiond-interface' => 'eth1',
    'legiond-scope' => 'private',
    'log-level' => 'debug',
    'mode' => 'leader'
  },

  'btrfs' => {
    'enabled' => true
  },

  'node' => {
    'version' => '0.10.38'
  },

  'plugins' => {
    'default' => [
      {
        'name' => 'cloud',
        'options' => {}
      },
      {
        'name' => 'cloud-hints',
        'options' => {}
      },
      {
        'name' => 'service-discovery',
        'options' => {}
      }
    ],
    'leader' => [
      {
        'name' => 'logs',
        'options' => {}
      }
    ],
    'follower' => []
  },

  'requisite_images' => [
    {
      'name' => 'containership/haproxy',
      'tag' => '0.0.1'
    },
    {
      'name' => 'containership/containership.cloud.loadbalancer',
      'tag' => '0.0.6'
    }
  ],

  'version' => '1.3.0-rc.21'
}

default['nodejs']['version'] = default['containership']['node']['version']
