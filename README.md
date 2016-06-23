
# Building Kubernetes 

on  mac run a new docker shell then (note we use build-cross.sh to make compatible binaries for linux)
```
mkdir -p ~/dev/git/
git clone https://github.com/childsb/kubernetes.git
cd ~/dev/git/kubernetes
hack/build-cross.sh 
```

This puts binaries in /dev/git/kubernetes/_output

Now create a new EC2 instance.  download the pem, chmod it..
set a variable for ease of use

```
chmod 0600 ~/.ssh/bchilds-devbox-2.pem
export EC2_MASTER=ec2-52-26-223-17.us-west-2.compute.amazonaws.com
ssh ec2-user@${EC2_MASTER} -i ~/.ssh/bchilds-devbox-2.pem
```
once on the box copy your authorized_key to the authorized_key on the node for easier access
make a directory for the kube binaries
```
mkdir -p /kube/
```

copy the build of kube to your master node
```
scp  -i ~/.ssh/bchilds-devbox-2.pem  _output/local/bin/darwin/amd64/*  ec2-user@${EC2_MASTER}:/kube
```
OR
```
rsync -avL --progress -e "ssh -i ~/.ssh/bchilds-devbox-2.pem"  _output/local/bin/darwin/amd64/* ec2-user@${EC2_MASTER}:/kube
```

setup the nodes from scratch

Install docker on RHEL
```
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
```

get the IP address of eth0
```
export IP_ADDR=`ip addr show eth0 | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/'`
```

get the etcd binary
```
cd ~
curl -L  https://github.com/coreos/etcd/releases/download/v2.3.7/etcd-v2.3.7-linux-amd64.tar.gz -o etcd-v2.3.7-linux-amd64.tar.gz
tar xzvf etcd-v2.3.7-linux-amd64.tar.gz
cd etcd-v2.3.7-linux-amd64
sudo cp etcd* /usr/bin/
```

install etcd as a container for ease.. container wont work with the shell scripts
```
sudo docker run -d -p 8001:8001 -p 5001:5001 quay.io/coreos/etcd:v0.4.6 -peer-addr 127.0.0.1:8001 -addr 127.0.0.1:5001 -name etcd-node1
```
copy the hack scripts to the node
```
scp  -i ~/.ssh/bchilds-devbox-2.pem -r cluster/ ec2-user@${EC2_MASTER}:/kube/cluster
scp  -i ~/.ssh/bchilds-devbox-2.pem -r hack/ ec2-user@${EC2_MASTER}:/kube/hack
```
run the single node hack script using the binaries copied to /kube
```
cd /kube

./local-up-cluster.sh -o /kube/
```
