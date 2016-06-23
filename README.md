# containers

# Building Kubernetes on my mac
# run a new docker shell then

cd ~/dev/git/kubernetes
hack/build-go.sh 

# This puts binaries in <kubedir>_output

# create a new EC2 instance.  download the pem, chmod it
chmod 0600 ~/.ssh/bchilds-devbox-2.pem

ssh ec2-user@ec2-52-26-223-17.us-west-2.compute.amazonaws.com -i ~/.ssh/bchilds-devbox-2.pem
# once on the box copy your authorized_key to the authorized_key on the node for easier access

# make a directory for the kube binaries

mkdir -p /kube

# copy the build of kube to your master node
scp  -i ~/.ssh/bchilds-devbox-2.pem  _output/local/bin/darwin/amd64/*  ec2-user@ec2-52-26-223-17.us-west-2.compute.amazonaws.com:/kube


#setup the nodes from scratch

# Install docker on RHEL

sudo tee /etc/yum.repos.d/docker.repo <<-EOF
[dockerrepo]
name=Docker Repository
baseurl=https://yum.dockerproject.org/repo/main/centos/7
enabled=1
gpgcheck=1
gpgkey=https://yum.dockerproject.org/gpg
EOF

sudo yum install docker-engine
sudo service docker start

# get the IP address of eth0
export IP_ADDR=`ip addr show eth0 | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/'`

# get the etcd binary
cd ~
curl -L  https://github.com/coreos/etcd/releases/download/v2.3.7/etcd-v2.3.7-linux-amd64.tar.gz -o etcd-v2.3.7-linux-amd64.tar.gz
tar xzvf etcd-v2.3.7-linux-amd64.tar.gz
cd etcd-v2.3.7-linux-amd64
sudo cp etcd* /usr/local/bin/

# install etcd as a container for ease.. container wont work with the shell scripts
sudo docker run -d -p 8001:8001 -p 5001:5001 quay.io/coreos/etcd:v0.4.6 -peer-addr 127.0.0.1:8001 -addr 127.0.0.1:5001 -name etcd-node1

# copy the hack scripts to the node
scp  -i ~/.ssh/bchilds-devbox-2.pem cluster/kubectl.sh ec2-user@ec2-52-26-223-17.us-west-2.compute.amazonaws.com:/kube
scp  -i ~/.ssh/bchilds-devbox-2.pem hack/local-up-cluster.sh ec2-user@ec2-52-26-223-17.us-west-2.compute.amazonaws.com:/kube

# run the single node hack script using the binaries copied to /kube
local-up-cluster.sh -o /kube/
