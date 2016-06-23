# Building Kubernetes & deploy to EC2

Create a new EC2 instance.  download the pem, chmod it..  
make sure you have a user with ID and KEY.  This user should have admin-ish permissions.

Set a variable pointing to the instance for imediate gratification.

```
chmod 0600 ~/.ssh/bchilds-devbox-2.pem
export EC2_MASTER=ec2-52-26-223-17.us-west-2.compute.amazonaws.com
ssh ec2-user@${EC2_MASTER} -i ~/.ssh/bchilds-devbox-2.pem
```
once on the box copy your public personal key to the authorized_key on the node for easier access.. or keep using the ec2 specific..

## Setup the EC2 nodes from scratch

Create a directory for the kube binaries (ec2 instance):
```
mkdir -p /kube/
```

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

Useful: get the IP address of eth0
```
export IP_ADDR=`ip addr show eth0 | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/'`
```

Install the etcd binary
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

## Build Locally 
Back on build box run a new Docker shell (mac) then (note- use build-cross.sh to make compatible binaries for linux)
```
mkdir -p ~/dev/git/
git clone https://github.com/childsb/kubernetes.git
cd ~/dev/git/kubernetes
hack/build-cross.sh 
```

This puts binaries in ~/dev/git/kubernetes/_output

Copy the hack scripts to the node.. Use /kube/kubectl instead of kubectl.sh
```
scp  -i ~/.ssh/bchilds-devbox-2.pem -r hack/ ec2-user@${EC2_MASTER}:/kube/hack
```
OR
```
rsync -avzL --progress -e "ssh -i ~/.ssh/bchilds-devbox-2.pem" hack/ ec2-user@${EC2_MASTER}:/kube/hack

```


Copy the local build (from build machine)
```
scp  -i ~/.ssh/bchilds-devbox-2.pem  _output/local/bin/linux/amd64*  ec2-user@${EC2_MASTER}:/kube
```
OR
```
rsync -avzL --progress -e "ssh -i ~/.ssh/bchilds-devbox-2.pem"  _output/local/bin/linux/amd64/* ec2-user@${EC2_MASTER}:/kube
```

run the single node hack script using the binaries copied to /kube .. i had to ```su``` to get this to work right 
```
cd /kube
export AWS_ACCESS_KEY_ID=yourkey
export AWS_SECRET_ACCESS_KEY=<secret key> 
export CLOUD_PROVIDER=aws

./hack/local-up-cluster.sh -o /kube/
```
