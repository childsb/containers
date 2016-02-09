#!/bin/sh

KUBE_CMD='kubectl.sh'

# Takes PV name as arg
createPV(){
read -r -d '' PV << EOM
kind: PersistentVolume
apiVersion: v1
metadata:
  name: ${1}
  labels:
    type: local
spec:
  capacity:
    storage: 5Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/tmp"
EOM
echo "${PV}" | ${KUBE_CMD} create -f -
#echo "${PV}"

}

#Takes claim name as arg
createPVC(){
read -r -d '' PVC << EOM
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: $1
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 3Gi
EOM
echo "${PVC}" | ${KUBE_CMD} create -f -
#echo "${PVC}"

}

#Takes rcname, claim name as arg
createRC(){
read -r -d '' RC << EOM
apiVersion: v1
kind: ReplicationController
metadata:
  labels:
    name: $2
  name: $2
spec:
  replicas: 1
  selector:
    name: $2-volume-capacity-test-rc
  template:
    metadata:
      labels:
        name: $2-volume-capacity-test-rc
    spec:
      restartPolicy: Always
      containers:
        - image: gcr.io/google_containers/nginx:1.7.9
          name: $2-volume-capacity-test
          ports:
           - containerPort: 80
          volumeMounts:
            - name: testvol
              mountPath: /mnt/rbd
      volumes:
        - name: testvol
          persistentVolumeClaim:
           claimName: $1
EOM
echo "${RC}" | ${KUBE_CMD} create -f -
# echo "${RC}"
}

test1(){
for num in {1..10}
do
    PVNAME="pv-test-${num}"
    PVCNAME="pvc-test-${num}"
    RCNAME="rctest${num}"
    createPV $PVNAME
    createPVC $PVCNAME
    createRC $PVCNAME $RCNAME
done
}

cleanup1(){
for num in {1..10}
do
    PVNAME="pv-test-${num}"
    PVCNAME="pvc-test-${num}"
    RCNAME="rctest${num}"
    ${KUBE_CMD} delete rc $RCNAME
    ${KUBE_CMD} delete pv $PVNAME
    ${KUBE_CMD} delete pvc $PVCNAME

done
}

test1
cleanup1

