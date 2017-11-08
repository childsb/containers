# clones a git repo and adds the upstream fork
# curl https://api.github.com/repos/childsb/kubernetes

# git clone https://github.com/childsb/kubernetes.git
# git clone git://github.com/childsb/kubernetes.git
#
#!/bin/sh

print_help() {
    echo "Usage: $0 git://github.com/childsb/kubernetes.git [OPTION]..."
    echo ""
    echo "Options:"
    echo " -g, --golang   	clones this project into the proper golang path"
    echo " -o, --org   	 	uses specified org instead of trying to discover it from the git path. (only for golang)"
    echo " -r, --repo_host  git repo host (defaults to github.com)"
    echo " -h, --help       show this message"
    echo ""

}

print_parsed(){
	echo "proto: ${proto}"
	echo "url: ${url}"
	echo "user: ${user}"
	echo "host: ${host}"
	echo "port: ${port}"
	echo "path: ${path}"
	echo "org: ${org}"
	echo "repo_full: ${repo_full}"
	echo "repo: ${repo}"
}

parse_url() {

	# extract the protocol
	if [[ $1 =~ .*://.* ]]; then
		# protocol specified
		proto="$(echo $1 | grep :// | sed -e's,^\(.*://\).*,\1,g')"
		# remove the protocol -- updated
		url=$(echo $1 | sed -e s,$proto,,g)
		# extract the user (if any)
		user="$(echo $url | grep @ | cut -d@ -f1)"

		# extract the host -- updated
		host=$(echo $url | sed -e s,$user@,,g | cut -d/ -f1)
		# by request - try to extract the port
		port="$(echo $host | sed -e 's,^.*:,:,g' -e 's,.*:\([0-9]*\).*,\1,g' -e 's,[^0-9],,g')"
		# extract the path (if any)
		path="$(echo $url | grep / | cut -d/ -f2-)"

		
	else
		# echo "WARN: no proto specified.."
		proto=""
		url=$1
		# extract the host -- updated
		user="$(echo $url | grep @ | cut -d@ -f1)"
		host=$(echo $url | sed -e s,$user@,,g | cut -d/ -f1)
		path="$(echo $url | grep / | cut -d/ -f2-)"
		
	fi
	
	if [[ $path =~ .*/.* ]]; then
		org="$(echo $path | cut -d "/" -f1)"
	else
		org="$(echo $host | cut -d ":" -f2)"
	fi
	
	repo_full="$(echo $path | cut -d "/" -f2)"
	repo="$(echo $repo_full | sed -e 's/\.git//g')"
}

detect_git_host() {

	if  [ -z ${REPO_HOST} ]; then
	  return
	fi
	
	if  [ "$repo" = "kubernetes" ]; then
		echo "Found kubernetes, using k8s for repo"
		REPO_HOST="k8s.io"
	fi
	REPO_HOST="github.org"
}

setup_git() {

	# finds the parent of a forked repo.
	parent_url=$(curl -sS "https://api.github.com/repos/${org}/${repo}" | jq -cr '.parent.ssh_url')

	if [ "$parent_url" != "null" ]; then
		# parse the parent URL to determine the real ORG
		parse_url $parent_url
	fi

	if  [ "$GO_LANG" = true ]; then
		# check for common repo over-rides
		detect_git_host
		echo "Cloning into $GOPATH instead of current directory .."
		if ! [  -z ${ORG_OVERIDE} ]; then
			echo "Using $ORG_OVERIDE instead of $ORG"       
			mkdir -p  ${GOPATH}/src/${REPO_HOST}/${ORG_OVERIDE}
			cd  ${GOPATH}/src/${REPO_HOST}/${ORG_OVERIDE}
		else
			echo "No ORG over ride"
			mkdir -p ${GOPATH}/src/$REPO_HOST/$org
			cd  ${GOPATH}/src/$REPO_HOST/$org
		fi	
	fi

	git clone $primary_repo
	cd $repo

	if [ "$parent_url" == "null" ]; then
		echo "Not setting upstream..."
	else
		echo "This repo appears to be a fork of: ${parent_url}.. Adding upstream remote"
		git remote add upstream ${parent_url}
	fi

}

if ! [ -x "$(command -v jq)" ]; then
  echo 'This script requires jq, Please install (https://stedolan.github.io/jq/download/)' >&2

  exit 1
fi

GO_LANG=false


# Parse args
while [ "${1+isset}" ]; do
    case "$1" in
        -g|--golang)
           GO_LANG=true
            shift 1 
            ;;
        -h|--help)
            print_help
  			exit 1
            ;;
        -r|--repo_host)
            REPO_HOST=$2
  			shift 2
            ;;
        -o|--org)
            ORG_OVERIDE=$2
  			shift 2
            ;;
   *)
     primary_repo=$1
     shift 1
    ;;
    esac
done

if  [ -z ${primary_repo} ]; then
  print_help
  exit 1
       
fi


# Parse the git URL into its pieces.
parse_url $primary_repo
setup_git

# print_parsed






# curl -sS "https://api.github.com/repos/${org}/${repo}" | jq -cr '.parent.ssh_url'

# parent_url=$(curl https://api.github.com/repos/${org}/${repo} | jq -c '.parent.ssh_url')

# echo "Parent URL: ${parent_url}"


