class test_module {
  file { 'simple file':
    path   => '/tmp/testfile',
    ensure => 'present',
    source => 'puppet:///modules/test_module/testfile.txt',
  }

  notify { 'simple notification':
    name     => 'simple note',
    message  => 'Hello world!',
  }
}
