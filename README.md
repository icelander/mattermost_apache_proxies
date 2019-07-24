# Mattermost Recipe - Running Mattermost Behind a Double Apache Proxy Inside a Subdirectory
*AKA "Yo Dawg, we put a proxy in yo proxy so you can connect while you connect"*

## Problem

You have to run Mattermost behind behind two Apache proxies, and also want to run it in a subdirectory

## Solution

**Note:** This code is provided as a reference on how to use proxies, and important things like firewalls and load balancing are absent. **DO NOT USE THIS FOR PRODUCTION WITHOUT SIGNIFICANT MODIFICATIONS**

1. On the external proxy server, install the `proxy_conf.conf` file as a Virtualhost. In Ubuntu 16.04 this is in `/etc/apache2/sites-available`, which you then activate with `a2ensite`.
2. On the internal server, install Apache and Mattermost, then load the `apache.conf` file as a virtual host like in step 1, and make sure the `SiteURL` in `/opt/mattermost/config.json` matches the URL you want to use to connect to Mattermost.
3. Restart both instances of Apache - `sudo service apache2 restart` on Ubuntu - and the instance of Mattermost.
4. Connect to your new instance by going to `https://www.bandicootsrus.com/mattermost/`

## Discussion

### How does this work?

When a request is made to `https://www.bandicootsrus.com/mattermost` it encrypts it via SSL. Then it connects to the Mattermost server via another Apache proxy. In this case, the connection is encrypted with a certificate signed by an internal security authority. 

#### internal_apache.conf

This file was pulled almost directly from the [unofficial Mattermost Apache documentation](https://docs.mattermost.com/install/config-apache2.html). The internally-signed certificates are loaded for SSL, and the listening port is set to something non-standard. If you just need to run Mattermost behind one Apache proxy you can use just this config file.

#### external_apache.conf

This file configures the public-facing web server to send requests to the internal server in the `<Location /mattermost/>...</Location>` section. If you have an existing Apache server and want to just proxy to Mattermost, change the `RewriteRule`, `ProxyPass`, and `ProxyPassReverse` sections to point to your Mattermost server.

#### apache_setup.sh

This file is what Vagrant uses to set up the public-facing Apache server. In order for the SSL connection from this server to the internal server

### Why two proxies?

This is kind of a unique setup, but the requirement to have internal communications encrypted with a certificate signed by the internal certificate authority couldn't be changed. To work around this, we have one Apache proxy proxying connections to an Apache proxy who is proxying for Mattermost, running on the internal server.

### Why your own certificate authority? 

Having an internal certificate authority and removing all others from your systems means that there is no third-party to involved in your TLS connections. None of your internal systems would be able to even open an SSL connection to anywhere, even if an otherwise valid certificate is being used. Setting up your own certificate authority is surprisingly easy to do, and I highly recommend [these instructions](https://deliciousbrains.com/ssl-certificate-authority-for-local-https-development/)

### How does running it in a subdirectory work?

When processing requests Mattermost looks mostly at the path of the request than the domain. So from the Mattermost server through both proxies you need to tell the connection the path to go to.

### How do I run this in Vagrant?

First, download [Virtualbox] and [Vagrant] and install them. Then, check this repository out and go into the directory. Make sure the `ip` in the `public_network` in the `Vagrantfile` is valid, and run `vagrant up`.

While this is booting, modify your hosts file like mentioned in the **Solution** section. If you're on a Mac this will do the trick:

```bash
$ sudo bash
# echo '<VALID LOCAL IP>    www.bandicootsrus.com' >> /etc/hosts
```

If you're really daring you can follow  to install `root_CA.pem` on your system, and then the certificate will appear valid.

Then go to `https://www.bandicootsrus.com/mattermost/` in your browser and you can log in with the username and password `admin`.

*When you're done testing make sure to run `vagrant halt apache` and `vagrant halt mattermost` to stop the servers. To delete them entirely, run `vagrant destroy`*

[Virtualbox]: https://www.virtualbox.org/wiki/Downloads
[Vagrant]: https://www.vagrantup.com/downloads.html
