set -ex

export CREDS="${CREDS:-ocp-edge-qe+ocp_edge_qe_robot:JWFJNUUF2L1KFQOOP900A297ZDCEXDMXEW8D9YAJ3P50P1AFK18ZM1408WHZOH52}"
export IMAGE="quay.io/ocp-edge-qe/eco-dast:latest"

sudo setenforce 0
sudo podman run --rm --privileged quay.io/ocp-edge-qe/qemu-user-static --reset -p yes

for arch in amd64 arm64; do
  {
  podman build --platform linux/$arch --build-arg ARCH=$arch -t $IMAGE-$arch -f Dockerfile
  podman push  --creds=$CREDS $IMAGE-$arch
  podman rmi                  $IMAGE-$arch
  } &
done
wait

podman rmi -f $IMAGE || true
podman manifest create $IMAGE $IMAGE-amd64 $IMAGE-arm64
podman manifest push --creds=$CREDS $IMAGE $IMAGE
podman rmi -f $IMAGE

exit
