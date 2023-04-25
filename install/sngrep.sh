cat >>  /etc/yum.repos.d/irontec.repo <<-'EOF'
[irontec]
name=Irontec RPMs repository
baseurl=http://packages.irontec.com/centos/$releasever/$basearch/
EOF
rpm --import http://packages.irontec.com/public.key
yum install -y sngrep