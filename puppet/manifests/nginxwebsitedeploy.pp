#All Our Scripts will start with checking the Linux Distro Type
$systemtype = $::operatingsystem ? {
  'Ubuntu' => 'debianbased',
  'Debian' => 'debianbased',
  'RedHat' => 'redhatbased',
  'Fedora' => 'redhatbased',
  'CentOS' => 'redhatbased',
  default  => 'unknown',
}

notify { "You have a ${systemtype} system": }

#Based on the output above we can install a specific package
  if $systemtype == 'redhatbased' {

  notify { "Enable Web Traffic Through HTTP and HTTPS": }
   exec { 'firewall changes http and https':
    path      => '/bin:/usr/bin',
    command   => 'systemctl start firewalld;systemctl enable firewalld;firewall-cmd --permanent --add-service=http; firewall-cmd --permanent --add-service=https; sudo firewall-cmd --reload',
   tag        => 'firewallenable',
    }
 
 $sourcefile = '/home/piuser1/confsetups/nginxtesting/webconfigs/nginx.conf'
 $targetfile = '/home/piuser1/deploy_nginx/nginx-1.23.2/conf/nginx.conf'

 notify { "Add The New Nginx Config File": }
  file { $targetfile :
    ensure => 'present',
    source =>  "file://${sourcefile}",
    owner  => 'piuser1',
    group  => 'piuser1',
    mode   => '0744',
    tag    => 'nginxconfmodify'
   }

  notify { "Creating Config Folder": }
  file { '/etc/nginx/conf.d':
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    tag    => 'nginxconffolder'
  }

  notify { "Creating Sites Enabled Folder": }
  file { '/etc/nginx/sites-enabled':
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    tag    => 'nginxsitesenfolder'
  }

  notify { "Creating Sites Available Folder": }
  file { '/etc/nginx/sites-available':
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    tag    => 'nginxsitesavfolder'
  }

  notify { "Creating webfolder www": }
  file { '/var/www/':
    ensure => 'directory',
    owner  => 'piuser1',
    group  => 'piuser1',
    mode   => '0755',
    tag    => 'wwwfolder'
  }

 $sourcedemowebfolder = '/home/piuser1/confsetups/nginxtesting/htmls/demo'
 $targetdemowebfolder = '/var/www/demo'

 notify { "Creating Site 1 Demo Site": }
  file { $targetdemowebfolder :
    ensure => 'directory',
    source =>  "file://${sourcedemowebfolder}",
    recurse => 'true',
    owner  => 'piuser1',
    group  => 'piuser1',
    mode   => '0644',
    tag    => 'demosite'
   }

  notify { "Creating Nginx Site 1 Demo Folder": }
  file { '/etc/nginx/sites-available/demo/':
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    tag    => 'demonginxfolder'
  }

  notify { "Ensure Site 1 is Accessible": }
   exec { 'Site 1 Access Setup':
    path      => '/bin:/usr/bin',
    command   => 'chcon -vR system_u:object_r:httpd_sys_content_t:s0 /var/www/demo/',
   tag        => 'siteoneaccess',
    }

 $sourcedemoconfile = '/home/piuser1/confsetups/nginxtesting/webconfigs/demo.conf'
 $targetdemoconfile = '/etc/nginx/sites-available/demo/demo.conf'

 notify { "Add Website 1 Configuration File": }
  file { $targetdemoconfile :
    ensure => 'present',
    source =>  "file://${sourcedemoconfile}",
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    tag    => 'demositeconf'
   }

  notify { "Create Soft Link to Sites Enabled Demo site": }
   exec { 'soft link change':
    path      => '/bin:/usr/bin',
    command   => 'ln -s /etc/nginx/sites-available/demo/demo.conf /etc/nginx/sites-enabled/demo.conf',
   tag        => 'softlinktodemosite',
    }

 $nginxservicesourcefile = '/home/piuser1/confsetups/nginxtesting/service/nginx.service'
 $nginxservicetargetfile = '/lib/systemd/system/nginx.service'

 notify { "Add The Nginx Service File": }
  file { $nginxservicetargetfile :
    ensure => 'present',
    source =>  "file://${nginxservicesourcefile}",
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    tag    => 'nginxservicefile'
   }

  notify { "Enable Nginx Systemd Service": }
   exec { 'Nginx Systemd Service Start and Restart':
    path      => '/bin:/usr/bin',
    command   => 'systemctl start nginx;systemctl enable nginx; systemctl reload nginx',
   tag        => 'nginxserviceenable',
    }

    file_line { 'Add hostfile the demosite':
        ensure => present,
        line => '192.168.60.18 www.demo-site.com',
        path => '/etc/hosts'
    }

}

# In our else statement we assume debian based is the distro and so 
# need less steps and in this example don't mind what version of htop is installed.
    else {
    exec { 'get system info':
    path        => '/bin:/usr/bin',
    command     => 'cat /etc/os-release > sysinfo.txt',
    tag    => 'debinfo',
    }
  }

